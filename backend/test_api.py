import os
import sys

# Ensure backend directory is in path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "online"
    print("[OK] Health check passed:", data)

def test_reconstruct_avatar():
    # Test reconstruction with biometrics
    form_data = {
        "gender": "female",
        "height_cm": "174.0",
        "bust_cm": "86.0",
        "waist_cm": "66.0",
        "hips_cm": "94.0",
        "shoulder_type": "Classique"
    }
    response = client.post("/v1/avatar/reconstruct", data=form_data)
    assert response.status_code == 200, f"Error: {response.text}"
    data = response.json()
    assert data["status"] == "success"
    assert "avatar" in data
    assert data["avatar"]["height_cm"] == 174.0
    assert data["avatar"]["glb_url"] != ""
    print("[OK] Reconstruct avatar passed:", data["avatar"]["avatar_id"], "-> GLB:", data["avatar"]["glb_url"])

def test_reconstruct_heavy_avatar():
    # Test heavy male avatar with 110kg weight
    form_data = {
        "gender": "male",
        "height_cm": "180.0",
        "weight_kg": "110.0",
        "bust_cm": "115.0",
        "waist_cm": "108.0",
        "hips_cm": "116.0",
        "shoulder_type": "Larges"
    }
    response = client.post("/v1/avatar/reconstruct", data=form_data)
    assert response.status_code == 200, f"Error: {response.text}"
    data = response.json()
    assert data["status"] == "success"
    print("[OK] Heavy (110kg) Reconstruct avatar passed:", data["avatar"]["avatar_id"], "-> GLB:", data["avatar"]["glb_url"])

def test_pipeline_health():
    response = client.get("/v1/avatar/health")
    assert response.status_code == 200
    data = response.json()
    print("[OK] Pipeline health:", data)

def test_reconstruct_avatar_with_photos():
    test_img = r"C:\Users\New Rohaan Computers\.gemini\antigravity-ide\brain\9ac46fea-5922-4953-98b1-8ee6da81fec6\scan_front_pose_1790859195636.jpg"
    form_data = {
        "gender": "female",
        "height_cm": "174.0",
        "bust_cm": "86.0",
        "waist_cm": "66.0",
        "hips_cm": "94.0",
        "shoulder_type": "Classique"
    }
    with open(test_img, "rb") as f:
        files = {
            "front_image": ("front.jpg", f.read(), "image/jpeg")
        }
    response = client.post("/v1/avatar/reconstruct", data=form_data, files=files)
    assert response.status_code == 200, f"Error: {response.text}"
    data = response.json()
    assert data["status"] == "success"
    assert "MediaPipe: ✓" in data["message"]
    assert "UV Texture: ✓" in data["message"]
    print("[OK] Full Photo Reconstruct passed:", data["avatar"]["avatar_id"], "-> GLB:", data["avatar"]["glb_url"])
    print("    Message:", data["message"])
    print("    Time:", data["processing_time_sec"], "s")

if __name__ == "__main__":
    print("Running backend tests...")
    test_health()
    test_pipeline_health()
    test_reconstruct_avatar()
    test_reconstruct_heavy_avatar()
    test_reconstruct_avatar_with_photos()
    print("\n>>> All DresKode Phase 3 Backend Pipeline Tests PASSED 100%! <<<")

