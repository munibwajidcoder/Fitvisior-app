import os
from typing import Optional
from dotenv import load_dotenv

load_dotenv()

class StorageService:
    """
    Manages storing 3D avatar GLB files in Supabase Storage or serving via local static URLs.
    """

    def __init__(self):
        self.supabase_url = os.getenv("SUPABASE_URL")
        self.service_role_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
        self.bucket_name = "avatars"
        self._client = None

        if self.supabase_url and self.service_role_key:
            try:
                from supabase import create_client
                self._client = create_client(self.supabase_url, self.service_role_key)
            except Exception:
                self._client = None

    def upload_glb(self, file_path: str, destination_name: str, base_server_url: str = "http://localhost:8000") -> str:
        """
        Uploads GLB file to Supabase Storage if available.
        Otherwise falls back to returning the server's static URL.
        """
        if self._client and os.path.exists(file_path):
            try:
                with open(file_path, "rb") as f:
                    file_bytes = f.read()

                # Upload to Supabase bucket 'avatars'
                self._client.storage.from_(self.bucket_name).upload(
                    path=destination_name,
                    file=file_bytes,
                    file_options={"content-type": "model/gltf-binary", "upsert": "true"}
                )

                # Get public URL
                public_url = self._client.storage.from_(self.bucket_name).get_public_url(destination_name)
                if public_url:
                    print(f"[StorageService] Successfully uploaded GLB to Supabase Storage: {public_url}")
                    return public_url
            except Exception as e:
                print(f"[StorageService] Supabase upload warning: {e}")

        # Fallback to local static file URL
        fallback_url = f"{base_server_url}/static/avatars/{destination_name}"
        print(f"[StorageService] Serving GLB via local server URL: {fallback_url}")
        return fallback_url
