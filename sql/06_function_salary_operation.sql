/*
 Задача:     Написать функцию, которая определяет, относится ли операция
             к начислению заработной платы. Входной параметр — id операции,
             результат — число: 1 или 0.
 Таблицы:    sh.test_operation (kod — id операции, descr — назначение платежа)
 Приёмы:     PL/SQL-функция, SELECT INTO, REGEXP_LIKE, UPPER,
             обработка исключения NO_DATA_FOUND
 Результат:  1 — операция по заработной плате, 0 — любая другая
             (или операция не найдена)
 СУБД:       Oracle (PL/SQL)
*/

CREATE OR REPLACE FUNCTION is_salary_operation (p_oper_id IN NUMBER)
RETURN NUMBER
IS
    v_descr sh.test_operation.descr%TYPE;
BEGIN
    SELECT descr
    INTO v_descr
    FROM sh.test_operation
    WHERE kod = p_oper_id;

    IF REGEXP_LIKE(UPPER(v_descr), 'ЗАРПЛАТ|ЗАРАБОТН') THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END is_salary_operation;
/


-- Проверка
SELECT
    kod,
    descr,
    is_salary_operation(kod) AS is_salary
FROM sh.test_operation;
