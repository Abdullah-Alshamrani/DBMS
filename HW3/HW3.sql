-- Name: Abdullah Alshamrani
-- Date: 10/07/2024

USE DB_Assignment3;

-- *************************************************************
-- PART 1 - Creating Tables: Merchents, Products, Orders, Contains, Customer, Place
-- *************************************************************

CREATE TABLE merchants (
    mid INT PRIMARY KEY,
    name VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50)
);

CREATE TABLE products (
    pid INT PRIMARY KEY,
    name VARCHAR(50),
    category ENUM('Peripheral', 'Networking', 'Computer'),
    description VARCHAR(255)
);

CREATE TABLE sell (
    mid INT,
    pid INT,
    price DECIMAL(10, 2) CHECK(price BETWEEN 0 AND 100000),
    quantity_available INT CHECK(quantity_available BETWEEN 0 AND 1000),
    PRIMARY KEY (mid, pid),
    FOREIGN KEY (mid) REFERENCES merchants(mid),
    FOREIGN KEY (pid) REFERENCES products(pid)
);

CREATE TABLE orders (
    oid INT PRIMARY KEY,
    shipping_method ENUM('UPS', 'FedEx', 'USPS'),
    shipping_cost DECIMAL(6, 2) CHECK(shipping_cost BETWEEN 0 AND 500)
);

CREATE TABLE contain (
    oid INT,
    pid INT,
    PRIMARY KEY (oid, pid),
    FOREIGN KEY (oid) REFERENCES orders(oid),
    FOREIGN KEY (pid) REFERENCES products(pid)
);

CREATE TABLE customers (
    cid INT PRIMARY KEY,
    fullname VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50)
);

CREATE TABLE place (
    cid INT,
    oid INT,
    order_date DATE,
    PRIMARY KEY (cid, oid),
    FOREIGN KEY (cid) REFERENCES customers(cid),
    FOREIGN KEY (oid) REFERENCES orders(oid)
);


-- *************************************************************
-- PART 2 - SQL Queries
-- *************************************************************

SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

/* ******************************************************************
   1. List names and sellers of products that are no longer available (quantity=0)
************************************************************************** */
SELECT products.name AS product_name, merchants.name AS seller_name
FROM products
JOIN sell ON products.pid = sell.pid
JOIN merchants ON merchants.mid = sell.mid
WHERE sell.quantity_available = 0;


/* ******************************************************************
   2. List names and descriptions of products that are not sold
************************************************************************** */
SELECT name, description 
FROM products
WHERE pid NOT IN (SELECT pid FROM sell);


/* ******************************************************************
   3. How many customers bought SATA drives but not any routers?
************************************************************************** */
SELECT COUNT(DISTINCT place.cid) AS num_customers
FROM contain
JOIN products ON contain.pid = products.pid
JOIN place ON contain.oid = place.oid
WHERE products.name LIKE '%SATA%' 
AND products.pid NOT IN (SELECT pid FROM products WHERE name LIKE '%Router%');


/* ******************************************************************
   4. HP has a 20% sale on all its Networking products
************************************************************************** */
UPDATE sell
JOIN products ON sell.pid = products.pid
SET sell.price = sell.price * 0.8
WHERE products.category = 'Networking' 
AND products.name LIKE 'HP%';


/* ******************************************************************
   5. What did Uriel Whitney order from Acer? 
      (retrieve product names and prices)
************************************************************************** */
SELECT products.name AS product_name, sell.price
FROM customers
JOIN place ON customers.cid = place.cid
JOIN contain ON place.oid = contain.oid
JOIN products ON contain.pid = products.pid
JOIN sell ON products.pid = sell.pid
JOIN merchants ON sell.mid = merchants.mid
WHERE customers.fullname = 'Uriel Whitney'
AND merchants.name = 'Acer';


/* ******************************************************************
   6. List the annual total sales for each company
************************************************************************** */
SELECT merchants.name AS company_name, YEAR(place.order_date) AS year,
       SUM(sell.price * sell.quantity_available) AS total_sales
FROM place
JOIN contain ON place.oid = contain.oid
JOIN sell ON contain.pid = sell.pid
JOIN merchants ON sell.mid = merchants.mid
GROUP BY merchants.name, year
ORDER BY merchants.name, year;



/* ******************************************************************
   7. Which company had the highest annual revenue and in what year?
************************************************************************** */
SELECT merchants.name AS company_name, 
       YEAR(place.order_date) AS year, 
       SUM(sell.price * sell.quantity_available) AS total_sales
FROM place
JOIN contain ON place.oid = contain.oid
JOIN sell ON contain.pid = sell.pid
JOIN merchants ON sell.mid = merchants.mid
GROUP BY merchants.name, year
ORDER BY total_sales DESC
LIMIT 1;


/* ******************************************************************
   8. On average, what was the cheapest shipping method used ever?
************************************************************************** */
SELECT shipping_method, AVG(shipping_cost) AS avg_cost
FROM orders
GROUP BY shipping_method
ORDER BY avg_cost ASC
LIMIT 1;


/* ******************************************************************
   9. What is the best sold ($) category for each company?
************************************************************************** */
SELECT merchants.name AS company_name, products.category,
       SUM(sell.price * sell.quantity_available) AS total_sales
FROM merchants
JOIN sell ON merchants.mid = sell.mid
JOIN products ON sell.pid = products.pid
JOIN contain ON products.pid = contain.pid
GROUP BY merchants.name, products.category
ORDER BY total_sales DESC;


/* ******************************************************************
   10. For each company, find out which customers have spent the most and the least amounts
************************************************************************** */
SELECT merchants.name AS company_name, customers.fullname, 
       SUM(sell.price * sell.quantity_available) AS total_spent
FROM merchants
JOIN sell ON merchants.mid = sell.mid
JOIN contain ON sell.pid = contain.pid
JOIN place ON contain.oid = place.oid
JOIN customers ON place.cid = customers.cid
GROUP BY merchants.name, customers.fullname
ORDER BY merchants.name, total_spent DESC;