-- Abdullah Alshamrani
-- 10/30/2024
USE HW4;

-- *************************************************************
-- Create 'actor' table
-- *************************************************************
CREATE TABLE actor (
    actor_id INT PRIMARY KEY,
    first_name VARCHAR(45),
    last_name VARCHAR(45)
);

-- *************************************************************
-- Create 'address' table
-- *************************************************************
CREATE TABLE address (
    address_id INT PRIMARY KEY,
    address VARCHAR(50),
    address2 VARCHAR(50),
    district VARCHAR(20),
    city_id INT,
    postal_code VARCHAR(10),
    phone VARCHAR(20),
    FOREIGN KEY (city_id) REFERENCES city(city_id)
);

-- *************************************************************
-- Create 'category' table
-- *************************************************************
CREATE TABLE category (
    category_id INT PRIMARY KEY,
    name VARCHAR(25) UNIQUE CHECK (
        name IN ('Animation', 'Comedy', 'Family', 'Foreign', 'Sci-Fi', 'Travel', 
                 'Children', 'Drama', 'Horror', 'Action', 'Classics', 'Games', 
                 'New', 'Documentary', 'Sports', 'Music')
    )
);

-- *************************************************************
-- Create 'city' table
-- *************************************************************
CREATE TABLE city (
    city_id INT PRIMARY KEY,
    city VARCHAR(50),
    country_id INT,
    FOREIGN KEY (country_id) REFERENCES country(country_id)
);

-- *************************************************************
-- Create 'country' table
-- *************************************************************
CREATE TABLE country (
    country_id INT PRIMARY KEY,
    country VARCHAR(50)
);

-- *************************************************************
-- Create 'customer' table
-- *************************************************************
CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    store_id INT,
    first_name VARCHAR(45),
    last_name VARCHAR(45),
    email VARCHAR(50),
    address_id INT,
    active INT CHECK (active IN (0, 1)),
    FOREIGN KEY (store_id) REFERENCES store(store_id),
    FOREIGN KEY (address_id) REFERENCES address(address_id)
);

-- *************************************************************
-- Create 'film' table
-- *************************************************************
CREATE TABLE film (
    film_id INT PRIMARY KEY,
    title VARCHAR(100),
    description TEXT,
    release_year INT,
    language_id INT,
    rental_duration INT CHECK (rental_duration BETWEEN 2 AND 8),
    rental_rate DECIMAL(4,2) CHECK (rental_rate BETWEEN 0.99 AND 6.99),
    length INT CHECK (length BETWEEN 30 AND 200),
    replacement_cost DECIMAL(5,2) CHECK (replacement_cost BETWEEN 5.00 AND 100.00),
    rating VARCHAR(5) CHECK (rating IN ('PG', 'G', 'NC-17', 'PG-13', 'R')),
    special_features VARCHAR(100) CHECK (
        special_features IN ('Behind the Scenes', 'Commentaries', 'Deleted Scenes', 'Trailers')
    ),
    FOREIGN KEY (language_id) REFERENCES language(language_id)
);

-- *************************************************************
-- Create 'film_actor' table
-- *************************************************************
CREATE TABLE film_actor (
    actor_id INT,
    film_id INT,
    PRIMARY KEY (actor_id, film_id),
    FOREIGN KEY (actor_id) REFERENCES actor(actor_id),
    FOREIGN KEY (film_id) REFERENCES film(film_id)
);

-- *************************************************************
-- Create 'film_category' table
-- *************************************************************
CREATE TABLE film_category (
    film_id INT,
    category_id INT,
    PRIMARY KEY (film_id, category_id),
    FOREIGN KEY (film_id) REFERENCES film(film_id),
    FOREIGN KEY (category_id) REFERENCES category(category_id)
);

-- *************************************************************
-- Create 'inventory' table
-- *************************************************************
CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY,
    film_id INT,
    store_id INT,
    FOREIGN KEY (film_id) REFERENCES film(film_id),
    FOREIGN KEY (store_id) REFERENCES store(store_id)
);

-- *************************************************************
-- Create 'language' table
-- *************************************************************
CREATE TABLE language (
    language_id INT PRIMARY KEY,
    name VARCHAR(20)
);

-- *************************************************************
-- Create 'payment' table
-- *************************************************************
CREATE TABLE payment (
    payment_id INT PRIMARY KEY,
    customer_id INT,
    staff_id INT,
    rental_id INT,
    amount DECIMAL(5,2) CHECK (amount >= 0),
    payment_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (rental_id) REFERENCES rental(rental_id)
);

-- *************************************************************
-- Create 'rental' table
-- *************************************************************
CREATE TABLE rental (
    rental_id INT PRIMARY KEY,
    rental_date DATE,
    inventory_id INT,
    customer_id INT,
    return_date DATE,
    staff_id INT,
    FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

-- *************************************************************
-- Create 'staff' table
-- *************************************************************
CREATE TABLE staff (
    staff_id INT PRIMARY KEY,
    first_name VARCHAR(45),
    last_name VARCHAR(45),
    address_id INT,
    email VARCHAR(50),
    store_id INT,
    active INT CHECK (active IN (0, 1)),
    username VARCHAR(16),
    password VARCHAR(40),
    FOREIGN KEY (address_id) REFERENCES address(address_id),
    FOREIGN KEY (store_id) REFERENCES store(store_id)
);

-- *************************************************************
-- Create 'store' table
-- *************************************************************
CREATE TABLE store (
    store_id INT PRIMARY KEY,
    address_id INT,
    FOREIGN KEY (address_id) REFERENCES address(address_id)
);


-- *************************************************************
-- Average length of films in each category, ordered alphabetically
-- *************************************************************
SELECT   c.name AS "Category Name", 
         ROUND(AVG(f.length), 2) AS "Average Length"
FROM     film f
JOIN     film_category fc ON f.film_id = fc.film_id
JOIN     category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY c.name;


-- *************************************************************
-- Category with the longest average film length
-- *************************************************************

SELECT   c.name AS "Category Name", 
         ROUND(AVG(f.length), 2) AS Average_Length
FROM     film f
JOIN     film_category fc ON f.film_id = fc.film_id
JOIN     category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY Average_Length DESC
LIMIT    1;

-- *************************************************************
-- Category with the shortest average film length
-- *************************************************************

SELECT   c.name AS "Category Name", 
         ROUND(AVG(f.length), 2) AS Average_Length
FROM     film f
JOIN     film_category fc ON f.film_id = fc.film_id
JOIN     category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY Average_Length ASC
LIMIT    1;


-- *************************************************************
-- Customers who rented action but not comedy or classic movies
-- *************************************************************

SELECT DISTINCT cu.first_name AS "First Name", 
                cu.last_name AS "Last Name"
FROM     customer cu
JOIN     rental r ON cu.customer_id = r.customer_id
JOIN     inventory i ON r.inventory_id = i.inventory_id
JOIN     film_category fc ON i.film_id = fc.film_id
JOIN     category c ON fc.category_id = c.category_id
WHERE    c.name = 'Action'
  AND    cu.customer_id NOT IN (
            SELECT cu2.customer_id
            FROM   customer cu2
            JOIN   rental r2 ON cu2.customer_id = r2.customer_id
            JOIN   inventory i2 ON r2.inventory_id = i2.inventory_id
            JOIN   film_category fc2 ON i2.film_id = fc2.film_id
            JOIN   category c2 ON fc2.category_id = c2.category_id
            WHERE  c2.name IN ('Comedy', 'Classics')
        );

-- *************************************************************
-- Actor with the most appearances in English-language movies
-- *************************************************************

SELECT   a.first_name AS "First Name", 
         a.last_name AS "Last Name", 
         COUNT(f.film_id) AS "Number of English Movies"
FROM     actor a
JOIN     film_actor fa ON a.actor_id = fa.actor_id
JOIN     film f ON fa.film_id = f.film_id
JOIN     language l ON f.language_id = l.language_id
WHERE    l.name = 'English'
GROUP BY a.actor_id
ORDER BY "Number of English Movies" DESC
LIMIT    1;


-- *************************************************************
-- Number of distinct movies rented for exactly 10 days 
-- from the store where Mike works
-- *************************************************************

SELECT COUNT(DISTINCT r.inventory_id) AS "Number of Movies"
FROM   rental r
JOIN   staff s ON r.staff_id = s.staff_id
JOIN   store st ON s.store_id = st.store_id
WHERE  DATEDIFF(r.return_date, r.rental_date) = 10
  AND  s.first_name = 'Mike';
  
-- *************************************************************
-- Alphabetically list actors who appeared in the movie 
-- with the largest cast of actors
-- *************************************************************

SELECT   a.first_name AS "First Name", 
         a.last_name AS "Last Name"
FROM     actor a
JOIN     film_actor fa ON a.actor_id = fa.actor_id
WHERE    fa.film_id = (
            SELECT fa2.film_id
            FROM   film_actor fa2
            GROUP BY fa2.film_id
            ORDER BY COUNT(fa2.actor_id) DESC
            LIMIT 1
        )
ORDER BY a.last_name, a.first_name;

