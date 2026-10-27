/*
 Задача:     Написать триггер, который фиксирует создание и удаление таблиц
             в схеме пользователя. Запретить создание и удаление таблиц
             в рабочее время (пн–пт, 09:00–18:00): при попытке триггер
             возбуждает исключение с сообщением. Все попытки записываются
             в специальную таблицу.
 Таблицы:    conn_log (журнал DDL-событий)
 Приёмы:     триггер уровня схемы (DDL-триггер на CREATE и DROP),
             автономная транзакция (PRAGMA AUTONOMOUS_TRANSACTION),
             системные атрибуты событий (ora_login_user, ora_dict_obj_type,
             ora_dict_obj_name, ora_sysevent), RAISE_APPLICATION_ERROR
 Результат:  журнал всех созданий и удалений таблиц; в рабочее время
             такие операции блокируются
 СУБД:       Oracle (PL/SQL)
*/


-- 1. Журнал событий
CREATE TABLE conn_log (
    id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    log_user     VARCHAR2(128),
    table_name   VARCHAR2(128),
    event        VARCHAR2(30),     -- CREATE или DROP
    event_date   DATE,
    check_error  NUMBER(1)         -- 1 — попытка заблокирована, 0 — выполнена
);


-- 2. Триггер
CREATE OR REPLACE TRIGGER tr_table_ddl_audit
BEFORE CREATE OR DROP ON SCHEMA
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_is_work_time BOOLEAN;
BEGIN
    -- отслеживаем только таблицы
    IF ora_dict_obj_type = 'TABLE' THEN

        -- рабочее время: пн–пт, 09:00–17:59
        -- (день недели берём по названию, чтобы не зависеть от настроек NLS)
        v_is_work_time :=
            TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE = ENGLISH')
                IN ('MON', 'TUE', 'WED', 'THU', 'FRI')
            AND TO_NUMBER(TO_CHAR(SYSDATE, 'HH24')) BETWEEN 9 AND 17;

        IF v_is_work_time THEN
            INSERT INTO conn_log (log_user, table_name, event, event_date, check_error)
            VALUES (ora_login_user, ora_dict_obj_name, ora_sysevent, SYSDATE, 1);
            COMMIT;

            RAISE_APPLICATION_ERROR(
                -20202,
                'Создание и удаление таблиц запрещено в рабочее время (пн–пт, 09:00–18:00)'
            );
        ELSE
            INSERT INTO conn_log (log_user, table_name, event, event_date, check_error)
            VALUES (ora_login_user, ora_dict_obj_name, ora_sysevent, SYSDATE, 0);
            COMMIT;
        END IF;

    END IF;
END tr_table_ddl_audit;
/


-- 3. Проверка
-- в рабочее время обе команды завершатся ошибкой ORA-20202,
-- в нерабочее — выполнятся; в обоих случаях попытка попадёт в журнал
CREATE TABLE test (id NUMBER);
DROP TABLE test;

SELECT * FROM conn_log ORDER BY id;
