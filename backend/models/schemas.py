from pydantic import BaseModel, Field
from typing import Optional, Dict, Any

class BiometricInputs(BaseModel):
    gender: str = Field(default="female", description="Gender for base mesh morphology ('female' or 'male')")
    height_cm: float = Field(default=174.0, ge=100.0, le=240.0, description="Total height in cm")
    bust_cm: float = Field(default=86.0, ge=50.0, le=180.0, description="Bust / Chest circumference in cm")
    waist_cm: float = Field(default=66.0, ge=40.0, le=160.0, description="Waist circumference in cm")
    hips_cm: float = Field(default=94.0, ge=50.0, le=180.0, description="Hips circumference in cm")
    shoulder_type: str = Field(default="Classique", description="Shoulder slope/width: 'Minces', 'Classique', 'Larges'")

class AvatarMetadata(BaseModel):
    avatar_id: str
    user_id: Optional[str] = None
    gender: str
    height_cm: float
    bust_cm: float
    waist_cm: float
    hips_cm: float
    shoulder_type: str
    glb_url: str
    texture_url: Optional[str] = None
    created_at: str

class AvatarReconstructResponse(BaseModel):
    status: str = "success"
    message: str = "Avatar 3D généré avec succès"
    avatar: AvatarMetadata
    processing_time_sec: float
