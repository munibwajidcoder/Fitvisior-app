from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional
from services.push_notification_service import PushNotificationService

router = APIRouter(prefix="/v1/notifications", tags=["Push Notifications & DB Sync"])
push_service = PushNotificationService()

class NotificationTriggerRequest(BaseModel):
    user_id: str
    title_en: str
    title_fr: Optional[str] = None
    body_en: str
    body_fr: Optional[str] = None
    category: Optional[str] = "system"
    lang: Optional[str] = "en"
    badge_count: Optional[int] = 1
    fcm_token: Optional[str] = None
    action_route: Optional[str] = "/home"

class WelcomeNotificationRequest(BaseModel):
    user_id: str
    lang: Optional[str] = "en"
    fcm_token: Optional[str] = None

class MarkReadRequest(BaseModel):
    notification_id: str

@router.post("/trigger")
async def trigger_notification(payload: NotificationTriggerRequest):
    """
    Trigger real production push notification to user device (Android & iOS)
    with bilingual support (en/fr) and sync to Supabase DB table
    """
    title_fr = payload.title_fr or payload.title_en
    body_fr = payload.body_fr or payload.body_en
    result = push_service.notify_user(
        user_id=payload.user_id,
        title_en=payload.title_en,
        title_fr=title_fr,
        body_en=payload.body_en,
        body_fr=body_fr,
        category=payload.category or "system",
        lang=payload.lang or "en",
        badge_count=payload.badge_count or 1,
        fcm_token=payload.fcm_token
    )
    return {
        "status": "success",
        "result": result
    }

@router.post("/welcome")
async def trigger_welcome(payload: WelcomeNotificationRequest):
    """
    Triggers Welcome push notification in selected language (en / fr) and saves to database
    """
    title_en = "Welcome to FitVisor! 🎉"
    title_fr = "Bienvenue sur FitVisor ! 🎉"
    body_en = "Your virtual 3D styling studio is calibrated. Explore your wardrobe and 3D outfit combinations."
    body_fr = "Votre studio de style 3D virtuel est calibré. Explorez votre dressing et vos tenues 3D."

    result = push_service.notify_user(
        user_id=payload.user_id,
        title_en=title_en,
        title_fr=title_fr,
        body_en=body_en,
        body_fr=body_fr,
        category="system",
        lang=payload.lang or "en",
        badge_count=1,
        fcm_token=payload.fcm_token
    )
    return {
        "status": "success",
        "result": result
    }

@router.post("/mark-read")
async def mark_notification_read(payload: MarkReadRequest):
    """
    Updates notification in DB to is_read=True and sets read_at timestamp
    """
    result = push_service.mark_as_read(payload.notification_id)
    return {
        "status": "success" if result.get("success") else "error",
        "result": result
    }
