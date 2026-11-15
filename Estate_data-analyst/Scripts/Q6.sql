-- Запрос 6. Определение статистических показателей для одного квадратного метра квартиры
SELECT MIN(a.last_price / f.total_area) AS min_price_per_sqm, -- Считаем минимальную стоимость квадратного метра
MAX(a.last_price / f.total_area) AS max_price_per_sqm, -- Считаем максимальную стоимость квадратного метра
ROUND(AVG(a.last_price / f.total_area)::numeric, 2) AS avg_price_per_sqm, -- Считаем среднюю стоимость квадратного метра
ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY (a.last_price / f.total_area))::numeric, 2) AS median_price_per_sqm -- Считаем медиану
-- стоимости квадратного метра
FROM real_estate.advertisement AS a
LEFT JOIN real_estate.flats AS f ON a.id = f.id
WHERE f.total_area > 0 AND a.last_price IS NOT NULL; -- Условие, чтобы избежать деления на 0 и использовать целые данные (везде, где есть цена)