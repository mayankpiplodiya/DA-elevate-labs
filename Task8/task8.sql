use db;
CREATE TABLE amazon_sales (
    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    category VARCHAR(100),
    sub_category VARCHAR(100),
    product_name VARCHAR(255),
    region VARCHAR(50),
    sales DECIMAL(10,2),
    quantity INT,
    profit DECIMAL(10,2)
);

SELECT
    product_name,
    SUM(sales) AS total_sales
FROM amazon_sales
GROUP BY product_name
ORDER BY total_sales DESC;

SELECT
    region,
    product_name,
    SUM(sales) AS total_sales,
    ROW_NUMBER() OVER (
        PARTITION BY region
        ORDER BY SUM(sales) DESC
    ) AS row_num
FROM amazon_sales
GROUP BY region, product_name;

SELECT
    region,
    product_name,
    SUM(sales) AS total_sales,
    RANK() OVER (
        PARTITION BY region
        ORDER BY SUM(sales) DESC
    ) AS rank_val,
    DENSE_RANK() OVER (
        PARTITION BY region
        ORDER BY SUM(sales) DESC
    ) AS dense_rank_val
FROM amazon_sales
GROUP BY region, product_name;

SELECT
    order_date,
    sales,
    SUM(sales) OVER (
        ORDER BY order_date
    ) AS running_total_sales
FROM amazon_sales
ORDER BY order_date;

SELECT
    order_date,
    sales,
    SUM(sales) OVER (
        ORDER BY order_date
    ) AS running_total_sales
FROM amazon_sales
ORDER BY order_date;
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m-01') AS month,
        SUM(sales) AS total_sales
    FROM amazon_sales
    GROUP BY DATE_FORMAT(order_date, '%Y-%m-01')
)
SELECT
    month,
    total_sales,
    total_sales
      - LAG(total_sales) OVER (ORDER BY month) AS mom_growth
FROM monthly_sales
ORDER BY month;

WITH ranked_products AS (
    SELECT
        category,
        product_name,
        SUM(sales) AS total_sales,
        DENSE_RANK() OVER (
            PARTITION BY category
            ORDER BY SUM(sales) DESC
        ) AS category_rank
    FROM amazon_sales
    GROUP BY category, product_name
)
SELECT *
FROM ranked_products
WHERE category_rank <= 3;

SELECT
    category,
    SUM(sales) AS total_sales
FROM amazon_sales
GROUP BY category
INTO OUTFILE '/tmp/category_sales.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
