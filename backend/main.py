import os
import sys

# Ensure current backend directory is in sys.path
backend_dir = os.path.dirname(os.path.abspath(__file__))
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from routers.avatar_router import router as avatar_router

app = FastAPI(
    title="DresKode 3D Avatar & Virtual Try-On AI Engine",
    description="High-precision 3D Humanoid Body Morphing and Reconstruction API (DresKode Specifications)",
    version="1.0.0"
)

# Enable CORS for Flutter Web, iOS, and Android
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Static directory for serving generated 3D GLB assets
static_dir = os.path.join(os.path.dirname(__file__), "static")
os.makedirs(os.path.join(static_dir, "avatars"), exist_ok=True)
app.mount("/static", StaticFiles(directory=static_dir), name="static")

# Mount API Routers
app.include_router(avatar_router)

@app.get("/health", tags=["Health"])
async def health_check():
    return {
        "status": "online",
        "service": "DresKode 3D Avatar Reconstruction Backend",
        "engine": "FastAPI + WebGL GLB Pipeline",
        "version": "1.0.0"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
