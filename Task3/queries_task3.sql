CREATE DATABASE retail_sales;
USE retail_sales;

CREATE TABLE retail_sales (
    transaction_id INT,
    order_date DATE,
    customer_id VARCHAR(20),
    gender VARCHAR(10),
    age INT,
    product_category VARCHAR(50),
    quantity INT,
    price_per_unit INT,
    total_amount INT
);

-- Verify Data Import
SELECT COUNT(*) FROM retail_sales;
SELECT * FROM retail_sales LIMIT 10;

 -- Filtering & Sorting
SELECT *
FROM retail_sales
WHERE product_category = 'Electronics'
ORDER BY total_amount DESC;

-- Aggregations & Summary Reports
SELECT product_category,
       SUM(total_amount) AS total_sales,
       AVG(total_amount) AS avg_sales,
       COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY product_category;

-- HAVING Clause
SELECT product_category,
       SUM(total_amount) AS total_sales
FROM retail_sales
GROUP BY product_category
HAVING SUM(total_amount) > 100000;

-- BETWEEN & LIKE
SELECT *
FROM retail_sales
WHERE order_date BETWEEN '2023-01-01' AND '2023-01-31';
SELECT *
FROM retail_sales
WHERE customer_id LIKE 'CUST0%';

-- Export Output to CSV
SELECT product_category,
       SUM(total_amount) AS total_sales
FROM retail_sales
GROUP BY product_category;


