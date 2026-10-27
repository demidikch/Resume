/*
 Задача:     Найти российские паспорта нового образца (серия — 4 цифры,
             номер — 6 цифр). Серия иногда указана не в отдельном поле,
             а вместе с номером. Вывести серию и номер паспорта одной строкой.
 Таблицы:    sh.uch_vse (rg0, sd0 — поля с серией и/или номером, цифры через пробел)
 Приёмы:     регулярные выражения (REGEXP_LIKE), CTE (WITH), CASE,
             конкатенация, REPLACE, очистка и нормализация данных
 Результат:  участники и их паспорт в формате «10 цифр без пробелов»
 СУБД:       Oracle
*/

WITH parsed AS (
    SELECT
        naimen,
        rg0,
        sd0,
        CASE
            -- серия в rg0, номер в sd0
            WHEN REGEXP_LIKE(rg0, '^(\d ){3}\d$')
             AND REGEXP_LIKE(sd0, '^(\d ){5}\d$')
                THEN REPLACE(rg0 || sd0, ' ', '')
            -- серия и номер целиком в rg0, sd0 не заполнено
            WHEN REGEXP_LIKE(rg0, '^(\d ){9}\d$')
             AND sd0 = '0'
                THEN REPLACE(rg0, ' ', '')
            -- серия и номер целиком в sd0, rg0 не заполнено
            WHEN REGEXP_LIKE(sd0, '^(\d ){9}\d$')
             AND rg0 = '0'
                THEN REPLACE(sd0, ' ', '')
            -- серия в sd0, номер в rg0
            WHEN REGEXP_LIKE(sd0, '^(\d ){3}\d$')
             AND REGEXP_LIKE(rg0, '^(\d ){5}\d$')
                THEN REPLACE(sd0 || rg0, ' ', '')
        END AS passport
    FROM sh.uch_vse
)
SELECT DISTINCT
    naimen,
    rg0,
    sd0,
    passport
FROM parsed
WHERE passport IS NOT NULL
  AND passport NOT LIKE '00%'   -- серия паспорта РФ не начинается с «00»
ORDER BY naimen;
