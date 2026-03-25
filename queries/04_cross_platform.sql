-- ============================================================
-- 04 · ANÁLISIS CROSS-PLATFORM
-- JOINs, UNION, comparativas TikTok vs Instagram
-- ============================================================


-- 4.1 UNION: todos los posts de ambas plataformas en una sola tabla normalizada
SELECT
    'TikTok'                AS plataforma,
    published_date          AS fecha,
    title                   AS descripcion,
    views                   AS visualizaciones,
    engagement_rate_pct     AS engagement_rate,
    save_rate_pct           AS save_rate,
    share_rate_pct          AS share_rate,
    new_followers           AS seguidores_ganados
FROM tiktok_videos

UNION ALL

SELECT
    'Instagram'             AS plataforma,
    fecha,
    descripcion_corta,
    visualizaciones,
    engagement_rate,
    save_rate,
    share_rate,
    seguidores_ganados
FROM instagram_reels

ORDER BY plataforma, fecha;


-- 4.2 Comparativa directa de KPIs medios por plataforma
SELECT
    plataforma,
    COUNT(*)                                  AS total_posts,
    ROUND(AVG(visualizaciones), 0)            AS vistas_medias,
    ROUND(AVG(engagement_rate), 2)            AS er_medio,
    ROUND(AVG(save_rate), 2)                  AS save_rate_medio,
    ROUND(AVG(share_rate), 2)                 AS share_rate_medio,
    SUM(seguidores_ganados)                   AS seguidores_totales,
    ROUND(
        CAST(SUM(seguidores_ganados) AS FLOAT) /
        NULLIF(SUM(visualizaciones), 0) * 1000, 3
    )                                         AS follower_rate_1k
FROM (
    SELECT 'TikTok' AS plataforma, views AS visualizaciones,
           engagement_rate_pct AS engagement_rate, save_rate_pct AS save_rate,
           share_rate_pct AS share_rate, new_followers AS seguidores_ganados
    FROM tiktok_videos
    UNION ALL
    SELECT 'Instagram', visualizaciones, engagement_rate, save_rate,
           share_rate, seguidores_ganados
    FROM instagram_reels
)
GROUP BY plataforma;


-- 4.3 ¿Qué temáticas funcionan mejor en cada plataforma?
WITH ig_temas AS (
    SELECT
        tema,
        'Instagram'                       AS plataforma,
        COUNT(*)                          AS posts,
        ROUND(AVG(engagement_rate), 2)    AS er_medio,
        ROUND(AVG(save_rate), 2)          AS save_medio
    FROM instagram_reels
    GROUP BY tema
),
tt_temas AS (
    SELECT
        CASE
            WHEN LOWER(title) LIKE '%sql%'         THEN 'SQL'
            WHEN LOWER(title) LIKE '%python%'      THEN 'Python'
            WHEN LOWER(title) LIKE '%excel%'       THEN 'Excel'
            WHEN LOWER(title) LIKE '%informátic%'
              OR LOWER(title) LIKE '%informatico%'
              OR LOWER(title) LIKE '%chico%'       THEN 'Humor personal'
            ELSE 'Otro'
        END                               AS tema,
        'TikTok'                          AS plataforma,
        COUNT(*)                          AS posts,
        ROUND(AVG(engagement_rate_pct), 2) AS er_medio,
        ROUND(AVG(save_rate_pct), 2)      AS save_medio
    FROM tiktok_videos
    GROUP BY tema
)
SELECT * FROM ig_temas
UNION ALL
SELECT * FROM tt_temas
ORDER BY tema, plataforma;


-- 4.4 ¿Qué día de la semana tiene mejor rendimiento en cada plataforma?
SELECT
    plataforma,
    dia_semana,
    posts,
    ROUND(er_medio, 2) AS er_medio,
    RANK() OVER (PARTITION BY plataforma ORDER BY er_medio DESC) AS rank_dia
FROM (
    SELECT 'TikTok' AS plataforma, dia_semana, COUNT(*) AS posts,
           AVG(engagement_rate_pct) AS er_medio
    FROM tiktok_videos GROUP BY dia_semana
    UNION ALL
    SELECT 'Instagram', dia_semana, COUNT(*), AVG(engagement_rate)
    FROM instagram_reels GROUP BY dia_semana
)
ORDER BY plataforma, rank_dia;


-- 4.5 Eficiencia de conversión: ¿qué plataforma convierte mejor vistas en seguidores?
SELECT
    plataforma,
    ROUND(SUM(seguidores) * 1.0 / SUM(vistas) * 1000, 4) AS seguidores_por_1k_vistas,
    ROUND(SUM(seguidores) * 1.0 / COUNT(*), 2)           AS seguidores_por_post,
    SUM(vistas)                                           AS vistas_totales,
    SUM(seguidores)                                       AS seguidores_totales
FROM (
    SELECT 'TikTok' AS plataforma, views AS vistas, new_followers AS seguidores
    FROM tiktok_videos
    UNION ALL
    SELECT 'Instagram', visualizaciones, seguidores_ganados
    FROM instagram_reels
)
GROUP BY plataforma
ORDER BY seguidores_por_1k_vistas DESC;
