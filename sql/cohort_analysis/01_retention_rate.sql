/*
 Задача:     Когортный анализ Retention Rate покупателей интернет-магазина.
             Когорта — месяц первого события пользователя, совершившего
             хотя бы одну покупку. Для каждой когорты и каждого месяца
             считается доля пользователей, которые вернулись в продукт.
 Таблицы:    tools_shop.users, orders, events (схема: schema.png)
 Приёмы:     несколько CTE, JOIN, DATE_TRUNC, агрегации, расчёт доли в процентах
 Результат:  месяц старта когорты, месяц события, размер когорты,
             число активных пользователей, Retention Rate (%)
 СУБД:       PostgreSQL
*/

WITH profile AS (
    -- покупатели и месяц их первого события (старт когорты)
    SELECT
        u.user_id,
        DATE_TRUNC('month', MIN(e.event_time))::date AS cohort_month
    FROM tools_shop.users AS u
    JOIN tools_shop.orders AS o
        ON u.user_id = o.user_id
    JOIN tools_shop.events AS e
        ON u.user_id = e.user_id
    GROUP BY u.user_id
),
sessions AS (
    -- уникальные пары «пользователь — месяц активности»
    SELECT
        p.user_id,
        DATE_TRUNC('month', e.event_time)::date AS session_month
    FROM tools_shop.events AS e
    JOIN profile AS p
        ON p.user_id = e.user_id
    GROUP BY p.user_id, session_month
),
cohort_size AS (
    SELECT
        cohort_month,
        COUNT(user_id) AS cohort_users_cnt
    FROM profile
    GROUP BY cohort_month
)
SELECT
    c.cohort_month,
    s.session_month,
    c.cohort_users_cnt,
    COUNT(p.user_id)                                         AS active_users_cnt,
    ROUND(COUNT(p.user_id) * 100.0 / c.cohort_users_cnt, 2) AS retention_rate
FROM profile AS p
JOIN sessions AS s
    ON p.user_id = s.user_id
JOIN cohort_size AS c
    ON c.cohort_month = p.cohort_month
GROUP BY c.cohort_month, s.session_month, c.cohort_users_cnt
ORDER BY c.cohort_month, s.session_month;
