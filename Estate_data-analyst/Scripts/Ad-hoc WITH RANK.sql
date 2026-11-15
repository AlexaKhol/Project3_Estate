/* Проект первого модуля: анализ данных для агентства недвижимости
 * Часть 2. Решаем ad hoc задачи
 * 
 * Автор: Холодилина Александра Романовна
 * Дата: 09.11.2026
*/

-- Задача 1: Время активности объявлений
-- Определим аномальные значения (выбросы) по значению перцентилей:
WITH limits AS (
    SELECT
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats),
-- Найдём id объявлений, которые не содержат выбросы, также оставим пропущенные данные:
filtered_id AS(
    SELECT id
    FROM real_estate.flats
    WHERE
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)),
-- Используйте id объявлений (СТЕ filtered_id), которые не содержат выбросы при анализе данных
categorized_data AS (
	SELECT *,
CASE WHEN days_exposition >= 1 AND days_exposition <= 30 THEN '1-30 days'
WHEN days_exposition > 30 AND days_exposition <= 90 THEN '31-90 days'
WHEN days_exposition > 90 AND days_exposition <= 180 THEN '91-180 days'
WHEN days_exposition > 180 THEN '181+ days'
ELSE 'non category' END AS flats_categories,
CASE WHEN c.city = 'Санкт-Петербург' THEN c.city
ELSE 'ЛенОбл' END AS region,
a.last_price / f.total_area AS price_per_sqm -- Стоимость за кв.м.
FROM real_estate.advertisement AS a
LEFT JOIN real_estate.flats AS f USING (id)
LEFT JOIN real_estate.city AS c USING(city_id)
LEFT JOIN real_estate."type" AS t USING (type_id)
WHERE EXTRACT(YEAR FROM a.first_day_exposition) BETWEEN 2015 AND 2018 AND t.TYPE = 'город' AND f.id IN (SELECT * FROM filtered_id))
SELECT region, flats_categories, COUNT(id) AS flats_num,
ROUND(AVG(price_per_sqm)::numeric, 2) AS avg_price_per_sqm, -- Средняя стоимость за кв.м.
ROUND(AVG(total_area)::numeric, 2) AS avg_square, -- Средняя размерность квартиры (кв.м)
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rooms) AS med_rooms, -- Медиана кол-ва комнат
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY balcony) AS med_balc, -- Медиана кол-ва балконов
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY floors_total) AS med_floor, -- Медиана по этажу расположения квартиры
-- Далее начинается дополнительная часть запроса
ROUND(AVG(ceiling_height)::numeric, 2) AS avg_ceiling_height, -- Средняя высота потолков
ROUND(AVG(kitchen_area)::numeric, 2) AS avg_kitchen_area, -- Средняя площадь кухни
ROUND(AVG(living_area)::numeric, 2) AS avg_living_area, -- Средняя жилая площадь
 -- Считаем долю студий (открытая планировка) в процентах (open_plan = 1)
ROUND((COUNT(*) FILTER (WHERE open_plan = 1)::numeric / COUNT(id)) * 100, 1) AS studio_share_perc, 
 -- Считаем долю апартаментов в процентах (is_apartment = 1)
ROUND((COUNT(*) FILTER (WHERE is_apartment = 1)::numeric / COUNT(id)) * 100, 1) AS apartment_share_perc
FROM categorized_data
GROUP BY region, flats_categories
ORDER BY region DESC, flats_num DESC, flats_categories DESC;

-- Задача 2: Сезонность объявлений
-- Определим аномальные значения (выбросы) по значению перцентилей:
WITH limits AS (
    SELECT
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats),
-- Найдём id объявлений, которые не содержат выбросы, также оставим пропущенные данные:
filtered_id AS(
    SELECT id
    FROM real_estate.flats
    WHERE
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)),
-- Используйте id объявлений (СТЕ filtered_id), которые не содержат выбросы при анализе данных
data AS (SELECT *,
a.last_price / f.total_area AS price_per_sqm, -- Стоимость за кв.м.
EXTRACT(MONTH FROM a.first_day_exposition) AS publ_month, -- Месяц публикации объявления
EXTRACT(MONTH FROM (a.first_day_exposition + a.days_exposition::int)) AS remove_month -- Месяц снятия объявления
FROM real_estate.advertisement AS a
LEFT JOIN real_estate.flats AS f USING(id)
LEFT JOIN real_estate.city AS c USING(city_id)
LEFT JOIN real_estate.type AS t USING(type_id)
WHERE t.type = 'город' AND EXTRACT(YEAR FROM a.first_day_exposition) BETWEEN 2015 AND 2018 AND f.id IN (SELECT * FROM filtered_id)),
publ_stats AS (
SELECT publ_month, 
COUNT(id) AS publ_cnt, -- Кол-во публикаций в месяце
ROUND(AVG(price_per_sqm)::numeric, 2) AS publ_avg_price_per_sqm, -- Средняя стоимость за кв.м. в публикациях за месяц
ROUND(AVG(total_area)::NUMERIC, 2) AS publ_avg_square, -- Средняя площадь квартир в публикациях за месяц
RANK() OVER (ORDER BY COUNT(id) DESC) AS publ_rank -- Ранг для определения месяца-лидера по числу публикаций
FROM data
GROUP BY publ_month),
remove_stats AS (
SELECT remove_month, 
COUNT(id) AS remove_cnt, -- Кол-во снятых публикаций в месяце
ROUND(AVG(price_per_sqm)::numeric, 2) AS remove_avg_price_per_sqm, -- Средняя стоимость за кв.м. в снятых публикациях за месяц
ROUND(AVG(total_area)::NUMERIC, 2) AS remove_avg_square, -- Средняя площадь квартир в снятых публикациях за месяц
RANK() OVER (ORDER BY COUNT(id) DESC) AS remove_rank -- Ранг для определения месяца-лидера по числу снятий объявлений
FROM data
WHERE remove_month IS NOT NULL -- Проверка на факт того, что объявление снято с публикации
GROUP BY remove_month)
SELECT publ_month AS month, -- Выводим в результирующую таблицу итоговые метрики
ps.publ_cnt,
ps.publ_rank,
rs.remove_cnt,
rs.remove_rank,
ps.publ_avg_price_per_sqm,
rs.remove_avg_price_per_sqm,
ps.publ_avg_square,
rs.remove_avg_square
FROM publ_stats AS ps
FULL JOIN remove_stats AS rs ON ps.publ_month = rs.remove_month
--WHERE remove_rank <= 3 -- Можно использовать эту строчку для фильтрации по рангу
ORDER BY month;