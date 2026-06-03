# 🗃️ SQL Analytics — TikTok & Instagram

> Análisis de métricas de redes sociales usando **SQL puro** sobre SQLite · @aroaxinping · Feb–Mar 2026

---

## Objetivo

Demostrar habilidades SQL aplicadas a datos reales: los mismos datos de los proyectos de [TikTok](https://github.com/aroaxinping/tiktok-analytics-aroaxinping) e [Instagram](https://github.com/aroaxinping/instagram-analytics-aroaxinping), analizados ahora con SQL en lugar de Python/pandas.

---

## Base de datos

```
social_media.db  (SQLite)
├── tiktok_videos       — 10 vídeos con métricas de engagement
├── tiktok_overview     — métricas globales del período
├── instagram_reels     — 30 reels con métricas detalladas
└── instagram_daily     — 28 días de métricas diarias de cuenta
```

---

## Queries SQL — por nivel de complejidad

### 📁 `queries/01_exploracion_basica.sql`
Fundamentos de SQL aplicados a social media analytics:
- `GROUP BY` + `HAVING` — rendimiento por temática (filtrando temas con ≥2 posts)
- `ORDER BY` con múltiples criterios
- Aggregations: `COUNT`, `SUM`, `AVG`, `MAX`, `ROUND`
- Análisis de franja horaria y día de la semana

### 📁 `queries/02_window_functions.sql`
Window functions sobre datos de rendimiento por post:
- `RANK()` y `ROW_NUMBER()` — ranking de posts y top N por categoría
- `PARTITION BY` — top 3 reels por temática independientemente
- `LAG()` / `LEAD()` — comparar cada post con el anterior/siguiente
- Running totals con `SUM() OVER (ORDER BY ...)`
- Media móvil 7 días: `AVG() OVER (ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)`
- Percentil calculado con window function

### 📁 `queries/03_ctes_subqueries.sql`
CTEs y subqueries para análisis más complejos:
- CTE simple — filtrar posts que superan la media en múltiples métricas a la vez
- CTEs encadenadas — clasificar en tiers (Top 20% / Mid 50% / Bottom 30%) y agregar por tier
- CTE con acumulado semanal
- Subquery correlacionada — comparar cada post con la media de su propia temática
- Tabla derivada en `FROM`

### 📁 `queries/04_cross_platform.sql`
Análisis comparativo TikTok vs Instagram:
- `UNION ALL` — tabla unificada normalizada de ambas plataformas
- KPIs medios por plataforma en una sola query
- Mejor día de publicación por plataforma con `PARTITION BY plataforma`
- Conversión de vistas a seguidores por plataforma (`NULLIF` para evitar división por cero)
- Rendimiento por temática en ambas plataformas

---

## Notebook

`notebooks/sql_analysis.ipynb` — ejecuta todas las queries con pandas + sqlite3 y muestra los resultados en tablas.

---

## Estructura

```
sql-social-media-analytics-aroaxinping/
├── data/
│   ├── videos_engagement.csv
│   ├── overview_metrics.csv
│   ├── reels_metricas.csv
│   └── metricas_diarias.csv
├── src/
│   └── build_db.py          ← crea social_media.db desde los CSVs
├── queries/
│   ├── 01_exploracion_basica.sql
│   ├── 02_window_functions.sql
│   ├── 03_ctes_subqueries.sql
│   └── 04_cross_platform.sql
├── notebooks/
│   └── sql_analysis.ipynb
├── social_media.db
└── requirements.txt
```

## Cómo ejecutar

```bash
git clone https://github.com/aroaxinping/sql-social-media-analytics-aroaxinping
cd sql-social-media-analytics-aroaxinping
pip install -r requirements.txt
python src/build_db.py        # genera social_media.db
jupyter notebook              # abre el notebook
```

O directamente con SQLite:
```bash
sqlite3 social_media.db < queries/02_window_functions.sql
```

---

## Proyectos relacionados

- [instagram-analytics-aroaxinping](https://github.com/aroaxinping/instagram-analytics-aroaxinping)
- [tiktok-analytics-aroaxinping](https://github.com/aroaxinping/tiktok-analytics-aroaxinping)
- [social-media-analytics-aroaxinping](https://github.com/aroaxinping/social-media-analytics-aroaxinping) — análisis cross-platform con Python

---

`SQL` `SQLite` `Python` `pandas` `Jupyter`
