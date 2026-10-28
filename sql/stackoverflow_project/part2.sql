/*
 Проект:     Анализ данных StackOverflow, часть 2 (Яндекс Практикум, «Продвинутый SQL»)
 Таблицы:    stackoverflow.posts, users (схема: schema.png)
 Приёмы:     CTE, подзапросы, JOIN, интервалы дат,
             оконные функции (SUM OVER с накоплением, LAG), расчёт изменения в процентах
 СУБД:       PostgreSQL
*/


-- 1. Общая сумма просмотров постов за каждый месяц 2008 года.
--    Сортировка по убыванию просмотров.
SELECT
    DATE_TRUNC('month', creation_date)::date AS month,
    SUM(views_count)                         AS total_views
FROM stackoverflow.posts
WHERE DATE_TRUNC('month', creation_date)::date BETWEEN '2008-01-01' AND '2008-12-01'
GROUP BY month
ORDER BY total_views DESC;


-- 2. Имена самых активных пользователей, которые в первый месяц после регистрации
--    (включая день регистрации) дали больше 100 ответов.
--    Для каждого имени — количество уникальных user_id.
SELECT
    u.display_name,
    COUNT(DISTINCT p.user_id) AS users_cnt
FROM stackoverflow.users AS u
JOIN stackoverflow.posts AS p
    ON u.id = p.user_id
WHERE p.post_type_id = 2  -- 2 — ответ
  AND p.creation_date::date BETWEEN u.creation_date::date
                                AND u.creation_date::date + INTERVAL '1 month'
GROUP BY u.display_name
HAVING COUNT(p.user_id) > 100
ORDER BY u.display_name;


-- 3. Количество постов за 2008 год по месяцам от пользователей, которые
--    зарегистрировались в сентябре 2008 года и сделали хотя бы один пост в декабре.
SELECT
    DATE_TRUNC('month', creation_date)::date AS month,
    COUNT(id)                                AS posts_cnt
FROM stackoverflow.posts
WHERE user_id IN (
        SELECT id
        FROM stackoverflow.users
        WHERE DATE_TRUNC('month', creation_date)::date = '2008-09-01'
      )
  AND user_id IN (
        SELECT user_id
        FROM stackoverflow.posts
        WHERE DATE_TRUNC('month', creation_date)::date = '2008-12-01'
      )
GROUP BY month
ORDER BY month DESC;


-- 4. Для каждого поста: автор, дата, просмотры и сумма просмотров постов автора
--    с накоплением. Сортировка по автору, затем по дате поста.
SELECT
    user_id,
    creation_date,
    views_count,
    SUM(views_count) OVER (
        PARTITION BY user_id
        ORDER BY creation_date
    ) AS views_cumulative
FROM stackoverflow.posts
ORDER BY user_id, creation_date;


-- 5. Сколько в среднем дней с 1 по 7 декабря 2008 года пользователи
--    публиковали хотя бы один пост. Результат округлён до целого.
WITH active_days AS (
    SELECT
        user_id,
        COUNT(DISTINCT creation_date::date) AS days_cnt
    FROM stackoverflow.posts
    WHERE creation_date::date BETWEEN '2008-12-01' AND '2008-12-07'
    GROUP BY user_id
)
SELECT ROUND(AVG(days_cnt)) AS avg_active_days
FROM active_days;


-- 6. Изменение количества постов месяц к месяцу (в процентах)
--    с 1 сентября по 31 декабря 2008 года.
WITH monthly_posts AS (
    SELECT
        EXTRACT(MONTH FROM creation_date) AS month_num,
        COUNT(id)                         AS posts_cnt
    FROM stackoverflow.posts
    WHERE creation_date::date BETWEEN '2008-09-01' AND '2008-12-31'
    GROUP BY month_num
)
SELECT
    month_num,
    posts_cnt,
    ROUND(
        (posts_cnt - LAG(posts_cnt) OVER (ORDER BY month_num)) * 100.0
        / LAG(posts_cnt) OVER (ORDER BY month_num),
        2
    ) AS change_pct
FROM monthly_posts
ORDER BY month_num;


-- 7. Активность пользователя с наибольшим числом постов за всё время:
--    номер недели октября 2008 года и время последнего поста на этой неделе.
WITH top_user AS (
    SELECT user_id
    FROM stackoverflow.posts
    GROUP BY user_id
    ORDER BY COUNT(id) DESC
    LIMIT 1
)
SELECT
    EXTRACT(WEEK FROM creation_date) AS week_num,
    MAX(creation_date)               AS last_post_dt
FROM stackoverflow.posts
WHERE user_id = (SELECT user_id FROM top_user)
  AND DATE_TRUNC('month', creation_date)::date = '2008-10-01'
GROUP BY week_num
ORDER BY week_num;
