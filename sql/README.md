# SQL и PL/SQL: учебные задачи

Решения задач по SQL и PL/SQL: проектирование базы данных, запросы к нескольким таблицам, подзапросы, регулярные выражения, администрирование пользователей, функции, процедуры и триггеры.

**СУБД:** Oracle  
**Стек:** SQL, PL/SQL, регулярные выражения

## Содержание

| № | Файл | Задача | Приёмы |
|---|------|--------|--------|
| 1 | [01_pig_farm_schema.sql](01_pig_farm_schema.sql) | Проектирование БД свиноводческой фермы ([ER-диаграмма](01_pig_farm_er_diagram.png)) | CREATE TABLE, PK, FK, связь «многие ко многим» |
| 2 | [02_join_job_history.sql](02_join_job_history.sql) | Сотрудники, отделы и периоды работы после 2006 года | JOIN трёх таблиц, фильтрация по дате |
| 3 | [03_subquery_salary_above_avg.sql](03_subquery_salary_above_avg.sql) | Сотрудники с зарплатой выше средней в отделе продаж | подзапрос, AVG |
| 4 | [04_regex_passport_search.sql](04_regex_passport_search.sql) | Поиск и нормализация паспортов РФ в «грязных» данных | REGEXP_LIKE, CTE, CASE, очистка данных |
| 5 | [05_users_and_privileges.sql](05_users_and_privileges.sql) | Создание пользователя и выдача прав | CREATE USER, GRANT, QUOTA |
| 6 | [06_function_salary_operation.sql](06_function_salary_operation.sql) | Функция: относится ли операция к выплате зарплаты (по id → 1/0) | PL/SQL-функция, SELECT INTO, регулярные выражения, NO_DATA_FOUND |
| 7 | [07_procedure_insurance_export.sql](07_procedure_insurance_export.sql) | Процедура выгрузки операций за период с журналом запусков | процедура с параметрами, INSERT … SELECT, SQL%ROWCOUNT, SEQUENCE, логирование, EXCEPTION |
| 8 | [08_trigger_ddl_audit.sql](08_trigger_ddl_audit.sql) | Аудит создания и удаления таблиц, запрет в рабочее время | DDL-триггер на CREATE/DROP, автономная транзакция, RAISE_APPLICATION_ERROR |

## Структура каждого файла

В начале каждого файла — комментарий с описанием:

- **Задача** — что требовалось сделать;
- **Таблицы** — с какими данными идёт работа;
- **Приёмы** — какие возможности SQL использованы;
- **Результат** — что получается на выходе.
