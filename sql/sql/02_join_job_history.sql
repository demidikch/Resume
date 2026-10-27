/*
 Задача:     Вывести имя сотрудника, название отдела, дату начала и окончания
             работы на прошлой должности — только для сотрудников, у которых
             дата окончания работы позднее 2006 года.
 Таблицы:    hr.employees, hr.departments, hr.job_history
 Приёмы:     JOIN нескольких таблиц, фильтрация по дате
 Результат:  список сотрудников с периодами работы, закончившимися после 2006 года
 СУБД:       Oracle (учебная схема HR)
*/

SELECT
    e.first_name,
    e.last_name,
    d.department_name,
    j.start_date,
    j.end_date
FROM hr.employees e
JOIN hr.departments d
    ON e.department_id = d.department_id
JOIN hr.job_history j
    ON e.employee_id = j.employee_id
WHERE j.end_date > DATE '2006-12-31';
