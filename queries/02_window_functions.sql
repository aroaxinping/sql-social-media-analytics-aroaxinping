-- ============================================================
-- 02 · WINDOW FUNCTIONS
-- RANK, ROW_NUMBER, LAG, LEAD, running totals, percentiles
-- ============================================================


-- 2.1 Ranking de vídeos TikTok por vistas (con posición y gap respecto al anterior)
SELECT
    title,
    views,
    engagement_rate_pct,
    RANK()       OVER (ORDER BY views DESC)              AS rank_vistas,
    RANK()       OVER (ORDER BY engagement_rate_pct DESC) AS rank_er,
    views - LAG(views) OVER (ORDER BY views DESC)        AS gap_respecto_anterior
FROM tiktok_videos
ORDER BY rank_vistas;


-- 2.2 Ranking de reels Instagram por engagement — con percentil
SELECT
    descripcion_corta,
    fecha,
    engagement_rate,
    RANK()  OVER (ORDER BY engagement_rate DESC)  AS rank_er,
    ROUND(
        100.0 * RANK() OVER (ORDER BY engagement_rate DESC) / COUNT(*) OVER (),
        1
    )                                              AS percentil_er,
    CASE
        WHEN RANK() OVER (ORDER BY engagement_rate DESC) <= 5 THEN 'Top 5'
        WHEN RANK() OVER (ORDER BY engagement_rate DESC) <= 10 THEN 'Top 10'
        ELSE 'Resto'
    END                                            AS tier
FROM instagram_reels
ORDER BY rank_er;


-- 2.3 Evolución acumulada de seguidores en Instagram (running total)
SELECT
    fecha,
    seguidores_ganados,
    SUM(seguidores_ganados) OVER (ORDER BY fecha)          AS seguidores_acumulados,
    AVG(seguidores_ganados) OVER (
        ORDER BY fecha ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    )                                                       AS media_movil_7dias
FROM instagram_daily
ORDER BY fecha;


-- 2.4 Comparativa reel vs reel anterior en Instagram (LAG / LEAD)
SELECT
    fecha,
    descripcion_corta,
    engagement_rate,
    LAG(engagement_rate)  OVER (ORDER BY fecha)  AS er_reel_anterior,
    LEAD(engagement_rate) OVER (ORDER BY fecha)  AS er_reel_siguiente,
    ROUND(
        engagement_rate - LAG(engagement_rate) OVER (ORDER BY fecha), 2
    )                                             AS variacion_er
FROM instagram_reels
ORDER BY fecha;


-- 2.5 TikTok — Comparar cada vídeo con la media de su semana (GROUP vs WINDOW)
SELECT
    title,
    published_date,
    views,
    engagement_rate_pct,
    ROUND(AVG(views) OVER (), 0)                     AS media_global_vistas,
    ROUND(views - AVG(views) OVER (), 0)             AS desviacion_media,
    ROUND(AVG(engagement_rate_pct) OVER (), 2)       AS media_global_er,
    ROUND(engagement_rate_pct - AVG(engagement_rate_pct) OVER (), 2) AS desviacion_er
FROM tiktok_videos
ORDER BY published_date;


-- 2.6 Instagram — Top 3 reels por temática (partición por tema)
SELECT *
FROM (
    SELECT
        tema,
        descripcion_corta,
        fecha,
        engagement_rate,
        save_rate,
        ROW_NUMBER() OVER (PARTITION BY tema ORDER BY engagement_rate DESC) AS rank_en_tema
    FROM instagram_reels
)
WHERE rank_en_tema <= 3
ORDER BY tema, rank_en_tema;
