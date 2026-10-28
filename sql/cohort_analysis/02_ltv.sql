/*
 Задача:     Когортный анализ LTV пользователей, зарегистрированных в 2019 году.
             Когорта — месяц регистрации. LTV — выручка когорты с накоплением
             по лайфтайму, делённая на размер когорты.
 Таблицы:    tools_shop.users, orders (схема: schema.png)
 Приёмы:     цепочка CTE, оконные функции (COUNT OVER, SUM OVER с накоплением),
             AGE и расчёт лайфтайма в месяцах
 Результат:  лайфтайм (месяцев с регистрации), месяц старта когорты, LTV
 СУБД:       PostgreSQL
*/

WITH profile AS (
    -- пользователи, месяц регистрации и размер когорты
    SELECT
        user_id,
        DATE_TRUNC('month', created_at)::date AS cohort_month,
        COUNT(user_id) OVER (
            PARTITION BY DATE_TRUNC('month', created_at)::date
        ) AS cohort_size
    FROM tools_shop.users
    WHERE created_at >= '2019-01-01'
      AND created_at <  '2020-01-01'
),
sessions AS (
    -- заказы с лайфтаймом: сколько полных месяцев прошло с месяца регистрации
    SELECT
        EXTRACT(YEAR  FROM AGE(DATE_TRUNC('month', o.created_at), pf.cohort_month)) * 12
      + EXTRACT(MONTH FROM AGE(DATE_TRUNC('month', o.created_at), pf.cohort_month)) AS lifetime,
        DATE_TRUNC('month', o.created_at)::date AS order_month,
        pf.cohort_month,
        pf.cohort_size,
        o.total_amt
    FROM profile AS pf
    JOIN tools_shop.orders AS o
        ON pf.user_id = o.user_id
),
ltv_raw AS (
    -- выручка когорты с накоплением по лайфтайму на одного пользователя
    SELECT
        lifetime,
        cohort_month,
        cohort_size,
        SUM(total_amt) OVER (
            PARTITION BY cohort_month
            ORDER BY lifetime
        ) / cohort_size AS ltv
    FROM sessions
)
SELECT
    lifetime,
    cohort_month,
    ltv
FROM ltv_raw
GROUP BY lifetime, cohort_month, ltv
ORDER BY cohort_month, lifetime;
