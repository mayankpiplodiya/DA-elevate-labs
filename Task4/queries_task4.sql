create database db;
use db;

CREATE TABLE customers (
    CustomerID VARCHAR(10) PRIMARY KEY,
    CompanyName VARCHAR(100),
    ContactName VARCHAR(50),
    Country VARCHAR(50)
);

-- Orders Table
CREATE TABLE orders (
    OrderID INT PRIMARY KEY,
    CustomerID VARCHAR(10),
    OrderDate DATE,
    ShipCountry VARCHAR(50),
    FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID)
     
);

-- Products Table
CREATE TABLE products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    CategoryID INT,
    UnitPrice DECIMAL(10,2),
    FOREIGN KEY (CategoryID) REFERENCES categories(CategoryID)
);

-- Categories Table
CREATE TABLE categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(50),
    Description TEXT
);

-- Order Details Table (uploaded CSV)
CREATE TABLE order_details (
    OrderID INT,
    ProductID INT,
    UnitPrice DECIMAL(10,2),
    Quantity INT,
    Discount DECIMAL(3,2),
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES products(ProductID)
);

-- 2. INNER JOIN Orders with Customers

-- Get order details with customer info
SELECT o.OrderID, o.OrderDate, c.CustomerID, c.CompanyName, c.Country
FROM orders AS o
INNER JOIN customers AS c ON o.CustomerID = c.CustomerID;

-- Validate: count orders per customer
SELECT c.CustomerID, c.CompanyName, COUNT(o.OrderID) AS TotalOrders
FROM customers AS c
INNER JOIN orders AS o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CompanyName;

-- 3. LEFT JOIN Customers with Orders (Customers with No Orders)

SELECT c.CustomerID, c.CompanyName, o.OrderID
FROM customers AS c
LEFT JOIN orders AS o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;


-- 4. Join Orders with Products to Calculate Total Revenue per Product
SELECT p.ProductID, p.ProductName, SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalRevenue
FROM order_details AS od
INNER JOIN products AS p ON od.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalRevenue DESC;


-- 5. Join Categories with Products to Generate Category-wise Revenue
SELECT cat.CategoryID, cat.CategoryName, SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS CategoryRevenue
FROM categories AS cat
INNER JOIN products AS p ON cat.CategoryID = p.CategoryID
INNER JOIN order_details AS od ON p.ProductID = od.ProductID
GROUP BY cat.CategoryID, cat.CategoryName
ORDER BY CategoryRevenue DESC;


-- 6. Conditional Queries: Sales in Specific Region Between Dates
SELECT o.OrderID, o.OrderDate, c.Country, p.ProductName, od.Quantity, od.UnitPrice,
       (od.Quantity * od.UnitPrice * (1 - od.Discount)) AS Revenue
FROM orders AS o
INNER JOIN customers AS c ON o.CustomerID = c.CustomerID
INNER JOIN order_details AS od ON o.OrderID = od.OrderID
INNER JOIN products AS p ON od.ProductID = p.ProductID
WHERE c.Country = 'USA'
  AND o.OrderDate BETWEEN '2023-01-01' AND '2023-12-31';


-- Export product revenue to CSV
SELECT p.ProductID, p.ProductName, SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalRevenue
INTO OUTFILE '/tmp/product_revenue.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM order_details AS od
INNER JOIN products AS p ON od.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalRevenue DESC;