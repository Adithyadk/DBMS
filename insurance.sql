CREATE DATABASE P2;
USE P2;

CREATE TABLE person (
driver_id VARCHAR(25) PRIMARY KEY,
driver_name VARCHAR(25),
address VARCHAR(25)
);

CREATE TABLE car (
reg_no VARCHAR(25) PRIMARY KEY,
model VARCHAR(25),
c_year YEAR
);

CREATE TABLE accident (
report_no INT PRIMARY KEY,
acc_date DATE,
loc VARCHAR(25)
);

CREATE TABLE owns (
driver_id VARCHAR(25),
reg_no VARCHAR(25),
FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE SET NULL,
FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE SET NULL
);

CREATE TABLE participated (
driver_id VARCHAR(25),
reg_no VARCHAR(25),
report_no INT,
damage_amount DECIMAL(10,2),
FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE SET NULL,
FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE SET NULL,
FOREIGN KEY (report_no) REFERENCES accident(report_no) ON DELETE SET NULL
);

INSERT INTO person VALUES
("D111", "Driver_1", "Kuvempunagar, Mysuru"),
("D222", "Smith", "JP Nagar, Mysuru"),
("D333", "Driver_3", "Udaygiri, Mysuru"),
("D444", "Driver_4", "Rajivnagar, Mysuru"),
("D555", "Driver_5", "Vijayanagar, Mysore");

INSERT INTO car VALUES
("KA-20-AB-4223", "Swift", 2020),
("KA-20-BC-5674", "Mazda", 2017),
("KA-21-AC-5473", "Alto", 2015),
("KA-21-BD-4728", "Triber", 2019),
("KA-09-MA-1234", "Tiago", 2018);

INSERT INTO accident VALUES
(43627, "2020-04-05", "Nazarbad, Mysuru"),
(56345, "2019-12-16", "Gokulam, Mysuru"),
(63744, "2020-05-14", "Vijaynagar, Mysuru"),
(54634, "2019-08-30", "Kuvempunagar, Mysuru"),
(65738, "2021-01-21", "JSS Layout, Mysuru"),
(66666, "2021-01-21", "JSS Layout, Mysuru");

INSERT INTO owns VALUES
("D111", "KA-20-AB-4223"),
("D222", "KA-20-BC-5674"),
("D333", "KA-21-AC-5473"),
("D444", "KA-21-BD-4728"),
("D222", "KA-09-MA-1234");

INSERT INTO participated VALUES
("D111", "KA-20-AB-4223", 43627, 20000),
("D222", "KA-20-BC-5674", 56345, 49500),
("D333", "KA-21-AC-5473", 63744, 15000),
("D444", "KA-21-BD-4728", 54634, 5000),
("D222", "KA-09-MA-1234", 65738, 25000);

-- 1.Find the total number of people who owned cars that were involved in accidents in 2021. 

select COUNT(DISTINCT driver_id) 
from participated 
join owns using(driver_id)
join accident using(report_no) 
where acc_date LIKE "2021%";

-- 2.Find the number of accidents in which the cars belonging to “Smith” were involved. 

SELECT COUNT(*)
FROM participated 
WHERE driver_id IN (
	SELECT driver_id FROM 
    person WHERE driver_name LIKE "%smith%");

-- OR --

SELECT COUNT(*)
FROM participated 
JOIN person USING (driver_id)
WHERE driver_name LIKE "%smith%";

-- 3.Add a new accident to the database; assume any values for required attributes. 
insert into accident values
(45562, "2024-04-05", "Mandya");

insert into participated values
("D222", "KA-21-BD-4728", 45562, 50000);


-- 4.Delete the Mazda belonging to “Smith”.

DELETE FROM car
WHERE model LIKE 'Mazda' AND 
reg_no IN(SELECT reg_no FROM owns JOIN person USING (driver_id) WHERE driver_name LIKE "smith");

-- 5.Update the damage amount for the car with license number “KA09MA1234” in the accident with report number 65738.
 
UPDATE participated 
SET damage_amount=750000 
WHERE reg_no="KA-09-MA-1234" AND report_no=65738;
 
-- 6.A view that shows models and year of cars that are involved in accident. 

create view Accident_Cars as
select model,c_year from car
where reg_no in (select reg_no from participated);

select * from Accident_Cars;

-- OR --
-- create view Accident_Cars as
-- select model,c_year from car
-- join participated using (reg_no) 
-- join accident using (report_no);

-- 7.A trigger that prevents a driver from participating in more than 2 accidents in a given year.

delimiter //
create trigger Prevent_Accident
before insert 
on participated
for each row 
begin
if ( (select count(driver_id) 
      from participated 
      join accident using(report_no) 
	  where driver_id=NEW.driver_id and year(acc_date) in 
			(select year(acc_date) from accident 
			 where report_no=NEW.report_no) ) =2) then
	SIGNAL SQLSTATE '45000' 
	SET MESSAGE_TEXT='Driver in 2 accidents';
end if;
end;//
delimiter ;


-- checking trigger
INSERT INTO participated VALUES
("D222", "KA-20-AB-4223", 66666, 20000);
