-- ============================================================
-- 01 · EXPLORACIÓN BÁSICA
-- Aggregations, GROUP BY, ORDER BY, HAVING
-- ============================================================


-- 1.1 Resumen global de TikTok
SELECT
    COUNT(*)                        AS total_videos,
    SUM(views)                      AS total_vistas,
    ROUND(AVG(engagement_rate_pct), 2) AS er_medio,
    ROUND(AVG(completion_pct), 2)   AS completion_medio,
    SUM(new_followers)              AS seguidores_ganados,
    MAX(views)                      AS video_mas_viral
FROM tiktok_videos;


-- 1.2 Resumen global de Instagram
SELECT
    COUNT(*)                            AS total_reels,
    SUM(visualizaciones)                AS total_vistas,
    ROUND(AVG(engagement_rate), 2)      AS er_medio,
    ROUND(AVG(save_rate), 2)            AS save_rate_medio,
    SUM(seguidores_ganados)             AS seguidores_ganados
FROM instagram_reels;


-- 1.3 TikTok — Rendimiento por día de la semana
SELECT
    dia_semana,
    COUNT(*)                              AS videos,
    ROUND(AVG(views), 0)                  AS vistas_medias,
    ROUND(AVG(engagement_rate_pct), 2)    AS er_medio,
    ROUND(AVG(completion_pct), 2)         AS completion_medio
FROM tiktok_videos
GROUP BY dia_semana
ORDER BY vistas_medias DESC;


-- 1.4 Instagram — Rendimiento por día de la semana
SELECT
    dia_semana,
    COUNT(*)                          AS reels,
    ROUND(AVG(visualizaciones), 0)    AS vistas_medias,
    ROUND(AVG(engagement_rate), 2)    AS er_medio,
    ROUND(AVG(save_rate), 2)          AS save_rate_medio
FROM instagram_reels
GROUP BY dia_semana
ORDER BY er_medio DESC;


-- 1.5 Instagram — Rendimiento por franja horaria
SELECT
    franja,
    COUNT(*)                          AS reels,
    ROUND(AVG(engagement_rate), 2)    AS er_medio,
    ROUND(AVG(save_rate), 2)          AS save_rate_medio,
    ROUND(AVG(guardados), 1)          AS guardados_medios
FROM instagram_reels
GROUP BY franja
ORDER BY er_medio DESC;


-- 1.6 Instagram — Top temáticas por engagement
SELECT
    tema,
    COUNT(*)                          AS reels,
    ROUND(AVG(engagement_rate), 2)    AS er_medio,
    ROUND(AVG(save_rate), 2)          AS save_rate_medio,
    SUM(seguidores_ganados)           AS seguidores_totales
FROM instagram_reels
GROUP BY tema
HAVING COUNT(*) >= 2
ORDER BY er_medio DESC;
