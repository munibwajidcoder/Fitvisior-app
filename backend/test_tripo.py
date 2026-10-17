import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from services.tripo_service import Tripo3DService

svc = Tripo3DService()
bal = svc.check_balance()
print("Tripo3D Account Balance:", bal)

# Test upload with a small jpg
sample_photo = os.path.join(os.path.dirname(__file__), "assets", "test_user_front.jpg")
if os.path.exists(sample_photo):
    with open(sample_photo, "rb") as f:
        data = f.read()
    token = svc.upload_image(data)
    print("Uploaded photo token:", token)
else:
    print("test_user_front.jpg not found, testing with raw bytes")
