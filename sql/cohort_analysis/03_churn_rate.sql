/*
 Задача:     Когортный анализ Churn Rate покупателей интернет-магазина.
             Когорта — месяц первого события пользователя, совершившего
             хотя бы одну покупку. Churn Rate — доля пользователей когорты,
             которые были активны в прошлом месяце, но не вернулись в текущем.
 Таблицы:    tools_shop.orders, events (схема: schema.png)
 Приёмы:     цепочка CTE, оконная функция LAG, приведение типов, расчёт доли в процентах
 Результат:  месяц старта когорты, месяц события, активные пользователи
             в текущем и предыдущем месяце, Churn Rate (%)
 СУБД:       PostgreSQL
*/

WITH profile AS (
    -- покупатели и месяц их первого события (старт когорты)
    SELECT
        o.user_id,
        MIN(DATE_TRUNC('month', e.event_time)::date) AS cohort_month
    FROM tools_shop.orders AS o
    JOIN tools_shop.events AS e
        ON o.user_id = e.user_id
    GROUP BY o.user_id
),
sessions AS (
    -- число активных пользователей когорты по месяцам
    SELECT
        p.cohort_month,
        DATE_TRUNC('month', e.event_time)::date AS event_month,
        COUNT(DISTINCT p.user_id)               AS users_cnt
    FROM profile AS p
    JOIN tools_shop.events AS e
        ON p.user_id = e.user_id
    GROUP BY p.cohort_month, event_month
),
churn_raw AS (
    -- активные пользователи той же когорты в предыдущем месяце
    SELECT
        *,
        LAG(users_cnt) OVER (
            PARTITION BY cohort_month
            ORDER BY event_month
        ) AS prev_month_users_cnt
    FROM sessions
)
SELECT
    *,
    ROUND((1 - users_cnt::numeric / prev_month_users_cnt) * 100, 2) AS churn_rate
FROM churn_raw
ORDER BY cohort_month, event_month;
