-- Запрос 3. Определение статистических характеристик по времени активности объявления
SELECT MIN(days_exposition) AS min_days, MAX(days_exposition) AS max_days, ROUND(AVG(days_exposition):: numeric,2) AS avg_days,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY days_exposition) AS median_days
FROM real_estate.advertisement;