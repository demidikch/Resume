/*
 Задача:     Вывести имя, фамилию и зарплату всех сотрудников, у которых
             зарплата выше средней по отделу продаж (department_name = 'Sales').
             Решить с помощью подзапроса.
 Таблицы:    hr.employees, hr.departments
 Приёмы:     скалярный подзапрос, агрегатная функция AVG, JOIN, алиасы столбцов
 Результат:  список сотрудников с зарплатой выше средней в отделе Sales
 СУБД:       Oracle (учебная схема HR)
*/

SELECT
    e.first_name  AS "Имя",
    e.last_name   AS "Фамилия",
    e.salary      AS "Оклад"
FROM hr.employees e
WHERE e.salary > (
    SELECT AVG(s.salary)
    FROM hr.employees s
    JOIN hr.departments d
        ON s.department_id = d.department_id
    WHERE d.department_name = 'Sales'
);
