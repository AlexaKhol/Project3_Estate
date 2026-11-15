-- Запрос 7. Определение статистических показателей по следующим количественным данным: 
-- общая площадь недвижимости, количество комнат и балконов, высота потолков, этаж. 
WITH stats AS (
    SELECT 'total_area' AS metric_name, -- Вводим название столбца и название метрики (считаем всё по площади квартир)
        MIN(total_area) AS min_val, -- Вводим название столбца и считаем значение метрики
        MAX(total_area) AS max_val, -- Вводим название столбца и считаем значение метрики
        ROUND(AVG(total_area)::numeric, 2) AS avg_val, -- Вводим название столбца и считаем значение метрики
        ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_area) AS numeric), 2) AS median_val,  -- Аналогично предыдущей строке кода
        ROUND(CAST(PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY total_area) AS numeric), 2) AS p99_val -- Аналогично предыдущей строке кода
    FROM real_estate.flats
    UNION ALL -- Склеиваем/объединяем полученные поля
    SELECT 'rooms', -- Считаем все статистические показатели по кол-ву комнат
        MIN(rooms), MAX(rooms), 
        ROUND(AVG(rooms)::numeric, 2), 
        ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rooms) AS numeric), 2),
        ROUND(CAST(PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY rooms) AS numeric), 2)
    FROM real_estate.flats
    UNION ALL -- Склеиваем/объединяем полученные поля
    SELECT 'balcony', -- Считаем все статистические показатели по кол-ву балконов
        MIN(balcony), MAX(balcony), 
        ROUND(AVG(balcony)::numeric, 2), 
        ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY balcony) AS numeric), 2),
        ROUND(CAST(PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY balcony) AS numeric), 2)
    FROM real_estate.flats
    UNION ALL -- Склеиваем/объединяем полученные поля
    SELECT 'ceiling_height', -- Считаем все статистические показатели по высоте потолков
        MIN(ceiling_height), MAX(ceiling_height), 
        ROUND(AVG(ceiling_height)::numeric, 2), 
        ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ceiling_height) AS numeric), 2),
        ROUND(CAST(PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS numeric), 2)
    FROM real_estate.flats
    UNION ALL -- Склеиваем/объединяем полученные поля
    SELECT 'floor', -- Считаем все статистические показатели по этажу объектов
        MIN(floor), MAX(floor), 
        ROUND(AVG(floor)::numeric, 2), 
        ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY floor) AS numeric), 2),
        ROUND(CAST(PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY floor) AS numeric), 2)
    FROM real_estate.flats)
SELECT * FROM stats