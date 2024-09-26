-- Name: Abdullah Alshamrani
-- Data: 09/23/2024

-- *************************************************************
-- Using restaurantDB Database
-- *************************************************************


use restaurantDB;

-- *************************************************************
-- PART 1
-- *************************************************************


-- *************************************************************
-- Creating Chefs Table
-- *************************************************************
create table chefs (
    chefID int primary key,
    name varchar(50),
    specialty varchar(50)
);


-- *************************************************************
-- Creating restaurants tables
-- *************************************************************
create table restaurants (
    restID int primary key,
    name varchar(50),
    location varchar(50)
);


-- *************************************************************
-- Creating works tables
-- *************************************************************
create table works (
    chefID int,
    restID int,
    primary key (chefID, restID),
    foreign key (chefID) references chefs(chefID),
    foreign key (restID) references restaurants(restID)
);


-- *************************************************************
-- Creating foods tables
-- *************************************************************
create table foods (
    foodID int primary key,
    name varchar(50),
    type varchar(50),
    price decimal(5, 2)
);


-- *************************************************************
-- Creating serves tables
-- *************************************************************
create table serves (
    restID int,
    foodID int,
    date_sold date,
    primary key (restID, foodID, date_sold),
    foreign key (restID) references restaurants(restID),
    foreign key (foodID) references foods(foodID)
);




-- *********************************************************************************************
-- PART 2
-- *********************************************************************************************



-- *************************************************************
-- Average Price of Foods at Each Restaurant
-- *************************************************************
SELECT r.name AS "Restaurant", 
       FORMAT(AVG(f.price), 2) AS "Average Price"
FROM   restaurants r
JOIN   serves s ON r.restID = s.restID
JOIN   foods f ON s.foodID = f.foodID
GROUP  BY r.name
ORDER  BY "Average Price";


-- *************************************************************
-- Maximum Food Price at Each Restaurant
-- *************************************************************
SELECT r.name AS "Restaurant", 
       max(f.price) AS "Max Price"
FROM   restaurants r
JOIN   serves s ON r.restID = s.restID
JOIN   foods f ON s.foodID = f.foodID
GROUP  BY r.name
ORDER  BY "Max Price" DESC;


-- *************************************************************
-- Count of Different Food Types Served at Each Restaurant
-- *************************************************************
SELECT r.name AS "Restaurant", 
       count(DISTINCT f.type) AS "Food Types"
FROM   restaurants r
JOIN   serves s ON r.restID = s.restID
JOIN   foods f ON s.foodID = f.foodID
GROUP  BY r.name
ORDER  BY "Food Types" DESC;


-- *************************************************************
-- Average Price of Foods Served by Each Chef
-- *************************************************************
SELECT c.name AS "Chef", 
       FORMAT(AVG(f.price), 2) AS "Average Price"
FROM   chefs c
JOIN   works w ON c.chefID = w.chefID
JOIN   serves s ON w.restID = s.restID
JOIN   foods f ON s.foodID = f.foodID
GROUP  BY c.name
ORDER  BY "Average Price";


-- *************************************************************
-- Restaurant with the Highest Average Food Price
-- *************************************************************
SELECT r.name AS "Restaurant", 
       FORMAT(AVG(f.price), 2) AS "Average Price"
FROM   restaurants r
JOIN   serves s ON r.restID = s.restID
JOIN   foods f ON s.foodID = f.foodID
GROUP  BY r.name
ORDER  BY AVG(f.price) DESC
LIMIT 1;


-- *************************************************************
-- Extra Credit
-- *************************************************************
SELECT c.name AS "Chef", 
       FORMAT(AVG(f.price), 2) AS "Average Price", 
       GROUP_CONCAT(DISTINCT r.name ORDER BY r.name) AS "Restaurants"
FROM   chefs c
JOIN   works w ON c.chefID = w.chefID
JOIN   restaurants r ON w.restID = r.restID
JOIN   serves s ON r.restID = s.restID
JOIN   foods f ON s.foodID = f.foodID
GROUP  BY c.name
ORDER  BY AVG(f.price) DESC;

