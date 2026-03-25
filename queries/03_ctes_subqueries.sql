-- ============================================================
-- 03 · CTEs Y SUBQUERIES
-- WITH, subqueries correlacionadas, tablas derivadas
-- ============================================================


-- 3.1 CTE: identificar reels de Instagram que superan la media en TODAS las métricas clave
WITH medias AS (
    SELECT
        AVG(engagement_rate) AS avg_er,
        AVG(save_rate)       AS avg_save,
        AVG(share_rate)      AS avg_share
    FROM instagram_reels
)
SELECT
    r.fecha,
    r.descripcion_corta,
    r.engagement_rate,
    r.save_rate,
    r.share_rate,
    r.tema
FROM instagram_reels r
CROSS JOIN medias m
WHERE r.engagement_rate > m.avg_er
  AND r.save_rate       > m.avg_save
  AND r.share_rate      > m.avg_share
ORDER BY r.engagement_rate DESC;


-- 3.2 CTE encadenada: clasificar reels en tier de rendimiento y calcular stats por tier
WITH base AS (
    SELECT
        *,
        RANK() OVER (ORDER BY engagement_rate DESC) AS rank_er
    FROM instagram_reels
),
tiered AS (
    SELECT
        *,
        CASE
            WHEN rank_er <= CAST(COUNT(*) OVER () * 0.2 AS INT) THEN 'Top 20%'
            WHEN rank_er <= CAST(COUNT(*) OVER () * 0.5 AS INT) THEN 'Mid 50%'
            ELSE 'Bottom 30%'
        END AS tier
    FROM base
)
SELECT
    tier,
    COUNT(*)                              AS reels,
    ROUND(AVG(engagement_rate), 2)        AS er_medio,
    ROUND(AVG(save_rate), 2)              AS save_medio,
    ROUND(AVG(visualizaciones), 0)        AS vistas_medias,
    SUM(seguidores_ganados)               AS seguidores_totales
FROM tiered
GROUP BY tier
ORDER BY er_medio DESC;


-- 3.3 CTE recursiva simulada: acumulado semanal de visualizaciones en Instagram
WITH semanas AS (
    SELECT
        CAST(strftime('%W', fecha) AS INT)    AS semana,
        SUM(visualizaciones)                  AS vistas_semana,
        SUM(seguidores_ganados)               AS seguidores_semana,
        COUNT(*)                              AS reels_publicados
    FROM instagram_reels
    GROUP BY semana
)
SELECT
    semana,
    reels_publicados,
    vistas_semana,
    seguidores_semana,
    SUM(vistas_semana)     OVER (ORDER BY semana) AS vistas_acumuladas,
    SUM(seguidores_semana) OVER (ORDER BY semana) AS seguidores_acumulados
FROM semanas
ORDER BY semana;


-- 3.4 Subquery correlacionada: reels de Instagram por encima de la media de su propia temática
SELECT
    r.fecha,
    r.tema,
    r.descripcion_corta,
    r.engagement_rate,
    ROUND((
        SELECT AVG(r2.engagement_rate)
        FROM instagram_reels r2
        WHERE r2.tema = r.tema
    ), 2) AS media_er_tema,
    ROUND(r.engagement_rate - (
        SELECT AVG(r2.engagement_rate)
        FROM instagram_reels r2
        WHERE r2.tema = r.tema
    ), 2) AS diferencia_vs_tema
FROM instagram_reels r
WHERE r.engagement_rate > (
    SELECT AVG(r2.engagement_rate)
    FROM instagram_reels r2
    WHERE r2.tema = r.tema
)
ORDER BY diferencia_vs_tema DESC;


-- 3.5 Tabla derivada: mejores días para publicar en Instagram (por cuartil de ER)
SELECT
    dia,
    ROUND(er_medio, 2)      AS er_medio,
    reels,
    CASE
        WHEN er_medio >= q3 THEN 'Mejor dia'
        WHEN er_medio >= q2 THEN 'Buen dia'
        ELSE 'Evitar'
    END AS recomendacion
FROM (
    SELECT
        dia_semana  AS dia,
        AVG(engagement_rate) AS er_medio,
        COUNT(*)             AS reels,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY AVG(engagement_rate)) OVER () AS q2,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY AVG(engagement_rate)) OVER () AS q3
    FROM instagram_reels
    GROUP BY dia_semana
) stats
ORDER BY er_medio DESC;
