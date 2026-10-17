import os
import sqlite3
import json
from typing import Optional, Dict, Any
from datetime import datetime, timezone

class DatabaseService:
    """
    Persistent SQLite storage for all 3D humanoid avatar measurements & generated models.
    Ensures measurements (height, weight, bust, waist, hips, shoulders) are permanently saved.
    """

    def __init__(self, db_path: Optional[str] = None):
        if not db_path:
            backend_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
            data_dir = os.path.join(backend_dir, "data")
            os.makedirs(data_dir, exist_ok=True)
            db_path = os.path.join(data_dir, "avatars.db")
        self.db_path = db_path
        self._init_db()

    def _get_connection(self) -> sqlite3.Connection:
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        return conn

    def _init_db(self):
        with self._get_connection() as conn:
            conn.execute("""
                CREATE TABLE IF NOT EXISTS avatars (
                    avatar_id TEXT PRIMARY KEY,
                    user_id TEXT,
                    gender TEXT,
                    height_cm REAL,
                    weight_kg REAL,
                    bust_cm REAL,
                    waist_cm REAL,
                    hips_cm REAL,
                    shoulder_type TEXT,
                    glb_url TEXT,
                    morphed INTEGER,
                    scales_json TEXT,
                    created_at TEXT
                )
            """)
            conn.commit()

    def save_avatar_record(
        self,
        avatar_id: str,
        user_id: Optional[str],
        gender: str,
        height_cm: float,
        weight_kg: Optional[float],
        bust_cm: float,
        waist_cm: float,
        hips_cm: float,
        shoulder_type: str,
        glb_url: str,
        morphed: bool,
        scales: Optional[Dict[str, Any]] = None,
        created_at: Optional[str] = None,
    ) -> bool:
        if not created_at:
            created_at = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
        scales_json = json.dumps(scales or {})

        try:
            with self._get_connection() as conn:
                conn.execute("""
                    INSERT OR REPLACE INTO avatars (
                        avatar_id, user_id, gender, height_cm, weight_kg,
                        bust_cm, waist_cm, hips_cm, shoulder_type, glb_url,
                        morphed, scales_json, created_at
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """, (
                    avatar_id, user_id, gender, height_cm, weight_kg,
                    bust_cm, waist_cm, hips_cm, shoulder_type, glb_url,
                    1 if morphed else 0, scales_json, created_at
                ))
                conn.commit()
            print(f"[DatabaseService] Saved avatar {avatar_id} for user {user_id} (h={height_cm}, w={weight_kg}, bust={bust_cm}, waist={waist_cm}, hips={hips_cm})")
            return True
        except Exception as e:
            print(f"[DatabaseService] Error saving avatar record: {e}")
            return False

    def get_latest_avatar(self, user_id: Optional[str] = None) -> Optional[Dict[str, Any]]:
        try:
            with self._get_connection() as conn:
                if user_id:
                    cursor = conn.execute(
                        "SELECT * FROM avatars WHERE user_id = ? ORDER BY created_at DESC LIMIT 1",
                        (user_id,)
                    )
                else:
                    cursor = conn.execute(
                        "SELECT * FROM avatars ORDER BY created_at DESC LIMIT 1"
                    )
                row = cursor.fetchone()
                if row:
                    return dict(row)
                return None
        except Exception as e:
            print(f"[DatabaseService] Error fetching latest avatar: {e}")
            return None
