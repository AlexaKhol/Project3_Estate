-- Запрос 2. Определение кол-ва объявлений по типу населеного пункта
SELECT COUNT(id) AS num_flats, t.type
FROM real_estate.flats AS f
LEFT JOIN real_estate.type AS t ON f.type_id=t.type_id
GROUP BY t.type
ORDER BY num_flats DESC;