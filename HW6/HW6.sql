
/* **************************************************************************************** 
-- Abdullah Alshamrani
-- 12/05/2024
**************************************************************************************** */


/* **************************************************************************************** 
-- Step 1: Create the `HW6` database and switch to it.
**************************************************************************************** */
USE HW6;

/* ****************************************************************************************
-- Step 2: Create the `accounts` table with the required columns.
**************************************************************************************** */
CREATE TABLE IF NOT EXISTS accounts (
  account_num CHAR(5) PRIMARY KEY,    -- 5-digit account number
  branch_name VARCHAR(50),           -- Branch name
  balance DECIMAL(10, 2),            -- Account balance with 2 decimal places
  account_type VARCHAR(50)           -- Account type
);

/* *************************************************generate_accounts***************************************
-- Step 3: Create a stored procedure to populate the `accounts` table with random data.
**************************************************************************************** */
DELIMITER $$

CREATE PROCEDURE generate_accounts(IN num_records INT)
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE batch_size INT DEFAULT 10000; -- Insert records in batches of 10,000
  DECLARE branch_name VARCHAR(50);
  DECLARE account_type VARCHAR(50);

  -- Ensure the table is cleared before generating new records
  TRUNCATE TABLE accounts;

  -- Loop to generate account records dynamically
  WHILE i <= num_records DO
    INSERT INTO accounts (account_num, branch_name, balance, account_type)
    SELECT LPAD(i + t, 5, '0'), -- Generate unique 5-digit account numbers
           ELT(FLOOR(1 + (RAND() * 6)), 
               'Brighton', 'Downtown', 'Mianus', 'Perryridge', 'Redwood', 'RoundHill'), -- Random branch
           ROUND((RAND() * 100000), 2), -- Random balance between 0 and 100,000
           ELT(FLOOR(1 + (RAND() * 2)), 'Savings', 'Checking') -- Random account type
    FROM (SELECT 0 AS t UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
          UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) AS temp
    WHERE i + t <= num_records;

    SET i = i + batch_size; -- Increment by batch size
  END WHILE;
END$$

DELIMITER ;

/* ****************************************************************************************
-- Step 4: Create indexes to optimize the query performance.
**************************************************************************************** */
-- Index on branch_name column to speed up branch-specific queries
CREATE INDEX idx_branch_name ON accounts (branch_name);

-- Composite index on branch_name and account_type for multi-column queries
CREATE INDEX idx_branch_account_type ON accounts (branch_name, account_type);

/* ****************************************************************************************
-- Step 5: Adjust server settings and execute the stored procedure.
**************************************************************************************** */
SET GLOBAL max_allowed_packet = 67108864; -- Increase packet size
SET GLOBAL wait_timeout = 600;            -- Increase wait timeout
SET GLOBAL interactive_timeout = 600;     -- Increase interactive timeout

-- Populate the table with 50,000 records
CALL generate_accounts(50000);

/* ****************************************************************************************
-- Step 6: Verify the data and structure.
**************************************************************************************** */
-- Count the total records in the table
SELECT COUNT(*) FROM accounts;

-- Display the first 10 records
SELECT * FROM accounts LIMIT 10;

-- Group and count records by branch name
SELECT branch_name, COUNT(*)
FROM accounts
GROUP BY branch_name
ORDER BY branch_name;

/* ****************************************************************************************
-- Step 7: Timing analysis for query performance.
**************************************************************************************** */
-- Step 7.1: Query without index
SET @start_time = NOW(6);
SELECT COUNT(*) FROM accounts WHERE branch_name = 'Downtown';
SET @end_time = NOW(6);
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) AS execution_time_microseconds;

-- Step 7.2: Query with composite index
SET @start_time = NOW(6);
SELECT COUNT(*) FROM accounts 
WHERE branch_name = 'Downtown' AND account_type = 'Savings';
SET @end_time = NOW(6);
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) AS execution_time_microseconds;

/* ****************************************************************************************
-- Step 8: Create a stored procedure to calculate average execution times.
**************************************************************************************** */
DELIMITER $$

CREATE PROCEDURE average_execution_time(IN query_text TEXT)
BEGIN
  DECLARE total_time BIGINT DEFAULT 0;
  DECLARE avg_time BIGINT;
  DECLARE i INT DEFAULT 1;

  -- Set the input query into a session variable
  SET @query_text = query_text;

  -- Execute the query 10 times and calculate the total execution time
  WHILE i <= 10 DO
    SET @start_time = NOW(6); -- Record the start time
    PREPARE stmt FROM @query_text; -- Dynamically prepare the query
    EXECUTE stmt; -- Execute the query
    SET @end_time = NOW(6); -- Record the end time
    SET total_time = total_time + TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time); -- Calculate execution time
    DEALLOCATE PREPARE stmt; -- Deallocate the prepared statement
    SET i = i + 1;
  END WHILE;

  -- Compute the average execution time
  SET avg_time = total_time / 10;
  SELECT avg_time AS average_execution_time_microseconds;
END$$

DELIMITER ;

/* ****************************************************************************************
-- Step 9: Example usage of the average_execution_time procedure.
**************************************************************************************** */
CALL average_execution_time('SELECT COUNT(*) FROM accounts WHERE branch_name = "Downtown"');
CALL average_execution_time('SELECT COUNT(*) FROM accounts WHERE branch_name = "Downtown" AND account_type = "Savings"');