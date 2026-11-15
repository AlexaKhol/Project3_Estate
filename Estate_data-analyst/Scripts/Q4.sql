-- Запрос 4. Определение процента проданных объектов по доле объявлений, снятых с публикации
SELECT COUNT(*) FILTER (WHERE days_exposition IS NOT NULL) AS removed_count, -- Считаем количество снятых объявлений
 COUNT(*) AS total_count, -- Считаем общее количество объявлений
ROUND((COUNT(*) FILTER (WHERE days_exposition IS NOT NULL)::numeric / COUNT(*)) * 100,2) AS removed_percentage
-- Считаем долю проданных объектов в процентах с округлением до двух знаков, не забывая для корректного округления
-- перевести данные в тип numeric
FROM real_estate.advertisement;