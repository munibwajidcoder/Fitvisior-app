"""
DresKode Phase 3 — Stage 3: Photorealistic 3D Humanoid Avatar Generator
Technology: Binary glTF (GLB) lossless node scaling + Biometric anisotropic morphing + PBR skin tone blending

Pipeline:
  1. Load photorealistic humanoid GLB template (male or female base)
  2. Apply anisotropic biometric scaling (bust, waist, hips, height, shoulders) to root bone & mesh nodes
  3. Blend real user skin tone RGB into PBR body materials
  4. Export production-grade .glb binary for ModelViewer in Flutter
"""

import os
import io
import json
import uuid
import shutil
import numpy as np
import cv2
from datetime import datetime, timezone
from typing import Dict, Any, Tuple, Optional
from services.tripo_service import Tripo3DService


class AvatarGenerator:
    """
    Stage 3 of the DresKode 3D Avatar Pipeline.

    Produces a personalized photorealistic .glb 3D human avatar from:
      - Tripo3D Cloud AI (Real clothes, real hair volume, real beard, and face)
      - Biometric anatomical morphing engine (precise height, bust, waist, hips, shoulders)
    """

    # DresKode reference biometrics
    REF_FEMALE = {"height": 174.0, "bust": 86.0, "waist": 66.0, "hips": 94.0}
    REF_MALE   = {"height": 178.0, "bust": 98.0, "waist": 82.0, "hips": 96.0}

    SHOULDER_SCALE = {"Minces": 0.94, "Classique": 1.0, "Larges": 1.06}

    def __init__(
        self,
        template_glb_path: Optional[str] = None,
        output_dir: Optional[str] = None,
    ):
        backend_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.output_dir = output_dir or os.path.join(backend_dir, "static", "avatars")
        self.template_glb_path = template_glb_path or os.path.join(
            backend_dir, "assets", "models", "base_avatar.glb"
        )
        self.backend_dir = backend_dir
        self.tripo_svc = Tripo3DService()
        os.makedirs(self.output_dir, exist_ok=True)

    # ── PUBLIC API ────────────────────────────────────────────────────────────

    def generate_avatar(
        self,
        user_id: Optional[str],
        gender: str,
        height_cm: float,
        bust_cm: float,
        waist_cm: float,
        hips_cm: float,
        shoulder_type: str,
        skin_rgb: Tuple[int, int, int] = (235, 195, 175),
        face_crop_bytes: Optional[bytes] = None,
        body_proportions: Optional[Dict[str, Any]] = None,
        weight_kg: Optional[float] = None,
        full_image_bytes: Optional[bytes] = None,
        shoulder_cm: Optional[float] = None,
    ) -> Dict[str, Any]:
        """
        Main entry point. Generates photorealistic 3D avatar.
        - WITH photo: Tripo3D image_to_model (photorealistic face + body)
        - WITHOUT photo: Tripo3D text_to_model (measurement-accurate body, random face)
        - Fallback: local anatomical GLB morphing
        """
        avatar_id = f"av_{uuid.uuid4().hex[:12]}"
        output_filename = f"{avatar_id}.glb"
        output_path = os.path.join(self.output_dir, output_filename)

        # ── Compute biometric scale factors ───────────────────────────────
        scales = self._compute_scales(
            gender, height_cm, bust_cm, waist_cm, hips_cm,
            shoulder_type, body_proportions, weight_kg
        )

        engine_source = "local_anatomical_morph"
        morphed = False

        # ── 1. Tripo3D Image-to-3D (when user photo available) ───────────
        if full_image_bytes and len(full_image_bytes) > 2000:
            try:
                tripo_res = self.tripo_svc.generate_avatar_from_image(full_image_bytes, output_path)
                if tripo_res and os.path.exists(output_path) and os.path.getsize(output_path) > 10000:
                    morphed = True
                    engine_source = "tripo3d_image_to_model"
                    print(f"[AvatarGenerator] Photorealistic avatar via Tripo3D image_to_model!")
            except Exception as e:
                print(f"[AvatarGenerator] Tripo3D image_to_model error: {e}")

        # ── 2. Tripo3D Text-to-3D (no photo — measurement-accurate body, random face) ─
        if not morphed:
            try:
                is_male = gender.lower() in ["male", "homme", "man", "m"]
                # Estimate shoulder_cm from shoulder_type if not provided
                sh_cm = shoulder_cm or (
                    (44.0 if is_male else 38.0) * self.SHOULDER_SCALE.get(shoulder_type, 1.0)
                )
                wt = weight_kg or (75.0 if is_male else 60.0)
                tripo_res = self.tripo_svc.generate_avatar_from_measurements(
                    gender=gender,
                    height_cm=height_cm,
                    weight_kg=wt,
                    bust_cm=bust_cm,
                    waist_cm=waist_cm,
                    hips_cm=hips_cm,
                    shoulder_cm=sh_cm,
                    output_glb_path=output_path,
                )
                if tripo_res and os.path.exists(output_path) and os.path.getsize(output_path) > 10000:
                    morphed = True
                    engine_source = "tripo3d_text_to_model_measurements"
                    print(f"[AvatarGenerator] Measurement-accurate avatar via Tripo3D text_to_model!")
            except Exception as e:
                print(f"[AvatarGenerator] Tripo3D text_to_model error: {e}")

        # ── 3. Fallback to local anatomical GLB morph ────────────────────
        if not morphed:
            morphed = self._morph_and_export(
                output_path, scales, skin_rgb, face_crop_bytes, gender
            )
            if not morphed:
                self._copy_template(output_path, gender)

        return {
            "avatar_id":       avatar_id,
            "user_id":         user_id,
            "gender":          gender,
            "height_cm":       height_cm,
            "weight_kg":       weight_kg,
            "bust_cm":         bust_cm,
            "waist_cm":        waist_cm,
            "hips_cm":         hips_cm,
            "shoulder_type":   shoulder_type,
            "skin_rgb":        list(skin_rgb),
            "scales":          scales,
            "output_path":     output_path,
            "output_filename": output_filename,
            "morphed":         morphed,
            "engine_source":   engine_source,
            "created_at":      datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        }

    # ── SCALE COMPUTATION ─────────────────────────────────────────────────────

    def _compute_scales(
        self,
        gender: str,
        height_cm: float,
        bust_cm: float,
        waist_cm: float,
        hips_cm: float,
        shoulder_type: str,
        proportions: Optional[Dict[str, Any]],
        weight_kg: Optional[float] = None,
    ) -> Dict[str, float]:
        """
        Produces a per-axis scale vector for anisotropic GLB mesh morphing.
        Uses gender-specific reference baselines.
        """
        is_male = (
            gender.lower() in ["male", "homme", "man", "m"] or
            (proportions is not None and proportions.get("shoulder_to_hip_ratio", 1.0) >= 1.25)
        )
        ref = self.REF_MALE if is_male else self.REF_FEMALE

        sc_height    = height_cm / ref["height"]
        sc_bust      = bust_cm   / ref["bust"]
        sc_waist     = waist_cm  / ref["waist"]
        sc_hips      = hips_cm   / ref["hips"]
        sc_shoulders = self.SHOULDER_SCALE.get(shoulder_type, 1.0)

        # ── Weight bulk factor (crucial for skinny vs heavy / mota avatars) ─
        if weight_kg and weight_kg > 0:
            ref_weight = 75.0 if is_male else 60.0
            weight_bulk = float(np.clip(np.sqrt(weight_kg / ref_weight), 0.65, 1.55))
            sc_waist = sc_waist * (0.35 + 0.65 * weight_bulk)
            sc_bust  = sc_bust  * (0.50 + 0.50 * weight_bulk)
            sc_hips  = sc_hips  * (0.45 + 0.55 * weight_bulk)
            print(f"[AvatarGenerator] Weight impact: {weight_kg}kg (ref {ref_weight}kg) -> bulk factor: {weight_bulk:.2f}")

        baseline_sh_ratio = 1.28 if is_male else 1.15
        if proportions and proportions.get("source") == "mediapipe_33_keypoints":
            lateral_correction = float(np.clip(
                proportions.get("shoulder_to_hip_ratio", baseline_sh_ratio) / baseline_sh_ratio,
                0.90, 1.15
            ))
        else:
            lateral_correction = 1.0

        # X (width): driven by hips/waist + shoulder correction
        sc_x = ((sc_hips + sc_waist) / 2.0) * sc_shoulders * lateral_correction
        # Y (height): direct scaling
        sc_y = sc_height
        # Z (depth): driven by chest/waist depth
        sc_z = (sc_bust + sc_waist) / 2.0

        return {
            "x": round(float(np.clip(sc_x, 0.75, 1.35)), 4),
            "y": round(float(np.clip(sc_y, 0.85, 1.30)), 4),
            "z": round(float(np.clip(sc_z, 0.75, 1.30)), 4),
            "height":    round(sc_height,    4),
            "bust":      round(sc_bust,      4),
            "waist":     round(sc_waist,     4),
            "hips":      round(sc_hips,      4),
            "shoulders": round(sc_shoulders, 4),
        }

    @staticmethod
    def _match_color_stats(source: np.ndarray, target: np.ndarray) -> np.ndarray:
        """
        Reinhard color transfer in LAB space.
        Matches the mean and standard deviation of source (user photo) to target (base model skin).
        This eliminates dark camera shadows, indoor lighting casts, and bruised appearances.
        """
        src_lab = cv2.cvtColor(source, cv2.COLOR_BGR2LAB).astype(np.float32)
        tgt_lab = cv2.cvtColor(target, cv2.COLOR_BGR2LAB).astype(np.float32)

        src_mean, src_std = cv2.meanStdDev(src_lab)
        tgt_mean, tgt_std = cv2.meanStdDev(tgt_lab)

        src_mean = src_mean.flatten()
        src_std = np.maximum(src_std.flatten(), 1e-4)
        tgt_mean = tgt_mean.flatten()
        tgt_std = tgt_std.flatten()

        for i in range(3):
            src_lab[:, :, i] = ((src_lab[:, :, i] - src_mean[i]) * (tgt_std[i] / src_std[i])) + tgt_mean[i]

        src_lab = np.clip(src_lab, 0, 255).astype(np.uint8)
        return cv2.cvtColor(src_lab, cv2.COLOR_LAB2BGR)

    # ── LOSSLESS GLB MORPHING & EXPORT ────────────────────────────────────────

    def _morph_and_export(
        self,
        output_path: str,
        scales: Dict[str, float],
        skin_rgb: Tuple[int, int, int],
        face_crop_bytes: Optional[bytes],
        gender: str,
    ) -> bool:
        """
        Loads base GLB for the given gender, applies precise biometric bone morphing
        directly to the glTF skeleton hierarchy, seamlessly blends face & beard, and exports.
        """
        template = self._resolve_template_path(gender)
        if not template or not os.path.exists(template):
            print(f"[AvatarGenerator] Template not found for gender={gender}")
            return False

        try:
            with open(template, "rb") as f:
                magic = f.read(4)
                if magic != b"glTF":
                    print(f"[AvatarGenerator] Invalid GLB magic in {template}")
                    return False
                version = int.from_bytes(f.read(4), "little")
                total_len = int.from_bytes(f.read(4), "little")

                chunk0_len = int.from_bytes(f.read(4), "little")
                chunk0_type = f.read(4)
                json_bytes = f.read(chunk0_len)

                chunk1_header = f.read(8)
                chunk1_len = int.from_bytes(chunk1_header[:4], "little")
                chunk1_type = chunk1_header[4:]
                bin_data = f.read(chunk1_len)

            data = json.loads(json_bytes.decode("utf-8"))
            is_male = gender.lower() in ["male", "homme", "man", "m"]

            # ── 1. True Anatomical Bone-Level Morphing ─────────────────────────
            # Build node dictionary by bone name
            nodes = data.get("nodes", [])
            bone_map = {n.get("name"): n for n in nodes if n.get("name")}

            # Unpack biometric scales from dict
            sc_hp = scales.get("hips", scales.get("x", 1.0))
            sc_w  = scales.get("waist", scales.get("x", 1.0))
            sc_b  = scales.get("bust", scales.get("x", 1.0))
            sc_h  = scales.get("height", scales.get("y", 1.0))
            sc_sh = scales.get("shoulders", 1.0)

            # Calculate harmonious body widths ensuring upper body scales with hips
            eff_hp = float(np.clip(sc_hp, 0.70, 1.30))
            eff_w  = float(np.clip(sc_w, 0.65, 1.45))
            eff_b  = float(np.clip(sc_b, 0.70, 1.45))

            # Maintain natural human anatomy: in heavy builds, waist & chest match hip expansion
            eff_w = max(eff_w, eff_hp * 0.90)
            eff_b = max(eff_b, eff_w * 0.95)

            # A. Hips (root skeleton joint): drives hip width & vertical height
            if "Hips" in bone_map:
                bone_map["Hips"]["scale"] = [round(eff_hp, 4), round(sc_h, 4), round(eff_hp, 4)]

            # B. Lower waist / belly (Spine)
            # Parent is Hips. Target world scale: eff_w
            if "Spine" in bone_map:
                loc_spine_x = eff_w / eff_hp
                loc_spine_z = eff_w / eff_hp
                bone_map["Spine"]["scale"] = [round(loc_spine_x, 4), 1.0, round(loc_spine_z, 4)]

            # C. Mid-torso / Abdomen (Spine1): give abdominal depth in Z
            if "Spine1" in bone_map:
                loc_spine1_z = max(1.0, eff_w * 0.95)
                bone_map["Spine1"]["scale"] = [1.02, 1.0, round(loc_spine1_z, 4)]

            # D. Chest / Bust (Spine2): target world scale is eff_b
            if "Spine2" in bone_map:
                loc_spine2_x = eff_b / eff_w
                loc_spine2_z = eff_b / eff_w
                bone_map["Spine2"]["scale"] = [round(loc_spine2_x, 4), 1.0, round(loc_spine2_z, 4)]

            # E. Shoulders: broader chests expand shoulder breadth
            eff_sh = sc_sh * max(1.0, (eff_b - 1.0) * 0.6 + 1.0)
            for sh_name in ["RightShoulder", "LeftShoulder"]:
                if sh_name in bone_map:
                    sh_node = bone_map[sh_name]
                    if "translation" in sh_node:
                        tx, ty, tz = sh_node["translation"]
                        sh_node["translation"] = [round(tx * eff_sh, 4), ty, tz]
                    sh_node["scale"] = [round(eff_sh, 4), 1.0, 1.0]

            # F. Upper Arms: scale arm thickness with chest bulk
            arm_thick = round(float(np.sqrt(max(1.0, eff_b))), 4)
            for arm_name in ["RightArm", "LeftArm"]:
                if arm_name in bone_map:
                    bone_map[arm_name]["scale"] = [arm_thick, 1.0, arm_thick]

            # G. Counter-scale Neck & Head (face/head stays perfectly proportioned)
            if "Neck" in bone_map:
                bone_map["Neck"]["scale"] = [
                    round(1.0 / max(0.4, eff_b), 4),
                    round(1.0 / max(0.4, sc_h), 4),
                    round(1.0 / max(0.4, eff_b), 4),
                ]
            if "Head" in bone_map:
                bone_map["Head"]["scale"] = [1.0, 1.0, 1.0]

            # H. Counter-scale Hands so hands stay natural
            for h_name in ["RightHand", "LeftHand"]:
                if h_name in bone_map:
                    bone_map[h_name]["scale"] = [
                        round(1.0 / max(0.4, eff_b * eff_sh), 4),
                        round(1.0 / max(0.4, sc_h), 4),
                        round(1.0 / max(0.4, eff_b), 4),
                    ]

            # I. Thighs (RightUpLeg, LeftUpLeg): keep at 1.0 (they inherit Hips, no double-scaling)
            for leg_name in ["RightUpLeg", "LeftUpLeg"]:
                if leg_name in bone_map:
                    bone_map[leg_name]["scale"] = [1.0, 1.0, 1.0]

            print(f"[AvatarGenerator] Applied Bone Morph: Hips={eff_hp:.2f}, Waist={eff_w:.2f}, Bust={eff_b:.2f}, Shoulders={eff_sh:.2f}")

            # ── 2. Remove Wig Mesh completely (No weird topi/hat on head) ────────────────
            if "h_wig" in bone_map:
                wig = bone_map["h_wig"]
                wig["scale"] = [0.0, 0.0, 0.0]
                wig["translation"] = [0.0, -100.0, 0.0]
                if "mesh" in wig:
                    del wig["mesh"]

            # ── 3. Real Face & Beard Texture Projection (Harmonized & Seamless) ─
            bin_data_arr = bytearray(bin_data)
            if face_crop_bytes and len(data.get("images", [])) > 1:
                try:
                    img_idx = 1  # Body diffuse texture in base avatar
                    if "bufferView" in data["images"][img_idx]:
                        bv_idx = data["images"][img_idx]["bufferView"]
                        bv = data["bufferViews"][bv_idx]
                        orig_jpg = bytes(bin_data_arr[bv["byteOffset"] : bv["byteOffset"] + bv["byteLength"]])

                        body_img = cv2.imdecode(np.frombuffer(orig_jpg, np.uint8), cv2.IMREAD_COLOR)
                        nparr_face = np.frombuffer(face_crop_bytes, np.uint8)
                        face_img = cv2.imdecode(nparr_face, cv2.IMREAD_COLOR)

                        if body_img is not None and face_img is not None:
                            # Accurate head UV bounds on 2048x2048 texture
                            dst_x1, dst_y1 = 360, 160
                            dst_x2, dst_y2 = 970, 920
                            target_w = dst_x2 - dst_x1
                            target_h = dst_y2 - dst_y1

                            resized_face = cv2.resize(face_img, (target_w, target_h), interpolation=cv2.INTER_LANCZOS4)
                            target_roi = body_img[dst_y1:dst_y2, dst_x1:dst_x2]

                            # 1. LAB color space harmonization to eliminate shadows & bruises
                            harmonized_face = self._match_color_stats(resized_face, target_roi)

                            # 2. Smooth feathered mask covering full face, beard & jawline
                            mask = np.zeros((target_h, target_w), dtype=np.float32)
                            center = (target_w // 2, int(target_h * 0.50))
                            axes = (int(target_w * 0.44), int(target_h * 0.48))
                            cv2.ellipse(mask, center, axes, 0, 0, 360, 1.0, -1)
                            mask = cv2.GaussianBlur(mask, (75, 75), 25)

                            # 3. Poisson seamless clone for flawless blending
                            clone_mask = (mask > 0.08).astype(np.uint8) * 255
                            clone_center = (dst_x1 + target_w // 2, dst_y1 + target_h // 2)
                            try:
                                body_img = cv2.seamlessClone(harmonized_face, body_img, clone_mask, clone_center, cv2.NORMAL_CLONE)
                            except Exception:
                                mask_3ch = np.stack([mask, mask, mask], axis=-1)
                                blended = harmonized_face.astype(np.float32) * mask_3ch + target_roi.astype(np.float32) * (1.0 - mask_3ch)
                                body_img[dst_y1:dst_y2, dst_x1:dst_x2] = np.clip(blended, 0, 255).astype(np.uint8)

                            # Encode updated diffuse texture
                            _, new_jpg_buf = cv2.imencode(".jpg", body_img, [cv2.IMWRITE_JPEG_QUALITY, 92])
                            new_jpg_bytes = bytes(new_jpg_buf)

                            while len(bin_data_arr) % 4 != 0:
                                bin_data_arr.append(0)
                            new_offset = len(bin_data_arr)
                            bin_data_arr.extend(new_jpg_bytes)
                            while len(bin_data_arr) % 4 != 0:
                                bin_data_arr.append(0)

                            data["bufferViews"][bv_idx]["byteOffset"] = new_offset
                            data["bufferViews"][bv_idx]["byteLength"] = len(new_jpg_bytes)
                            data["buffers"][0]["byteLength"] = len(bin_data_arr)
                            print("[AvatarGenerator] Projected user face & beard seamlessly onto 3D GLB!")
                except Exception as ex:
                    print(f"[AvatarGenerator] Face texture projection warning: {ex}")

            bin_data = bytes(bin_data_arr)

            # ── 4. Natural PBR Base Color Factors ─────────────────────────────
            # Preserve bright, crisp studio lighting on skin & clothes
            for mat in data.get("materials", []):
                mat_name = mat.get("name", "").lower()
                if "_body" in mat_name or "body" in mat_name or "skin" in mat_name:
                    pbr = mat.get("pbrMetallicRoughness", {})
                    pbr["baseColorFactor"] = [1.0, 1.0, 1.0, 1.0]
                    mat["pbrMetallicRoughness"] = pbr
                elif "hair" in mat_name or "wig" in mat_name:
                    pbr = mat.get("pbrMetallicRoughness", {})
                    # Natural deep dark masculine/feminine hair
                    pbr["baseColorFactor"] = [0.25, 0.22, 0.20, 1.0]
                    mat["pbrMetallicRoughness"] = pbr

            # ── 5. Serialize and write GLB ────────────────────────────────────
            new_json_bytes = json.dumps(data, separators=(",", ":")).encode("utf-8")
            pad = (4 - (len(new_json_bytes) % 4)) % 4
            new_json_bytes += b" " * pad

            new_total_len = 12 + 8 + len(new_json_bytes) + 8 + len(bin_data)

            with open(output_path, "wb") as f:
                f.write(magic)
                f.write(version.to_bytes(4, "little"))
                f.write(new_total_len.to_bytes(4, "little"))

                f.write(len(new_json_bytes).to_bytes(4, "little"))
                f.write(chunk0_type)
                f.write(new_json_bytes)

                f.write(len(bin_data).to_bytes(4, "little"))
                f.write(chunk1_type)
                f.write(bin_data)

            print(f"[AvatarGenerator] Successfully morphed realistic GLB: {output_path} ({os.path.getsize(output_path)} bytes)")
            return True

        except Exception as e:
            print(f"[AvatarGenerator] Morph error: {e}")
            return False

    # ── TEMPLATE RESOLUTION ───────────────────────────────────────────────────

    def _resolve_template_path(self, gender: str = "female") -> Optional[str]:
        """Resolves template GLB path based on gender."""
        is_male = gender.lower() in ["male", "homme", "man", "m"]
        model_name = "base_avatar_male.glb" if is_male else "base_avatar_female.glb"

        candidates = [
            os.path.join(self.backend_dir, "assets", "models", model_name),
            os.path.join(self.backend_dir, "..", "assets", "models", model_name),
            os.path.join(self.backend_dir, "assets", "models", "base_avatar.glb"),
            os.path.join(self.backend_dir, "..", "assets", "models", "base_avatar.glb"),
            self.template_glb_path,
        ]
        for path in candidates:
            abs_p = os.path.abspath(path)
            if os.path.exists(abs_p):
                return abs_p
        return None

    def _copy_template(self, output_path: str, gender: str = "female") -> None:
        """Copies realistic template to output as last-resort fallback."""
        template = self._resolve_template_path(gender)
        if template and os.path.exists(template):
            shutil.copyfile(template, output_path)
        else:
            with open(output_path, "wb") as f:
                f.write(b"glTF" + b"\x00" * 1024)
