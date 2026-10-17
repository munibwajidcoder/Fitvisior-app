"""
DresKode Phase 3 — Stage 1: Landmark & Contour Extraction
Technology: MediaPipe Pose (33 3D keypoints via Tasks API / Legacy Solutions) + OpenCV body segmentation
"""

import os
import cv2
import numpy as np
from typing import Dict, Any, Tuple, Optional, List

# Cache detector
_pose_detector_info = None


def _resolve_model_path() -> Optional[str]:
    candidates = [
        os.path.join(os.path.dirname(__file__), "..", "models", "pose_landmarker_full.task"),
        os.path.join("models", "pose_landmarker_full.task"),
        os.path.join("backend", "models", "pose_landmarker_full.task"),
    ]
    for c in candidates:
        if os.path.exists(c):
            return os.path.abspath(c)
    return None


def _get_pose_detector():
    """
    Returns tuple (mode, detector_instance) or None.
    Supports MediaPipe Tasks API (v1.0+) with fallback to Solutions API.
    """
    global _pose_detector_info
    if _pose_detector_info is not None:
        return _pose_detector_info if _pose_detector_info is not False else None

    # Strategy 1: MediaPipe Tasks API (MediaPipe 0.10+ / 1.0+)
    try:
        import mediapipe as mp
        from mediapipe.tasks import python
        from mediapipe.tasks.python import vision

        model_path = _resolve_model_path()
        if model_path and os.path.exists(model_path):
            base_options = python.BaseOptions(model_asset_path=model_path)
            options = vision.PoseLandmarkerOptions(
                base_options=base_options,
                output_segmentation_masks=True
            )
            detector = vision.PoseLandmarker.create_from_options(options)
            _pose_detector_info = ("tasks", detector)
            return _pose_detector_info
    except Exception as e:
        print(f"[LandmarkExtractor] MediaPipe Tasks init notice: {e}")

    # Strategy 2: Legacy MediaPipe Solutions API (mediapipe < 0.10)
    try:
        import mediapipe as mp
        if hasattr(mp, "solutions") and hasattr(mp.solutions, "pose"):
            _pose_detector_info = ("solutions", mp.solutions.pose)
            return _pose_detector_info
    except Exception:
        pass

    _pose_detector_info = False
    return None


class LandmarkExtractor:
    """
    Stage 1 of the DresKode 3D Avatar Pipeline.

    Responsibilities:
    1. Sample skin tone from the face/neck region (OpenCV)
    2. Extract 33 3D world-landmark keypoints using MediaPipe Pose
    3. Estimate body silhouette proportions from the front photo contour
    4. Compute biometric scaling ratios (pixel -> centimetre)
    """

    # -- PUBLIC API ------------------------------------------------------------

    @staticmethod
    def sample_skin_tone(image_bytes: bytes) -> Tuple[int, int, int]:
        """
        Samples average skin tone from the upper-centre quadrant (face/neck region).
        Returns (R, G, B).
        """
        try:
            nparr = np.frombuffer(image_bytes, np.uint8)
            img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            if img is None:
                return (235, 195, 175)

            h, w, _ = img.shape
            # Focus on the upper 15-35 % of the frame, centre 30 % width (face/neck)
            y1, y2 = int(h * 0.15), int(h * 0.35)
            x1, x2 = int(w * 0.35), int(w * 0.65)
            roi = img[y1:y2, x1:x2]

            if roi.size == 0:
                return (235, 195, 175)

            roi_rgb = cv2.cvtColor(roi, cv2.COLOR_BGR2RGB)

            # Filter out very dark (hair/shadows) or overexposed pixels
            mask = (
                (roi_rgb[:, :, 0] > 60) & (roi_rgb[:, :, 0] < 245) &
                (roi_rgb[:, :, 1] > 40) & (roi_rgb[:, :, 1] < 245) &
                (roi_rgb[:, :, 2] > 30) & (roi_rgb[:, :, 2] < 240)
            )
            filtered = roi_rgb[mask]

            if len(filtered) > 100:
                median = np.median(filtered, axis=0).astype(int)
                return (int(median[0]), int(median[1]), int(median[2]))

            mean = np.mean(roi_rgb, axis=(0, 1)).astype(int)
            return (int(mean[0]), int(mean[1]), int(mean[2]))

        except Exception:
            return (230, 190, 170)

    @staticmethod
    def extract_33_keypoints(image_bytes: bytes) -> Optional[Dict[str, Any]]:
        """
        Runs MediaPipe Pose on the image and returns:
        - world_landmarks: list of 33 dicts {x, y, z, visibility} in metres
        - image_landmarks: list of 33 dicts {x, y, z} in normalised image coords
        Returns None if MediaPipe unavailable or pose not detected.
        """
        detector_info = _get_pose_detector()
        if not detector_info:
            return None

        try:
            nparr = np.frombuffer(image_bytes, np.uint8)
            img_bgr = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            if img_bgr is None:
                return None

            img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
            mode, detector = detector_info

            if mode == "tasks":
                import mediapipe as mp
                mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=img_rgb)
                results = detector.detect(mp_image)

                if not results.pose_landmarks or len(results.pose_landmarks) == 0:
                    return None

                raw_image_lm = results.pose_landmarks[0]
                raw_world_lm = results.pose_world_landmarks[0] if results.pose_world_landmarks else raw_image_lm

                world_lm = [
                    {
                        "x": float(lm.x),
                        "y": float(lm.y),
                        "z": float(lm.z),
                        "visibility": float(getattr(lm, "visibility", 1.0))
                    }
                    for lm in raw_world_lm
                ]

                image_lm = [
                    {
                        "x": float(lm.x),
                        "y": float(lm.y),
                        "z": float(lm.z)
                    }
                    for lm in raw_image_lm
                ]

                seg_mask = None
                if results.segmentation_masks and len(results.segmentation_masks) > 0:
                    mask_np = results.segmentation_masks[0].numpy_view()
                    seg_mask = (mask_np > 0.5).tolist()

                return {
                    "world_landmarks": world_lm,       # 33 points in metres
                    "image_landmarks": image_lm,       # 33 points, normalised 0-1
                    "segmentation_mask": seg_mask,
                    "image_shape": list(img_bgr.shape[:2])  # [H, W]
                }

            elif mode == "solutions":
                with detector.Pose(
                    static_image_mode=True,
                    model_complexity=2,
                    enable_segmentation=True,
                    min_detection_confidence=0.5
                ) as pose:
                    results = pose.process(img_rgb)

                if not results.pose_world_landmarks:
                    return None

                world_lm = [
                    {
                        "x": float(lm.x),
                        "y": float(lm.y),
                        "z": float(lm.z),
                        "visibility": float(lm.visibility)
                    }
                    for lm in results.pose_world_landmarks.landmark
                ]

                image_lm = [
                    {
                        "x": float(lm.x),
                        "y": float(lm.y),
                        "z": float(lm.z)
                    }
                    for lm in results.pose_landmarks.landmark
                ]

                seg_mask = None
                if results.segmentation_mask is not None:
                    seg_mask = (results.segmentation_mask > 0.5).tolist()

                return {
                    "world_landmarks": world_lm,
                    "image_landmarks": image_lm,
                    "segmentation_mask": seg_mask,
                    "image_shape": list(img_bgr.shape[:2])
                }

        except Exception as e:
            print(f"[LandmarkExtractor] MediaPipe error: {e}")
            return None

    @staticmethod
    def compute_body_proportions(
        keypoint_data: Optional[Dict[str, Any]],
        height_cm: float,
        front_image_bytes: Optional[bytes] = None
    ) -> Dict[str, Any]:
        """
        Stage 1 output: biometric scaling ratios derived from the 33 landmarks.

        MediaPipe world coords are already in metres, centred at the pelvis.
        We use key landmark pairs to compute anatomical distances and
        then scale them to the user's declared height.

        MediaPipe landmark indices (POSE_LANDMARKS):
          0  = nose           11 = left_shoulder   12 = right_shoulder
          13 = left_elbow     14 = right_elbow      23 = left_hip
          24 = right_hip      25 = left_knee        26 = right_knee
          27 = left_ankle     28 = right_ankle
        """
        defaults = _default_proportions()

        if keypoint_data is None:
            # Fallback: silhouette-based estimate from OpenCV contour
            if front_image_bytes:
                return _contour_proportions(front_image_bytes, height_cm)
            return defaults

        wlm = keypoint_data.get("world_landmarks", [])
        if len(wlm) < 29:
            return defaults

        def dist3d(a: int, b: int) -> float:
            """Euclidean distance between landmark indices a and b (metres)."""
            pa, pb = wlm[a], wlm[b]
            return float(np.sqrt(
                (pa["x"] - pb["x"]) ** 2 +
                (pa["y"] - pb["y"]) ** 2 +
                (pa["z"] - pb["z"]) ** 2
            ))

        def midpoint(a: int, b: int) -> Dict[str, float]:
            return {
                "x": (wlm[a]["x"] + wlm[b]["x"]) / 2,
                "y": (wlm[a]["y"] + wlm[b]["y"]) / 2,
                "z": (wlm[a]["z"] + wlm[b]["z"]) / 2,
            }

        try:
            # -- Anatomical distances in metres ----------------------------
            shoulder_width_m = dist3d(11, 12)           # L-shoulder <-> R-shoulder
            hip_width_m      = dist3d(23, 24)           # L-hip      <-> R-hip

            # Torso height: mid-shoulder -> mid-hip
            mid_shoulder = midpoint(11, 12)
            mid_hip      = midpoint(23, 24)
            torso_m = float(np.sqrt(
                (mid_shoulder["x"] - mid_hip["x"]) ** 2 +
                (mid_shoulder["y"] - mid_hip["y"]) ** 2 +
                (mid_shoulder["z"] - mid_hip["z"]) ** 2
            ))

            # Leg length: mid-hip -> mid-ankle
            mid_ankle = midpoint(27, 28)
            leg_m = float(np.sqrt(
                (mid_hip["x"] - mid_ankle["x"]) ** 2 +
                (mid_hip["y"] - mid_ankle["y"]) ** 2 +
                (mid_hip["z"] - mid_ankle["z"]) ** 2
            ))

            # -- Pixel-to-cm scale factor ----------------------------------
            measured_total_m = torso_m + leg_m + 0.25   # +0.25 m head estimate
            scale_m_to_cm = height_cm / (measured_total_m * 100) if measured_total_m > 0 else 1.0

            shoulder_width_cm = shoulder_width_m * 100 * scale_m_to_cm
            hip_width_cm      = hip_width_m * 100 * scale_m_to_cm
            torso_cm          = torso_m * 100 * scale_m_to_cm
            leg_cm            = leg_m   * 100 * scale_m_to_cm

            # -- Derived ratios ---------------------------------------------
            shoulder_to_hip = float(np.clip(
                shoulder_width_cm / hip_width_cm if hip_width_cm > 0 else 1.15,
                0.80, 1.50
            ))
            waist_to_hip = 0.72

            leg_to_height = float(np.clip(
                leg_cm / height_cm if height_cm > 0 else 0.48,
                0.40, 0.56
            ))

            return {
                "shoulder_to_hip_ratio":  shoulder_to_hip,
                "waist_to_hip_ratio":     waist_to_hip,
                "leg_to_height_ratio":    leg_to_height,
                "shoulder_width_cm":      round(shoulder_width_cm, 2),
                "hip_width_cm":           round(hip_width_cm, 2),
                "torso_cm":               round(torso_cm, 2),
                "leg_cm":                 round(leg_cm, 2),
                "scale_m_to_cm":          round(scale_m_to_cm, 4),
                "source":                 "mediapipe_33_keypoints"
            }

        except Exception as e:
            print(f"[LandmarkExtractor] Proportion calculation error: {e}")
            return defaults

    @staticmethod
    def crop_face_region(image_bytes: bytes) -> Optional[bytes]:
        """
        Crops the face region from the front photo using MediaPipe landmarks.
        Returns JPEG bytes of the face crop, or None if detection fails.
        Used in Stage 3 for UV face texture projection.
        """
        detector_info = _get_pose_detector()
        if not detector_info:
            return _fallback_face_crop(image_bytes)

        try:
            nparr = np.frombuffer(image_bytes, np.uint8)
            img_bgr = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            if img_bgr is None:
                return None

            h, w = img_bgr.shape[:2]
            img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
            mode, detector = detector_info

            lm = None
            if mode == "tasks":
                import mediapipe as mp
                mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=img_rgb)
                results = detector.detect(mp_image)
                if results.pose_landmarks and len(results.pose_landmarks) > 0:
                    lm = results.pose_landmarks[0]
            elif mode == "solutions":
                with detector.Pose(
                    static_image_mode=True,
                    model_complexity=1,
                    min_detection_confidence=0.4
                ) as pose:
                    results = pose.process(img_rgb)
                if results.pose_landmarks:
                    lm = results.pose_landmarks.landmark

            if not lm or len(lm) < 13:
                return _fallback_face_crop(image_bytes)

            # Facial landmarks: Nose=0, Left Eye=2, Right Eye=5, Left Mouth=9, Right Mouth=10
            nose = lm[0]
            eye_l = lm[2]
            eye_r = lm[5]
            mouth_l = lm[9]
            mouth_r = lm[10]

            eye_y = (eye_l.y + eye_r.y) / 2.0 * h
            eye_x = (eye_l.x + eye_r.x) / 2.0 * w
            mouth_y = (mouth_l.y + mouth_r.y) / 2.0 * h
            nose_x = nose.x * w

            face_height = max(20.0, mouth_y - eye_y)
            chin_y = mouth_y + 1.65 * face_height  # Capture full chin & beard
            forehead_y = eye_y - 1.25 * face_height # Capture full forehead & hairline

            eye_dist = max(20.0, abs(eye_r.x - eye_l.x) * w)
            face_width = max(eye_dist * 2.5, face_height * 2.1) # Capture cheeks, jawline & temples

            center_x = (eye_x + nose_x) / 2.0
            x1 = int(max(0, center_x - face_width / 2.0))
            x2 = int(min(w, center_x + face_width / 2.0))
            y1 = int(max(0, forehead_y))
            y2 = int(min(h, chin_y))

            face_crop = img_bgr[y1:y2, x1:x2]
            if face_crop.size == 0:
                return _fallback_face_crop(image_bytes)

            _, buf = cv2.imencode(".jpg", face_crop, [cv2.IMWRITE_JPEG_QUALITY, 92])
            return bytes(buf)

        except Exception:
            return _fallback_face_crop(image_bytes)


# -- INTERNAL HELPERS ----------------------------------------------------------

def _default_proportions() -> Dict[str, Any]:
    """DresKode reference proportions (174 cm female baseline)."""
    return {
        "shoulder_to_hip_ratio":  1.15,
        "waist_to_hip_ratio":     0.72,
        "leg_to_height_ratio":    0.48,
        "shoulder_width_cm":      38.0,
        "hip_width_cm":           33.0,
        "torso_cm":               55.0,
        "leg_cm":                 83.0,
        "scale_m_to_cm":          1.0,
        "source":                 "default_baseline"
    }


def _contour_proportions(image_bytes: bytes, height_cm: float) -> Dict[str, Any]:
    """
    Fallback silhouette analysis using OpenCV Otsu thresholding.
    """
    defaults = _default_proportions()
    defaults["source"] = "opencv_contour_fallback"

    try:
        nparr = np.frombuffer(image_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_GRAYSCALE)
        if img is None:
            return defaults

        _, thresh = cv2.threshold(img, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)
        contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        if not contours:
            return defaults

        largest = max(contours, key=cv2.contourArea)
        _, _, cw, ch = cv2.boundingRect(largest)

        aspect = cw / float(ch) if ch > 0 else 0.35
        shoulder_to_hip = float(np.clip(aspect * 3.2, 0.90, 1.35))

        return {
            **defaults,
            "shoulder_to_hip_ratio": shoulder_to_hip,
            "source": "opencv_contour_fallback"
        }

    except Exception:
        return defaults


def _fallback_face_crop(image_bytes: bytes) -> Optional[bytes]:
    """
    Fallback: crops the top 25 % centre of the image as an approximate face region.
    """
    try:
        nparr = np.frombuffer(image_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        if img is None:
            return None
        h, w = img.shape[:2]
        y2 = int(h * 0.30)
        x1, x2 = int(w * 0.25), int(w * 0.75)
        crop = img[0:y2, x1:x2]
        _, buf = cv2.imencode(".jpg", crop, [cv2.IMWRITE_JPEG_QUALITY, 88])
        return bytes(buf)
    except Exception:
        return None
