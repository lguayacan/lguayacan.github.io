-- Project 2: Where do cost outliers come from?
-- Table: construction-analytics-512220.cost_analysis.projects (6,123 rows, loaded from the Kaggle CSV)

-- 1. Inspect the data
SELECT project_id, project_type, total_area_sqft, total_project_cost
FROM `construction-analytics-512220.cost_analysis.projects`
LIMIT 10;

-- 2. Average cost by project type
SELECT project_type,
       COUNT(*) AS projects,
       ROUND(AVG(total_project_cost)) AS avg_cost
FROM `construction-analytics-512220.cost_analysis.projects`
GROUP BY project_type
ORDER BY avg_cost DESC;

-- 3. Highest cost per sq ft
SELECT project_id, project_type, total_project_cost,
       ROUND(total_project_cost / total_area_sqft, 2) AS cost_per_sqft
FROM `construction-analytics-512220.cost_analysis.projects`
WHERE total_project_cost / total_area_sqft > 195
ORDER BY cost_per_sqft DESC
LIMIT 20;

-- 4. Count of IQR outliers (upper fence from query 5b). Expected: 423
SELECT COUNT(*) AS flagged
FROM `construction-analytics-512220.cost_analysis.projects`
WHERE total_project_cost / total_area_sqft > 194.8451739;

-- 5. Quartiles and IQR fences for cost per sq ft
WITH cps AS (
  SELECT total_project_cost / total_area_sqft AS cost_per_sqft
  FROM `construction-analytics-512220.cost_analysis.projects`
),
quartiles AS (
  SELECT DISTINCT
         PERCENTILE_CONT(cost_per_sqft, 0.25) OVER () AS q1,
         PERCENTILE_CONT(cost_per_sqft, 0.75) OVER () AS q3
  FROM cps
)
SELECT q1, q3, q3 - q1 AS iqr,
       q1 - 1.5 * (q3 - q1) AS lower_fence,
       q3 + 1.5 * (q3 - q1) AS upper_fence
FROM quartiles;

-- 6. Share of outliers by project type
SELECT project_type,
       COUNT(*) AS projects,
       COUNTIF(total_project_cost / total_area_sqft > 194.8451739) AS flagged,
       ROUND(100 * COUNTIF(total_project_cost / total_area_sqft > 194.8451739) / COUNT(*), 1) AS pct_flagged
FROM `construction-analytics-512220.cost_analysis.projects`
GROUP BY project_type
ORDER BY pct_flagged DESC;

-- 7. Share of outliers by area band
SELECT CASE
         WHEN total_area_sqft < 2000 THEN '1. under 2,000'
         WHEN total_area_sqft < 5000 THEN '2. 2,000 to 4,999'
         WHEN total_area_sqft < 10000 THEN '3. 5,000 to 9,999'
         ELSE '4. 10,000 or more'
       END AS area_band,
       COUNT(*) AS projects,
       COUNTIF(total_project_cost / total_area_sqft > 194.8451739) AS flagged,
       ROUND(100 * COUNTIF(total_project_cost / total_area_sqft > 194.8451739) / COUNT(*), 1) AS pct_flagged
FROM `construction-analytics-512220.cost_analysis.projects`
GROUP BY area_band
ORDER BY area_band;

-- 8. Equipment cost as a share of total cost, by area band
SELECT CASE
         WHEN total_area_sqft < 2000 THEN '1. under 2,000'
         WHEN total_area_sqft < 5000 THEN '2. 2,000 to 4,999'
         WHEN total_area_sqft < 10000 THEN '3. 5,000 to 9,999'
         ELSE '4. 10,000 or more'
       END AS area_band,
       ROUND(AVG(total_project_cost)) AS avg_cost,
       ROUND(AVG(equipment_cost)) AS avg_equipment,
       ROUND(100 * AVG(equipment_cost / total_project_cost), 1) AS equipment_pct_of_cost
FROM `construction-analytics-512220.cost_analysis.projects`
GROUP BY area_band
ORDER BY area_band;

-- 9. IQR fences on cost per sq ft net of equipment. Result: upper fence 175.99, 205 flagged
WITH base AS (
  SELECT (total_project_cost - equipment_cost) / total_area_sqft AS net_cost_per_sqft
  FROM `construction-analytics-512220.cost_analysis.projects`
),
q AS (
  SELECT DISTINCT
         PERCENTILE_CONT(net_cost_per_sqft, 0.25) OVER () AS q1,
         PERCENTILE_CONT(net_cost_per_sqft, 0.75) OVER () AS q3
  FROM base
)
SELECT ROUND(q1, 2) AS q1,
       ROUND(q3, 2) AS q3,
       ROUND(q3 + 1.5 * (q3 - q1), 2) AS upper_fence,
       (SELECT COUNTIF(net_cost_per_sqft > q3 + 1.5 * (q3 - q1)) FROM base) AS flagged
FROM q;

-- 10. Where do the remaining outliers sit?
WITH base AS (
  SELECT total_area_sqft,
         (total_project_cost - equipment_cost) / total_area_sqft AS net_cost_per_sqft
  FROM `construction-analytics-512220.cost_analysis.projects`
)
SELECT CASE
         WHEN total_area_sqft < 2000 THEN '1. under 2,000'
         WHEN total_area_sqft < 5000 THEN '2. 2,000 to 4,999'
         WHEN total_area_sqft < 10000 THEN '3. 5,000 to 9,999'
         ELSE '4. 10,000 or more'
       END AS area_band,
       COUNT(*) AS projects,
       COUNTIF(net_cost_per_sqft > 175.99) AS flagged
FROM base
GROUP BY area_band
ORDER BY area_band;

-- 11. Do risk or weather explain the outliers? (outlier = cost per sq ft above the IQR fence)
SELECT total_project_cost / total_area_sqft > 194.8451739 AS is_outlier,
       COUNT(*) AS projects,
       ROUND(AVG(risk_index), 3) AS avg_risk,
       ROUND(AVG(rainfall_index), 3) AS avg_rainfall,
       ROUND(AVG(avg_temperature), 2) AS avg_temp,
       ROUND(AVG(weather_delay_days), 2) AS avg_delay_days
FROM `construction-analytics-512220.cost_analysis.projects`
GROUP BY is_outlier;
