/*
 Проект:     Анализ данных StackOverflow, часть 1 (Яндекс Практикум, «Продвинутый SQL»)
 Таблицы:    stackoverflow.posts, users, badges, votes, vote_types (схема: schema.png)
 Приёмы:     агрегации, подзапросы, JOIN, CTE, CASE, работа с датами,
             оконные функции (ROW_NUMBER, DENSE_RANK, AVG/SUM OVER, FIRST_VALUE)
 СУБД:       PostgreSQL
*/


-- 1. Количество вопросов, которые набрали больше 300 очков
--    или как минимум 100 раз были добавлены в «Закладки».
SELECT COUNT(id) AS questions_cnt
FROM stackoverflow.posts
WHERE post_type_id = 1  -- 1 — вопрос
  AND (score > 300 OR favorites_count >= 100);


-- 2. Сколько в среднем в день задавали вопросов с 1 по 18 ноября 2008 включительно.
--    Результат округлён до целого.
SELECT ROUND(AVG(questions_cnt)) AS avg_questions_per_day
FROM (
    SELECT
        creation_date::date AS dt,
        COUNT(id)           AS questions_cnt
    FROM stackoverflow.posts
    WHERE post_type_id = 1
      AND creation_date::date BETWEEN '2008-11-01' AND '2008-11-18'
    GROUP BY creation_date::date
) AS daily;


-- 3. Сколько пользователей получили значки сразу в день регистрации.
SELECT COUNT(DISTINCT u.id) AS users_cnt
FROM stackoverflow.users AS u
JOIN stackoverflow.badges AS b
    ON u.id = b.user_id
WHERE b.creation_date::date = u.creation_date::date;


-- 4. Сколько уникальных постов пользователя Joel Coehoorn получили хотя бы один голос.
SELECT COUNT(DISTINCT p.id) AS posts_cnt
FROM stackoverflow.posts AS p
WHERE p.user_id IN (
        SELECT id
        FROM stackoverflow.users
        WHERE display_name = 'Joel Coehoorn'
      )
  AND p.id IN (
        SELECT post_id
        FROM stackoverflow.votes
      );


-- 5. Все поля таблицы vote_types и поле rank с номерами записей в обратном порядке.
--    Таблица отсортирована по id.
SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY id DESC) AS rank
FROM stackoverflow.vote_types
ORDER BY id;


-- 6. Топ-10 пользователей, которые поставили больше всего голосов типа Close.
--    Сортировка: по убыванию числа голосов, затем по убыванию id пользователя.
SELECT
    v.user_id,
    COUNT(v.id) AS close_votes_cnt
FROM stackoverflow.votes AS v
JOIN stackoverflow.vote_types AS vt
    ON v.vote_type_id = vt.id
WHERE vt.name = 'Close'
GROUP BY v.user_id
ORDER BY close_votes_cnt DESC, v.user_id DESC
LIMIT 10;


-- 7. Топ-10 пользователей по количеству значков с 15 ноября по 15 декабря 2008 года.
--    Одинаковое число значков — одинаковое место в рейтинге.
SELECT
    user_id,
    COUNT(id)                              AS badges_cnt,
    DENSE_RANK() OVER (ORDER BY COUNT(id) DESC) AS rating
FROM stackoverflow.badges
WHERE creation_date::date BETWEEN '2008-11-15' AND '2008-12-15'
GROUP BY user_id
ORDER BY badges_cnt DESC, user_id
LIMIT 10;


-- 8. Сколько в среднем очков получает пост каждого пользователя.
--    Посты без заголовка и с нулём очков не учитываются.
SELECT
    title,
    user_id,
    score,
    ROUND(AVG(score) OVER (PARTITION BY user_id)) AS avg_user_score
FROM stackoverflow.posts
WHERE title <> ''
  AND score <> 0;


-- 9. Заголовки постов пользователей, получивших более 1000 значков.
SELECT title
FROM stackoverflow.posts
WHERE title <> ''
  AND user_id IN (
        SELECT user_id
        FROM stackoverflow.badges
        GROUP BY user_id
        HAVING COUNT(id) > 1000
      );


-- 10. Пользователи из США, разделённые на три группы по числу просмотров профиля.
--     Пользователи с нулём просмотров не учитываются.
SELECT
    id,
    views,
    CASE
        WHEN views >= 350 THEN 1
        WHEN views >= 100 THEN 2
        ELSE 3
    END AS views_group
FROM stackoverflow.users
WHERE location LIKE '%United States%'
  AND views <> 0;


-- 11. Лидеры каждой группы из задачи 10 — пользователи с максимальным числом просмотров.
--     Сортировка: по убыванию просмотров, затем по возрастанию id.
WITH user_groups AS (
    SELECT
        id,
        views,
        CASE
            WHEN views >= 350 THEN 1
            WHEN views >= 100 THEN 2
            ELSE 3
        END AS views_group
    FROM stackoverflow.users
    WHERE location LIKE '%United States%'
      AND views <> 0
)
SELECT
    id,
    views_group,
    views
FROM user_groups
WHERE views IN (
        SELECT MAX(views)
        FROM user_groups
        GROUP BY views_group
      )
ORDER BY views DESC, id;


-- 12. Ежедневный прирост новых пользователей в ноябре 2008 года
--     с накопительной суммой.
SELECT
    day_num,
    users_cnt,
    SUM(users_cnt) OVER (ORDER BY day_num) AS users_cumulative
FROM (
    SELECT
        EXTRACT(DAY FROM creation_date::date) AS day_num,
        COUNT(id)                             AS users_cnt
    FROM stackoverflow.users
    WHERE creation_date::date BETWEEN '2008-11-01' AND '2008-11-30'
    GROUP BY creation_date::date
) AS daily;


-- 13. Интервал между регистрацией и первым постом для каждого пользователя,
--     написавшего хотя бы один пост.
SELECT DISTINCT
    p.user_id,
    FIRST_VALUE(p.creation_date) OVER (
        PARTITION BY p.user_id
        ORDER BY p.creation_date
    ) - u.creation_date AS time_to_first_post
FROM stackoverflow.posts AS p
JOIN stackoverflow.users AS u
    ON p.user_id = u.id;
