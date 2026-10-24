import os
import uuid
from datetime import datetime, timezone
from typing import Optional, Dict, Any
import firebase_admin
from firebase_admin import credentials, messaging
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv()

class PushNotificationService:
    """
    Production-grade Push Notification & Database Sync Service
    Sends high-priority FCM Push Notifications to Android & iOS devices
    with bilingual support (English / French), badge counts, and Supabase DB sync.
    """
    def __init__(self):
        self.supabase_url = os.environ.get("SUPABASE_URL", "https://oifklsdxmpmdfbnaazso.supabase.co")
        self.supabase_service_key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY", "")
        self.supabase: Client = create_client(self.supabase_url, self.supabase_service_key)
        self._init_firebase()

    def _init_firebase(self):
        if not firebase_admin._apps:
            try:
                base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
                sa_path = os.path.join(base_dir, "firebase_service_account.json")
                if os.path.exists(sa_path):
                    cred = credentials.Certificate(sa_path)
                    firebase_admin.initialize_app(cred)
                    print("[PushNotificationService] Firebase Admin SDK initialized with Service Account Key!")
                else:
                    firebase_admin.initialize_app(options={'projectId': "fitvisor-24396"})
                    print("[PushNotificationService] Firebase Admin SDK initialized with project ID.")
            except Exception as e:
                print(f"[PushNotificationService] Firebase Admin init notice: {e}")

    def send_push_notification(
        self,
        token: str,
        title: str,
        body: str,
        badge_count: int = 1,
        data: Optional[Dict[str, str]] = None
    ) -> Dict[str, Any]:
        """
        Sends high-priority FCM push notification directly to Android & iOS devices.
        Triggers heads-up banner, sound, vibration, status bar icon, and launcher badge.
        """
        try:
            str_data = dict(data) if data else {}
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                android=messaging.AndroidConfig(
                    priority='high',
                    notification=messaging.AndroidNotification(
                        sound='default',
                        channel_id='fitvisor_high_importance_channel',
                        priority='max',
                        default_sound=True,
                        default_vibrate_timings=True,
                        notification_count=badge_count,
                    ),
                ),
                apns=messaging.APNSConfig(
                    headers={'apns-priority': '10'},
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(
                            sound='default',
                            badge=badge_count,
                            content_available=True,
                        )
                    )
                ),
                data=str_data,
                token=token,
            )
            response = messaging.send(message)
            print(f"[PushNotificationService] Successfully sent FCM push to {token[:15]}... Message ID: {response}")
            return {"success": True, "message_id": response}
        except Exception as e:
            print(f"[PushNotificationService] FCM delivery error: {e}")
            return {"success": False, "error": str(e)}

    def record_notification_in_db(
        self,
        user_id: str,
        title_en: str,
        title_fr: str,
        body_en: str,
        body_fr: str,
        category: str = "system",
        action_route: str = "/home"
    ) -> Dict[str, Any]:
        """
        Inserts bilingual notification record into Supabase notifications table with UUID id.
        """
        notif_id = str(uuid.uuid4())
        payload = {
            "id": notif_id,
            "user_id": user_id,
            "title_en": title_en,
            "title_fr": title_fr,
            "body_en": body_en,
            "body_fr": body_fr,
            "category": category,
            "image_url": "assets/images/logo.png",
            "action_route": action_route,
            "is_read": False,
            "read_at": None,
            "created_at": datetime.now(timezone.utc).isoformat(),
        }
        try:
            self.supabase.table("notifications").upsert(payload).execute()
            print(f"[PushNotificationService] Recorded notification in Supabase table: {notif_id}")
            return {"success": True, "record": payload}
        except Exception as e:
            print(f"[PushNotificationService] Supabase record notice: {e}")
            return {"success": False, "error": str(e)}

    def mark_as_read(self, notification_id: str) -> Dict[str, Any]:
        """
        Marks notification as read in database and sets exact read_at timestamp
        """
        now_iso = datetime.now(timezone.utc).isoformat()
        try:
            self.supabase.table("notifications").update({
                "is_read": True,
                "read_at": now_iso
            }).eq("id", notification_id).execute()
            return {"success": True, "read_at": now_iso}
        except Exception as e:
            return {"success": False, "error": str(e)}

    def notify_user(
        self,
        user_id: str,
        title_en: str,
        title_fr: str,
        body_en: str,
        body_fr: str,
        category: str = "system",
        lang: str = "en",
        badge_count: int = 1,
        fcm_token: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Complete end-to-end user notification:
        1. Records bilingual content in Supabase DB table
        2. Sends FCM push notification to device in selected language (en / fr) with badge count
        """
        # Save bilingual row to DB table
        db_res = self.record_notification_in_db(
            user_id=user_id,
            title_en=title_en,
            title_fr=title_fr,
            body_en=body_en,
            body_fr=body_fr,
            category=category
        )

        # Send FCM if token available
        fcm_res = None
        target_token = fcm_token
        if not target_token:
            try:
                user_info = self.supabase.auth.admin.get_user_by_id(user_id)
                target_token = user_info.user.user_metadata.get("fcm_token")
            except Exception:
                pass

        if target_token:
            display_title = title_fr if lang == "fr" else title_en
            display_body = body_fr if lang == "fr" else body_en
            fcm_res = self.send_push_notification(
                token=target_token,
                title=display_title,
                body=display_body,
                badge_count=badge_count,
                data={
                    "category": category,
                    "lang": lang,
                    "notification_id": db_res.get("record", {}).get("id", "")
                }
            )

        return {
            "db_saved": db_res.get("success", False),
            "fcm_delivered": fcm_res.get("success", False) if fcm_res else False,
            "notification_id": db_res.get("record", {}).get("id")
        }
