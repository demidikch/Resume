/*
 Задача:     Спроектировать базу данных свиноводческой фермы: склады кормов,
             оборудование, ангары и их секторы, сотрудники, животные,
             доступ сотрудников к складам. ER-диаграмма: 01_pig_farm_er_diagram.png
 Таблицы:    storehouse, farm_worker, equipment, hangar_svinarnik,
             hangar_sector, pig, ac_se
 Приёмы:     CREATE TABLE, PRIMARY KEY, FOREIGN KEY, составной ключ
             (связь «многие ко многим»), INSERT
 Результат:  нормализованная схема из 7 связанных таблиц с тестовыми данными
 СУБД:       Oracle
*/


-- 1. Склады кормов
CREATE TABLE storehouse (
    id_storehouse     NUMBER PRIMARY KEY,
    pig_feed          VARCHAR2(50),
    capacity          NUMBER,
    building_area     NUMBER,
    number_of_floors  NUMBER
);

INSERT INTO storehouse VALUES (1, 'Ростовой',          200,  8, 2);
INSERT INTO storehouse VALUES (2, 'Комбикорм',         300, 11, 3);
INSERT INTO storehouse VALUES (3, 'Гранулированный',   350, 15, 4);
INSERT INTO storehouse VALUES (4, 'Концентрированный', 330, 13, 4);
INSERT INTO storehouse VALUES (5, 'Сухой',              50,  5, 1);


-- 2. Сотрудники фермы
CREATE TABLE farm_worker (
    pass_nomer     NUMBER PRIMARY KEY,
    full_name      VARCHAR2(100),
    date_of_birth  DATE,
    phone_number   VARCHAR2(30),
    job_f          VARCHAR2(30)
);

INSERT INTO farm_worker VALUES (1, 'Иванов Иван Иванович',     DATE '1978-12-23', '89436272627',     'ветеринар');
INSERT INTO farm_worker VALUES (2, 'Смирнов Сергей Игоревич',  DATE '1982-06-19', '+78927372803',    'свиновод');
INSERT INTO farm_worker VALUES (3, 'Петров Петр Петрович',     DATE '1985-05-09', '8(923)3491827',   'кормовед');
INSERT INTO farm_worker VALUES (4, 'Васильев Вадим Сидорович', DATE '1990-01-29', '8-192-456-32-90', 'разнорабочий');
INSERT INTO farm_worker VALUES (5, 'Егоров Данил Эдуардович',  DATE '1970-09-22', '89284736589',     'зоотехник');


-- 3. Оборудование (хранится на складах)
CREATE TABLE equipment (
    id_eq        NUMBER PRIMARY KEY,
    destination  VARCHAR2(30),
    price        NUMBER,
    storehouses  NUMBER,
    useful_life  NUMBER,
    CONSTRAINT storehouses_fk FOREIGN KEY (storehouses)
        REFERENCES storehouse (id_storehouse)
);

INSERT INTO equipment VALUES (1, 'поилка',     1000, 1,  2);
INSERT INTO equipment VALUES (2, 'кормушка',   1500, 2,  3);
INSERT INTO equipment VALUES (3, 'станок',     2500, 3,  5);
INSERT INTO equipment VALUES (4, 'вентиляция', 1000, 4, 10);
INSERT INTO equipment VALUES (5, 'освещение',  1000, 5,  1);


-- 4. Ангары (у каждого есть ответственный сотрудник)
CREATE TABLE hangar_svinarnik (
    building_nomer  NUMBER PRIMARY KEY,
    building_area   NUMBER,
    purpose         VARCHAR2(30),
    wall_material   VARCHAR2(30),
    manager         NUMBER,
    CONSTRAINT manager_fk FOREIGN KEY (manager)
        REFERENCES farm_worker (pass_nomer)
);

INSERT INTO hangar_svinarnik VALUES (1, 15, 'склад',       'кирпич',      1);
INSERT INTO hangar_svinarnik VALUES (2, 10, 'моечная',     'дерево',      2);
INSERT INTO hangar_svinarnik VALUES (3, 20, 'откормочник', 'гипсокартон', 3);
INSERT INTO hangar_svinarnik VALUES (4, 13, 'свинобойня',  'газосиликат', 4);
INSERT INTO hangar_svinarnik VALUES (5, 17, 'инвентарная', 'бетон',       5);


-- 5. Секторы ангаров
CREATE TABLE hangar_sector (
    sector_nomer        NUMBER PRIMARY KEY,
    type_s              VARCHAR2(50),
    hangar              NUMBER,
    responsible_worker  NUMBER,
    equipment           NUMBER,
    CONSTRAINT hangar_fk FOREIGN KEY (hangar)
        REFERENCES hangar_svinarnik (building_nomer),
    CONSTRAINT responsible_worker_fk FOREIGN KEY (responsible_worker)
        REFERENCES farm_worker (pass_nomer),
    CONSTRAINT equipment_fk FOREIGN KEY (equipment)
        REFERENCES equipment (id_eq)
);

INSERT INTO hangar_sector VALUES (1, 'рабочий',          1, 1, 1);
INSERT INTO hangar_sector VALUES (2, 'производственный', 2, 2, 2);
INSERT INTO hangar_sector VALUES (3, 'выращивание',      3, 3, 3);
INSERT INTO hangar_sector VALUES (4, 'убой',             4, 4, 4);
INSERT INTO hangar_sector VALUES (5, 'производственный', 5, 5, 5);


-- 6. Животные (закреплены за сектором)
CREATE TABLE pig (
    id_nomer       NUMBER PRIMARY KEY,
    breed          VARCHAR2(30),
    date_of_birth  DATE,
    weight         NUMBER,
    sector         NUMBER,
    CONSTRAINT sector_fk FOREIGN KEY (sector)
        REFERENCES hangar_sector (sector_nomer)
);

INSERT INTO pig VALUES (1, 'брейтовая',       DATE '2022-10-12', 5.5, 1);
INSERT INTO pig VALUES (2, 'гемпширская',     DATE '2022-04-10', 7,   2);
INSERT INTO pig VALUES (3, 'линкольнширская', DATE '2021-03-03', 3.6, 3);
INSERT INTO pig VALUES (4, 'мангалица',       DATE '2022-01-09', 2.7, 4);
INSERT INTO pig VALUES (5, 'пьетрен',         DATE '2021-05-11', 1.8, 5);


-- 7. Доступ сотрудников к складам (связь «многие ко многим»)
CREATE TABLE ac_se (
    pass_nomer        NUMBER,
    storehouse_nomer  NUMBER,
    CONSTRAINT ac_se_pk PRIMARY KEY (pass_nomer, storehouse_nomer),
    CONSTRAINT farm_worker_ac_se_fk FOREIGN KEY (pass_nomer)
        REFERENCES farm_worker (pass_nomer),
    CONSTRAINT storehouse_ac_se_fk FOREIGN KEY (storehouse_nomer)
        REFERENCES storehouse (id_storehouse)
);

INSERT INTO ac_se VALUES (1, 1);
INSERT INTO ac_se VALUES (2, 2);
INSERT INTO ac_se VALUES (3, 3);
INSERT INTO ac_se VALUES (4, 4);
INSERT INTO ac_se VALUES (5, 5);

COMMIT;
