CREATE DATABASE P1;

USE P1;

CREATE TABLE sailors(
sid INT PRIMARY KEY,
sname VARCHAR (30),
rating INT,
age INT);

CREATE TABLE boat(
bid INT PRIMARY KEY,
bname VARCHAR(30),
color VARCHAR(15));

CREATE TABLE rservers(
sid INT ,
bid INT,
date DATE,
FOREIGN KEY (sid) REFERENCES sailors(sid),
FOREIGN KEY (bid) REFERENCES boat(bid));

INSERT INTO sailors VALUES
(31,'Albert',7,45),
(32,'Victor',9,50),
(33,'Stormy',10,35),
(34,'Mandy',8,28),
(35,'Randy',6,25),
(36,'NeelAmstormg',9,47);
 
INSERT INTO boat VALUES
(101,'Boat-1','Green'),
(102,'Boat-2','Red'),
(103,'Boat-3','Blue'),
(104,'Boat-4','Grey'),
(105,'Boat-5','White');


INSERT INTO rservers VALUES
(31,101,'2023-11-25'),
(31,103,'2023-08-30'),
(31,105,'2023-12-22'),
(32,102,'2023-11-17'),
(32,104,'2023-08-17'),
(32,105,'2023-10-17'),
(33,102,'2023-12-10'),
(33,101,'2023-12-22'),
(34,102,'2023-12-22');

SELECT * FROM sailors;

SELECT * FROM boat;

SELECT * FROM rservers;

-- 1.Find the colours of boats reserved by Albert
SELECT color
FROM boat
WHERE bid IN(
	SELECT bid
    FROM rservers 
    WHERE sid IN(
    SELECT sid 
    FROM sailors
    WHERE sname LIKE 'Albert'));
    
-- 2.Find all sailor id’s of sailors who have a rating of at least 8 or reserved boat 103
SELECT sid
FROM sailors 
WHERE rating>=8 OR sid IN(
	 SELECT sid 
     FROM rservers
     WHERE bid=103);
     
-- 3.Find the names of sailors who have not reserved a boat whose name contains the string “storm”. Order the names in ascending order.
SELECT sname 
FROM sailors 
WHERE sid NOT IN (
	SELECT sid FROM rservers 
    WHERE bid IN(
		SELECT bid 
        FROM boat where bname LIKE '%storm%'));
    
-- 4.Find the names of sailors who have reserved all boats. 
select sname from sailors s where not exists
	(select * from boat b where not exists
		(select * from rservers r where r.sid=s.sid and b.bid=r.bid));
        

INSERT INTO rservers VALUES
(31,102,'2023-10-01'),
(31,104,'2023-11-01');

-- 5.Find the name and age of the oldest sailor. 
SELECT sname,age
FROM sailors 
WHERE age =(
	SELECT MAX(age)
    FROM sailors);


-- 6.For each boat which was reserved by at least 5 sailors with age >= 40, find the boat id and the average age of such sailors.
select b.bid, avg(s.age) as average_age
from boat AS b 
JOIN rservers AS r USING (bid)
JOIN sailors AS s USING (sid)
WHERE age>=40
GROUP BY bid
HAVING COUNT(bid)>=2;

-- 7.Create a view that shows the names and colours of all the boats that have been reserved by a sailor with a specific rating.
create view specific_rating as
SELECT DISTINCT bname, color
FROM rservers
JOIN boat b USING (bid)
JOIN sailors s USING (sid)
WHERE rating=10;

select * from specific_rating;

-- 8.Trigger that prevents boats from being deleted if they have active reservation

DELIMITER //
create trigger CheckAndDelete
before delete on boat
for each row
BEGIN
	IF EXISTS (select * from rservers where rservers.bid=old.bid) THEN
		SIGNAL SQLSTATE '45000' SET message_text='Boat is reserved and hence cannot be deleted';
	END IF;
END;//

DELIMITER ;

DELETE FROM boat
WHERE bid =103;
