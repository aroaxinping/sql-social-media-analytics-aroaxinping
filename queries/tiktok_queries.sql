-- ============================================================
-- TikTok Analytics — Queries SQL
-- Base de datos: social_media.db / tabla: tiktok_videos
-- Periodo: 24 Feb - 24 Mar 2026
-- ============================================================


-- 1. Resumen global del periodo
SELECT
    COUNT(*)                            AS total_videos,
    SUM(views)                          AS total_vistas,
    ROUND(AVG(views), 0)                AS vistas_medias,
    ROUND(AVG(engagement_rate_pct), 2)  AS er_medio,
    ROUND(AVG(completion_pct), 2)       AS completion_medio,
    SUM(new_followers)                  AS seguidores_ganados,
    MAX(views)                          AS video_mas_viral,
    MIN(views)                          AS video_menos_visto
FROM tiktok_videos;


-- 2. Ranking de videos por vistas, con gap respecto al anterior (LAG)
SELECT
    title,
    published_date,
    views,
    engagement_rate_pct,
    completion_pct,
    RANK() OVER (ORDER BY views DESC)               AS rank_vistas,
    RANK() OVER (ORDER BY engagement_rate_pct DESC) AS rank_er,
    views - LAG(views) OVER (ORDER BY views DESC)   AS gap_vs_anterior
FROM tiktok_videos
ORDER BY rank_vistas;


-- 3. Relacion entre duracion del video y completion rate
SELECT
    title,
    duration_sec,
    views,
    completion_pct,
    engagement_rate_pct,
    CASE
        WHEN duration_sec <= 15 THEN 'Corto (<=15s)'
        WHEN duration_sec <= 30 THEN 'Medio (16-30s)'
        ELSE 'Largo (>30s)'
    END AS categoria_duracion
FROM tiktok_videos
ORDER BY completion_pct DESC;


-- 4. Eficiencia de conversion: vistas a seguidores por video
SELECT
    title,
    views,
    new_followers,
    ROUND(CAST(new_followers AS FLOAT) / NULLIF(views, 0) * 1000, 4) AS seguidores_por_1k_vistas,
    ROUND(CAST(new_followers AS FLOAT) / NULLIF(views, 0) * 1000, 4) -
        AVG(CAST(new_followers AS FLOAT) / NULLIF(views, 0) * 1000) OVER ()
        AS diferencia_vs_media
FROM tiktok_videos
ORDER BY seguidores_por_1k_vistas DESC;


-- 5. Videos por encima de la media en vistas Y engagement a la vez
SELECT
    title,
    published_date,
    views,
    engagement_rate_pct,
    virality_score
FROM tiktok_videos
WHERE views > (SELECT AVG(views) FROM tiktok_videos)
  AND engagement_rate_pct > (SELECT AVG(engagement_rate_pct) FROM tiktok_videos)
ORDER BY virality_score DESC;


-- 6. Comparar cada video con la media global (desviacion)
SELECT
    title,
    views,
    engagement_rate_pct,
    ROUND(AVG(views) OVER (), 0)                          AS media_vistas,
    ROUND(views - AVG(views) OVER (), 0)                  AS desviacion_vistas,
    ROUND(AVG(engagement_rate_pct) OVER (), 2)            AS media_er,
    ROUND(engagement_rate_pct - AVG(engagement_rate_pct) OVER (), 2) AS desviacion_er
FROM tiktok_videos
ORDER BY desviacion_er DESC;


-- 7. Acumulado de seguidores ganados por orden de publicacion
SELECT
    title,
    published_date,
    new_followers,
    SUM(new_followers) OVER (ORDER BY published_date)  AS seguidores_acumulados,
    SUM(views) OVER (ORDER BY published_date)          AS vistas_acumuladas
FROM tiktok_videos
ORDER BY published_date;


-- 8. Metricas por dia de la semana (derivado de fecha con strftime)
SELECT
    CASE CAST(strftime('%w', published_date) AS INT)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        ELSE 'Saturday'
    END                                             AS dia_semana,
    COUNT(*)                                        AS videos,
    ROUND(AVG(views), 0)                            AS vistas_medias,
    ROUND(AVG(engagement_rate_pct), 2)              AS er_medio,
    ROUND(AVG(completion_pct), 2)                   AS completion_medio
FROM tiktok_videos
GROUP BY dia_semana
ORDER BY er_medio DESC;
