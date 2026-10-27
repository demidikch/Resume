/*
 Задача:     Создать пользователя базы данных, выдать ему права на подключение,
             создание таблиц и чтение нужных таблиц, задать квоту
             на табличное пространство.
 Таблицы:    sh.test_operation, sh.test_uchast
 Приёмы:     CREATE USER, GRANT (системные и объектные привилегии), ALTER USER QUOTA
 Результат:  пользователь с минимально необходимым набором прав
 СУБД:       Oracle
*/

-- Создание пользователя (пароль заменён на заглушку)
CREATE USER chemeris_ds
    IDENTIFIED BY "<password>";

-- Системные привилегии
GRANT CONNECT      TO chemeris_ds;
GRANT CREATE TABLE TO chemeris_ds;

-- Доступ на чтение к исходным таблицам
GRANT SELECT ON sh.test_operation TO chemeris_ds;
GRANT SELECT ON sh.test_uchast    TO chemeris_ds;

-- Квота на табличное пространство
ALTER USER chemeris_ds QUOTA 10M ON users;
