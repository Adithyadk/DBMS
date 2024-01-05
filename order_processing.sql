create database order_process;
use order_process;

create table  customers (
cust_id int primary key,
cname varchar(35),
city varchar(35)
);

create table orders (
order_id int primary key,
odate date,
cust_id int,
order_amt DECIMAL (10,2),
foreign key (cust_id) references Customers(cust_id) on delete SET NULL
);

create table items (
item_id  int primary key,
unitprice DECIMAL (10,2)
);

create table orderitems (
order_id int,
item_id int,
qty DECIMAL(10,2),
foreign key (order_id) references orders(order_id) on delete SET NULL,
foreign key (item_id) references Items(item_id) on delete SET NULL
);

create table warehouses (
warehouse_id int primary key,
city varchar(35) 
);

create table shipments (
order_id int,
warehouse_id int,
ship_date date ,
foreign key (order_id) references orders(order_id) on delete SET NULL,
foreign key (warehouse_id) references warehouses(warehouse_id) on delete SET NULL
);

INSERT INTO customers VALUES
(0001, "Customer_1", "Mysuru"),
(0002, "Customer_2", "Bengaluru"),
(0003, "Kumar", "Mumbai"),
(0004, "Customer_4", "Dehli"),
(0005, "Customer_5", "Bengaluru");

INSERT INTO orders VALUES
(001, "2020-01-14", 0001, 2000),
(002, "2021-04-13", 0002, 500),
(003, "2019-10-02", 0003, 2500),
(004, "2019-05-12", 0005, 1000),
(005, "2020-12-23", 0004, 1200);

INSERT INTO items VALUES
(0001, 400),
(0002, 200),
(0003, 1000),
(0004, 100),
(0005, 500);

INSERT INTO warehouses VALUES
(0001, "Mysuru"),
(0002, "Bengaluru"),
(0003, "Mumbai"),
(0004, "Dehli"),
(0005, "Chennai");

INSERT INTO orderitems VALUES 
(001, 0001, 5),
(002, 0005, 1),
(003, 0005, 5),
(004, 0003, 1),
(005, 0004, 12);

INSERT INTO shipments VALUES
(001, 0002, "2020-01-16"),
(002, 0001, "2021-04-14"),
(003, 0004, "2019-10-07"),
(004, 0003, "2019-05-16"),
(005, 0005, "2020-12-23");

-- 1.List the Order# and Ship_date for all orders shipped from Warehouse# "W2". 

SELECT order_id,ship_date
FROM shipments 
WHERE warehouse_id=2; 

-- 2.List the Warehouse information from which the Customer named "Kumar" was supplied his orders. Produce a listing of Order#, Warehouse#. 

SELECT *
FROM  warehouses
JOIN shipments USING (warehouse_id)
JOIN orders USING (order_id)
JOIN customers USING (cust_id)
WHERE cname LIKE 'kumar';

-- 3.Produce a listing: Cname, #ofOrders, Avg_Order_Amt, where the middle column is the total number of orders by the customer and 
--   the last column is the average order amount for that customer. (Use aggregate functions) 

SELECT cname,COUNT(*) AS 'Total No. Orders',Avg(order_amt) AS 'Avg Order Amt.'
FROM orders
JOIN customers USING(cust_id)
GROUP BY cname;

-- 4.Delete all orders for customer named "Kumar". 

DELETE 
FROM orders
WHERE cust_id =(SELECT cust_id FROM customers WHERE cname LIKE "%kumar%");

-- 5.Find the item with the maximum unit price. 

SELECT * 
FROM items 
WHERE unitprice IN (SELECT MAX(unitprice) FROM items);

-- 6.A trigger that updates order_amout based on quantity and unitprice of order_item

create trigger total_amt
after insert on orderitems
for each row update orders set order_amt=(select unitprice from items where item_id=NEW.item_id)*NEW.qty where order_id=NEW.order_id;

-- check trigger

INSERT INTO Orders VALUES
(006, "2020-12-23", 0003,1200);

INSERT INTO OrderItems VALUES 
(006,0003,9); 

SELECT * FROM Orders;
-- 7.Create a view to display orderID and shipment date of all orders shipped from a warehouse 5.

create view WareHouse5_Details as
select order_id,ship_date
from shipments
where warehouse_id=5;

SELECT * FROM WareHouse5_Details;
