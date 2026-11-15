-- Запрос 5. Процент объявлений в Санкт-Петербурге
SELECT COUNT(id) AS num_flats, -- Считаем общее кол-во объявлений
(SELECT COUNT(id) 
FROM real_estate.flats AS f
LEFT JOIN real_estate.city AS c ON f.city_id=c.city_id
WHERE city ='Санкт-Петербург') AS num_flats_spb, -- Считаем кол-во объявлений в Санкт-Петербурге с помощью подзапроса SELECT (можно было
-- использовать CTE или аналогично Запрос 4 FILTER)
ROUND((COUNT(*) FILTER (WHERE city ='Санкт-Петербург')::numeric / COUNT(id)) * 100,2) AS percentage_flats_spb -- Считаем процент объявленний
-- в Санкт-Петербурге от общества кол-ва объявлений
FROM real_estate.flats AS f
LEFT JOIN real_estate.city AS c ON f.city_id=c.city_id;