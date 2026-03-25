"""
build_db.py — Crea la base de datos SQLite con las 4 tablas del proyecto.

Tablas:
  - tiktok_videos       : métricas por vídeo de TikTok
  - tiktok_overview     : métricas globales de TikTok
  - instagram_reels     : métricas por reel de Instagram
  - instagram_daily     : métricas diarias de Instagram
"""

import sqlite3
import pandas as pd
from pathlib import Path

DATA = Path(__file__).parent.parent / "data"
DB   = Path(__file__).parent.parent / "social_media.db"

def build():
    conn = sqlite3.connect(DB)

    # TikTok videos
    tt = pd.read_csv(DATA / "videos_engagement.csv")
    tt.to_sql("tiktok_videos", conn, if_exists="replace", index=False)
    print(f"✅ tiktok_videos — {len(tt)} filas")

    # TikTok overview
    ov = pd.read_csv(DATA / "overview_metrics.csv")
    ov.to_sql("tiktok_overview", conn, if_exists="replace", index=False)
    print(f"✅ tiktok_overview — {len(ov)} filas")

    # Instagram reels
    ig = pd.read_csv(DATA / "reels_metricas.csv")
    ig.to_sql("instagram_reels", conn, if_exists="replace", index=False)
    print(f"✅ instagram_reels — {len(ig)} filas")

    # Instagram daily
    daily = pd.read_csv(DATA / "metricas_diarias.csv")
    daily.to_sql("instagram_daily", conn, if_exists="replace", index=False)
    print(f"✅ instagram_daily — {len(daily)} filas")

    conn.close()
    print(f"\n📦 Base de datos creada en: {DB}")

if __name__ == "__main__":
    build()
