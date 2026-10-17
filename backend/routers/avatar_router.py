"""
DresKode Phase 3 — Full Avatar Reconstruction Pipeline
POST /v1/avatar/reconstruct

Pipeline stages:
  Stage 1: Skin tone extraction (OpenCV)
  Stage 1: 33-keypoint 3D skeleton (MediaPipe Pose)
  Stage 1: Body proportion ratios
  Stage 1: Face crop extraction
  Stage 3: Biometric mesh morphing + UV face texture (Trimesh + PIL)
  Stage 4: GLB storage + signed URL generation
"""

import time
from fastapi import APIRouter, UploadFile, File, Form, Request, HTTPException
from typing import Optional

from models.schemas import AvatarReconstructResponse, AvatarMetadata
from services.landmark_extractor import LandmarkExtractor
from services.avatar_generator import AvatarGenerator
from services.storage_service import StorageService
from services.database_service import DatabaseService

router    = APIRouter(prefix="/v1/avatar", tags=["3D Avatar Pipeline"])
avatar_gen  = AvatarGenerator()
storage_svc = StorageService()
db_svc      = DatabaseService()


@router.post("/reconstruct", response_model=AvatarReconstructResponse)
async def reconstruct_3d_avatar(
    request:       Request,
    front_image:   Optional[UploadFile] = File(None),
    side_image:    Optional[UploadFile] = File(None),
    back_image:    Optional[UploadFile] = File(None),
    user_id:       Optional[str]  = Form(None),
    gender:        str            = Form("female"),
    height_cm:     float          = Form(174.0),
    weight_kg:     Optional[float]= Form(None),
    bust_cm:       float          = Form(86.0),
    waist_cm:      float          = Form(66.0),
    hips_cm:       float          = Form(94.0),
    shoulder_type: str            = Form("Classique"),
    shoulder_cm:   Optional[float]= Form(None),   # ← exact shoulder width in cm
):
    """
    DresKode Technical Specification (PDF Page 5, 6, 11) — Full Phase 3 Pipeline.

    Accepts up to 3 body photos (front, side, back) + biometric measurements.
    Returns a personalised .glb 3D humanoid avatar URL.
    """
    start_time = time.time()
    pipeline_log = []

    # ── Read uploaded image bytes ─────────────────────────────────────────────
    front_bytes = None
    side_bytes  = None
    back_bytes  = None

    if front_image:
        try:
            front_bytes = await front_image.read()
            pipeline_log.append(f"front_image: {len(front_bytes)} bytes")
        except Exception as e:
            pipeline_log.append(f"front_image read error: {e}")

    if side_image:
        try:
            side_bytes = await side_image.read()
            pipeline_log.append(f"side_image: {len(side_bytes)} bytes")
        except Exception:
            pass

    if back_image:
        try:
            back_bytes = await back_image.read()
            pipeline_log.append(f"back_image: {len(back_bytes)} bytes")
        except Exception:
            pass

    # ══════════════════════════════════════════════════════════════════════════
    # STAGE 1A: Skin tone extraction (OpenCV)
    # ══════════════════════════════════════════════════════════════════════════
    skin_rgb = (235, 195, 175)  # neutral default
    if front_bytes:
        try:
            skin_rgb = LandmarkExtractor.sample_skin_tone(front_bytes)
            pipeline_log.append(f"stage1a_skin_rgb: {skin_rgb}")
        except Exception as e:
            pipeline_log.append(f"stage1a_skin_error: {e}")

    # ══════════════════════════════════════════════════════════════════════════
    # STAGE 1B: MediaPipe 33-keypoint skeleton extraction
    # ══════════════════════════════════════════════════════════════════════════
    keypoint_data = None
    if front_bytes:
        try:
            keypoint_data = LandmarkExtractor.extract_33_keypoints(front_bytes)
            if keypoint_data:
                pipeline_log.append(
                    f"stage1b_keypoints: {len(keypoint_data['world_landmarks'])} landmarks"
                )
            else:
                pipeline_log.append("stage1b_keypoints: not detected (fallback)")
        except Exception as e:
            pipeline_log.append(f"stage1b_keypoint_error: {e}")

    # ══════════════════════════════════════════════════════════════════════════
    # STAGE 1C: Body proportion ratios from keypoints
    # ══════════════════════════════════════════════════════════════════════════
    body_proportions = None
    try:
        body_proportions = LandmarkExtractor.compute_body_proportions(
            keypoint_data=keypoint_data,
            height_cm=height_cm,
            front_image_bytes=front_bytes,
        )
        pipeline_log.append(f"stage1c_proportions_source: {body_proportions.get('source', 'unknown')}")
    except Exception as e:
        pipeline_log.append(f"stage1c_proportions_error: {e}")

    # ══════════════════════════════════════════════════════════════════════════
    # STAGE 1D: Face crop extraction (for UV texture projection)
    # ══════════════════════════════════════════════════════════════════════════
    face_crop_bytes = None
    if front_bytes:
        try:
            face_crop_bytes = LandmarkExtractor.crop_face_region(front_bytes)
            if face_crop_bytes:
                pipeline_log.append(f"stage1d_face_crop: {len(face_crop_bytes)} bytes")
            else:
                pipeline_log.append("stage1d_face_crop: not extracted")
        except Exception as e:
            pipeline_log.append(f"stage1d_face_error: {e}")

    # ══════════════════════════════════════════════════════════════════════════
    # STAGE 3: Biometric mesh morphing + UV face texture + GLB export
    # ══════════════════════════════════════════════════════════════════════════
    try:
        print(f"\n[AvatarPipeline] >>> NEW RECONSTRUCTION REQUEST <<<")
        print(f"[AvatarPipeline] Input: gender={gender}, height={height_cm}cm, weight={weight_kg}kg, bust={bust_cm}cm, waist={waist_cm}cm, hips={hips_cm}cm, shoulders={shoulder_type}")
        gen_result = avatar_gen.generate_avatar(
            user_id=user_id,
            gender=gender,
            height_cm=height_cm,
            bust_cm=bust_cm,
            waist_cm=waist_cm,
            hips_cm=hips_cm,
            shoulder_type=shoulder_type,
            shoulder_cm=shoulder_cm,
            skin_rgb=skin_rgb,
            face_crop_bytes=face_crop_bytes,
            body_proportions=body_proportions,
            weight_kg=weight_kg,
            full_image_bytes=front_bytes,
        )
        pipeline_log.append(
            f"stage3_morphed: {gen_result.get('morphed', False)} ({gen_result.get('engine_source', 'local')}) | "
            f"scales: x={gen_result['scales']['x']} y={gen_result['scales']['y']} z={gen_result['scales']['z']}"
        )
    except Exception as e:
        pipeline_log.append(f"stage3_error: {e}")
        raise HTTPException(status_code=500, detail=f"Avatar generation failed: {e}")

    # ══════════════════════════════════════════════════════════════════════════
    # STAGE 4: GLB URL publication
    # ══════════════════════════════════════════════════════════════════════════
    base_url = str(request.base_url).rstrip("/")
    client_host = request.client.host if request.client else ""
    if "10.0.2.2" in client_host:
        base_url = "http://10.0.2.2:8000"

    try:
        glb_url = storage_svc.upload_glb(
            file_path=gen_result["output_path"],
            destination_name=gen_result["output_filename"],
            base_server_url=base_url,
        )
        pipeline_log.append(f"stage4_glb_url: {glb_url}")
    except Exception as e:
        pipeline_log.append(f"stage4_storage_error: {e}")
        raise HTTPException(status_code=500, detail=f"GLB storage failed: {e}")

    elapsed = round(time.time() - start_time, 3)
    print(f"[AvatarPipeline] {elapsed}s | " + " | ".join(pipeline_log))

    # ══════════════════════════════════════════════════════════════════════════
    # STAGE 5: Persistent Database Save (SQLite / Supabase)
    # ══════════════════════════════════════════════════════════════════════════
    db_svc.save_avatar_record(
        avatar_id=gen_result["avatar_id"],
        user_id=user_id,
        gender=gender,
        height_cm=height_cm,
        weight_kg=weight_kg,
        bust_cm=bust_cm,
        waist_cm=waist_cm,
        hips_cm=hips_cm,
        shoulder_type=shoulder_type,
        glb_url=glb_url,
        morphed=gen_result.get("morphed", False),
        scales=gen_result.get("scales"),
        created_at=gen_result.get("created_at"),
    )

    return AvatarReconstructResponse(
        status="success",
        message=(
            "Avatar 3D morphé avec succès — "
            f"MediaPipe: {'✓' if keypoint_data else '✗'} | "
            f"UV Texture: {'✓' if face_crop_bytes else '✗'} | "
            f"Morphed: {'✓' if gen_result.get('morphed') else '✗'}"
        ),
        processing_time_sec=elapsed,
        avatar=AvatarMetadata(
            avatar_id=gen_result["avatar_id"],
            user_id=user_id,
            gender=gender,
            height_cm=height_cm,
            bust_cm=bust_cm,
            waist_cm=waist_cm,
            hips_cm=hips_cm,
            shoulder_type=shoulder_type,
            glb_url=glb_url,
            created_at=gen_result["created_at"],
        ),
    )


@router.get("/latest")
async def get_latest_avatar(user_id: Optional[str] = None):
    """
    Returns the most recently generated 3D avatar with all saved biometric measurements.
    """
    record = db_svc.get_latest_avatar(user_id)
    if not record:
        raise HTTPException(status_code=404, detail="No avatar record found")
    return {"status": "success", "avatar": record}


@router.get("/health", tags=["Health"])
async def pipeline_health_check():
    """
    Returns the availability status of each pipeline component.
    Useful for the Flutter app to show which AI stages are active.
    """
    status = {
        "pipeline": "DresKode Phase 3 — 3D Avatar AI Engine",
        "stages": {}
    }

    # Check OpenCV
    try:
        import cv2
        status["stages"]["stage1a_opencv_skin"] = f"✓ cv2 {cv2.__version__}"
    except ImportError:
        status["stages"]["stage1a_opencv_skin"] = "✗ opencv not installed"

    # Check MediaPipe
    try:
        import mediapipe as mp
        status["stages"]["stage1b_mediapipe_skeleton"] = f"✓ mediapipe {mp.__version__}"
    except ImportError:
        status["stages"]["stage1b_mediapipe_skeleton"] = "✗ mediapipe not installed (fallback active)"

    # Check Pillow
    try:
        from PIL import Image
        import PIL
        status["stages"]["stage1d_pillow_face_uv"] = f"✓ Pillow {PIL.__version__}"
    except ImportError:
        status["stages"]["stage1d_pillow_face_uv"] = "✗ Pillow not installed"

    # Check trimesh
    try:
        import trimesh
        status["stages"]["stage3_trimesh_morphing"] = f"✓ trimesh {trimesh.__version__}"
    except ImportError:
        status["stages"]["stage3_trimesh_morphing"] = "✗ trimesh not installed"

    # Check base_avatar.glb
    from services.avatar_generator import AvatarGenerator
    gen = AvatarGenerator()
    template = gen._resolve_template_path()
    status["stages"]["base_avatar_glb"] = f"✓ {template}" if template else "✗ base_avatar.glb not found"

    return status


@router.post("/auth/send-login-otp")
async def send_login_otp(request: Request):
    """
    Triggers Supabase OTP for existing user login.
    Uses admin generate_link (magiclink type) - Supabase emails the magic link/OTP automatically.
    The 6-digit token embedded in the magic link IS the OTP the user enters.
    """
    try:
        body = await request.json()
        email = body.get("email", "").strip()
        if not email:
            raise HTTPException(status_code=400, detail="Email is required")

        import os
        from supabase import create_client
        url = os.environ.get("SUPABASE_URL", "https://oifklsdxmpmdfbnaazso.supabase.co")
        service_key = os.environ.get("SUPABASE_SERVICE_KEY", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9pZmtsc2R4bXBtZGZibmFhenNvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc5MTYyNjcyMywiZXhwIjoyMTA3MjAyNzIzfQ.ZRqmi-fxfSJF5PbEICvjStspDRBxS-xI_qkO__W8d1k")
        admin_client = create_client(url, service_key)

        # generate_link with type="magiclink" generates the OTP AND sends email via Supabase SMTP
        link_res = admin_client.auth.admin.generate_link({
            "type": "magiclink",
            "email": email
        })

        otp_code = None
        if hasattr(link_res, "properties") and hasattr(link_res.properties, "email_otp"):
            otp_code = link_res.properties.email_otp

        print(f"[Auth] Login OTP generated & email sent for {email}. OTP (debug): {otp_code}")
        return {"status": "ok", "email": email, "message": "OTP sent to email"}

    except HTTPException:
        raise
    except Exception as e:
        print(f"[Auth] send_login_otp error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to send OTP: {str(e)}")
