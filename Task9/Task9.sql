CREATE DATABASE sales_dw;
USE sales_dw;

CREATE TABLE dim_date (
    date_id INT AUTO_INCREMENT PRIMARY KEY,
    order_date DATE UNIQUE
);

CREATE TABLE dim_product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(50),
    style VARCHAR(50),
    category VARCHAR(50),
    size VARCHAR(20),
    asin VARCHAR(20),
    UNIQUE (sku, style, category, size, asin)
);

CREATE TABLE dim_customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    ship_city VARCHAR(50),
    ship_state VARCHAR(50),
    ship_postal_code VARCHAR(20),
    ship_country VARCHAR(20),
    UNIQUE (ship_city, ship_state, ship_postal_code, ship_country)
);

CREATE TABLE dim_region (
    region_id INT AUTO_INCREMENT PRIMARY KEY,
    ship_state VARCHAR(50),
    ship_country VARCHAR(20),
    UNIQUE (ship_state, ship_country)
);

CREATE TABLE fact_sales (
    sales_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(30),
    date_id INT,
    product_id INT,
    customer_id INT,
    region_id INT,
    qty INT,
    amount DECIMAL(10,2),

    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (region_id) REFERENCES dim_region(region_id)
);

# Insert Distinct Values into Dimensions
INSERT INTO dim_date (order_date)
SELECT DISTINCT STR_TO_DATE(date, '%m-%d-%y')
FROM amazon_clean
WHERE date IS NOT NULL;

INSERT INTO dim_product (sku, style, category, size, asin)
SELECT DISTINCT sku, style, category, size, asin
FROM amazon_clean
WHERE sku IS NOT NULL;

INSERT INTO dim_customer (ship_city, ship_state, ship_postal_code, ship_country)
SELECT DISTINCT ship_city, ship_state, ship_postal_code, ship_country
FROM amazon_clean
WHERE ship_city IS NOT NULL;

#Insert Data into Fact Table (Mapped with Dimension IDs)
INSERT INTO fact_sales (
    order_id,
    date_id,
    product_id,
    customer_id,
    region_id,
    qty,
    amount
)
SELECT
    a.order_id,
    d.date_id,
    p.product_id,
    c.customer_id,
    r.region_id,
    a.qty,
    a.amount
FROM amazon_clean a
JOIN dim_date d
    ON d.order_date = STR_TO_DATE(a.date, '%m-%d-%y')
JOIN dim_product p
    ON a.sku = p.sku
   AND a.style = p.style
   AND a.category = p.category
   AND a.size = p.size
   AND a.asin = p.asin
JOIN dim_customer c
    ON a.ship_city = c.ship_city
   AND a.ship_state = c.ship_state
   AND a.ship_postal_code = c.ship_postal_code
   AND a.ship_country = c.ship_country
JOIN dim_region r
    ON a.ship_state = r.ship_state
   AND a.ship_country = r.ship_country;

#Create Indexes for Performance
CREATE INDEX idx_fact_date ON fact_sales(date_id);
CREATE INDEX idx_fact_product ON fact_sales(product_id);
CREATE INDEX idx_fact_customer ON fact_sales(customer_id);
CREATE INDEX idx_fact_region ON fact_sales(region_id);

#Analytics Queries

SELECT
    MONTH(d.order_date) AS month,
    SUM(f.amount) AS total_sales
FROM fact_sales f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY MONTH(d.order_date)
ORDER BY month;

SELECT
    p.sku,
    p.category,
    SUM(f.amount) AS revenue
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.sku, p.category
ORDER BY revenue DESC
LIMIT 10;

SELECT
    AVG(amount) AS avg_order_value
FROM fact_sales;

#Validation Queries
SELECT COUNT(*) FROM amazon_clean;
SELECT COUNT(*) FROM fact_sales;

#Missing Foreign Key Check
SELECT COUNT(*) 
FROM fact_sales
WHERE date_id IS NULL
   OR product_id IS NULL
   OR customer_id IS NULL
   OR region_id IS NULL;

#Referential Integrity Check
SELECT COUNT(*)
FROM fact_sales f
LEFT JOIN dim_product p ON f.product_id = p.product_id
WHERE p.product_id IS NULL;
