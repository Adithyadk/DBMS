create database enrollment;
use enrollment;

create table student(
regno varchar(13) primary key,
name varchar(25) ,
major varchar(25),
bdate date 
);

create table course(
course int primary key,
cname varchar(30) ,
dept varchar(100) 
);

create table enroll(
regno varchar(13),
course int,
sem int,
marks int,
foreign key(regno) references Student(regno) on delete SET NULL,
foreign key(course) references Course(course) on delete SET NULL
);

create table textBook(
bookIsbn int primary key,
book_title varchar(40) ,
publisher varchar(25) ,
author varchar(25)
);

create table bookadoption(
course int,
sem int ,
bookIsbn int,
foreign key(bookIsbn) references TextBook(bookIsbn) on delete SET NULL,
foreign key(course) references Course(course) on delete SET NULL
);

INSERT INTO student VALUES
("01HF235", "Student_1", "CSE", "2001-05-15"),
("01HF354", "Student_2", "Literature", "2002-06-10"),
("01HF254", "Student_3", "Philosophy", "2000-04-04"),
("01HF653", "Student_4", "History", "2003-10-12"),
("01HF234", "Student_5", "Computer Economics", "2001-10-10");

INSERT INTO course VALUES
(001, "DBMS", "CS"),
(002, "Literature", "English"),
(003, "Philosophy", "Philosphy"),
(004, "History", "Social Science"),
(005, "Computer Economics", "CS");

INSERT INTO enroll VALUES
("01HF235", 001, 5, 85),
("01HF354", 002, 6, 87),
("01HF254", 003, 3, 95),
("01HF653", 004, 3, 80),
("01HF234", 005, 5, 75);

INSERT INTO textBook VALUES
(241563, "Operating Systems", "Pearson", "Silberschatz"),
(532678, "Complete Works of Shakesphere", "Oxford", "Shakesphere"),
(453723, "Immanuel Kant", "Delphi Classics", "Immanuel Kant"),
(278345, "History of the world", "The Times", "Richard Overy"),
(426784, "Behavioural Economics", "Pearson", "David Orrel");

INSERT INTO bookadoption VALUES
(001, 5, 241563),
(002, 6, 532678),
(003, 3, 453723),
(004, 3, 278345),
(001, 6, 426784);


-- 1.Demonstrate how you add a new text book to the database and make this book be adopted by some department.
insert into textBook values
(123456, "Adi The Autobiography", "Pearson", "Adithya");

insert into bookadoption values
(001, 5, 123456);
 
-- 2.Produce a list of text books (include Course #, Book-ISBN, Book-title) in the alphabetical order for courses offered by the ‘CS’ department that use more than two books. 

select b.course,t.bookIsbn,t.book_title
from bookadoption b
join textbook t using(bookIsbn)
join course c using(course)
where c.dept='CS'
AND ( SELECT COUNT(bookIsbn) FROM BookAdoption b) > 2
ORDER BY t.book_title;

-- 3.List any department that has all its adopted books published by a specific publisher. 

SELECT DISTINCT C.dept
FROM Course C
WHERE NOT EXISTS (
    SELECT B.course
    FROM BookAdoption B
    JOIN TextBook T USING(bookIsbn)
    WHERE B.course = C.course
      AND T.publisher <> 'Pearson'
);



-- 4. List the students who have scored maximum marks in ‘DBMS’ course. 

select s.name from student s
join enroll e using(regno)
join course c using (course)
where marks in ( select max(marks) from enroll where course in (select course from course where cname='DBMS'));

-- 5. Create a view to display all the courses opted by a student along with marks obtained.
create view Student_Details as 
select c.cname,e.marks
from course c 
join enroll e using(course)
where e.regno="01HF235";

select * from Student_Details;


-- 6.Create a trigger that prevents a student from enrolling in a course if the marks prerequisite is less than 10.

DELIMITER //
create trigger PreventEnrollment
before insert on Enroll
for each row
BEGIN
	IF (new.marks<10) THEN
		signal sqlstate '45000' set message_text='Marks below threshold';
	END IF;
END;//

DELIMITER ;

INSERT INTO Enroll VALUES
("01HF235", 002, 5, 5); -- Gives error since marks is less than 10
