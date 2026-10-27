/*
 Задача:     Написать процедуру, которая выгружает в отдельную таблицу операции
             по страховым взносам, где плательщик — ИП, за период, заданный
             параметрами. Процедура фиксирует свою работу в таблице отладки:
             номер записи, время начала, входные параметры, число вставленных
             строк, время окончания, флаг успешного выполнения.
 Таблицы:    sh.test_operation (источник), oper_zao (результат), log_table (лог)
 Приёмы:     PL/SQL-процедура с параметрами, INSERT ... SELECT, SQL%ROWCOUNT,
             SEQUENCE, RETURNING INTO, логирование, обработка исключений
 Результат:  выгрузка операций за период + журнал запусков процедуры
             (одна строка журнала на один запуск)
 СУБД:       Oracle (PL/SQL)
*/


-- 1. Таблица для результата: та же структура, что у источника, без данных
CREATE TABLE oper_zao AS
SELECT *
FROM sh.test_operation
WHERE 1 = 0;


-- 2. Таблица отладки (журнал запусков)
CREATE TABLE log_table (
    id           NUMBER PRIMARY KEY,   -- порядковый номер записи
    proc_start   DATE NOT NULL,        -- дата и время начала
    dt_from      DATE NOT NULL,        -- входной параметр: начало периода
    dt_to        DATE NOT NULL,        -- входной параметр: конец периода
    row_count    NUMBER,               -- количество вставленных строк
    proc_end     DATE,                 -- дата и время окончания
    proc_status  VARCHAR2(10)          -- флаг успешного выполнения
);

CREATE SEQUENCE seq_proc_log_id
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE;


-- 3. Процедура выгрузки
CREATE OR REPLACE PROCEDURE zao_from_to (
    date_from IN DATE,
    date_to   IN DATE
)
IS
    v_log_id  log_table.id%TYPE;
    v_count   NUMBER := 0;
BEGIN
    -- запись о начале работы (фиксируем сразу, чтобы она осталась даже при ошибке)
    INSERT INTO log_table (id, proc_start, dt_from, dt_to, proc_status)
    VALUES (seq_proc_log_id.NEXTVAL, SYSDATE, date_from, date_to, 'RUNNING')
    RETURNING id INTO v_log_id;
    COMMIT;

    -- выгрузка одним запросом вместо построчной вставки в цикле
    INSERT INTO oper_zao
    SELECT *
    FROM sh.test_operation op
    WHERE op.data_op >= date_from
      AND op.data_op <= date_to
      AND REGEXP_LIKE(op.descr, ' ИП ')
      AND REGEXP_LIKE(op.descr, 'страх');

    v_count := SQL%ROWCOUNT;

    -- завершаем ту же запись журнала
    UPDATE log_table
    SET row_count   = v_count,
        proc_end    = SYSDATE,
        proc_status = 'TRUE'
    WHERE id = v_log_id;

    COMMIT;   -- данные и запись журнала фиксируются вместе

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;   -- отменяем частично вставленные данные

        UPDATE log_table
        SET row_count   = 0,
            proc_end    = SYSDATE,
            proc_status = 'FALSE'
        WHERE id = v_log_id;
        COMMIT;

        RAISE;      -- передаём ошибку в вызывающую среду
END zao_from_to;
/


-- 4. Запуск и проверка
BEGIN
    zao_from_to(DATE '2001-01-01', DATE '2010-01-01');
END;
/

SELECT * FROM log_table ORDER BY id;
SELECT * FROM oper_zao  ORDER BY data_op;
