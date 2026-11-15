-- Запрос 1. Определение временного интервала данных
-- Следует обратить внимание на начальную дату и конечную дату в данных, так как годовые интервалы данных неполные
-- при анализе используем только те года, которые включают все месяца года
SELECT *
FROM (SELECT MAX(first_day_exposition) AS max_date, MIN(first_day_exposition) AS min_date
FROM real_estate.advertisement);