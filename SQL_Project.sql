# DATABASE SETUP
CREATE DATABASE inventory;
USE inventory;

DROP TABLE IF EXISTS zepto;

CREATE TABLE zepto (
    sku_id SERIAL PRIMARY KEY,
    category VARCHAR(120),
    name VARCHAR(150) NOT NULL,
    mrp NUMERIC(8,2),
    discountPercent NUMERIC(5,2),
    availableQuantity INTEGER,
    discountedSellingPrice NUMERIC(8,2),
    weightInGms INTEGER,
    outOfStock VARCHAR(10),	
    quantity INTEGER
);

# DATA EXPLORATION

# 1. Total number of products
SELECT COUNT(*) AS total_rows FROM zepto;

# 2. Sample of first few records
SELECT * FROM zepto
ORDER BY sku_id ASC
LIMIT 10;

# 3. Check for any NULL values in important fields
SELECT *
FROM zepto
WHERE name IS NULL
   OR category IS NULL
   OR mrp IS NULL
   OR discountPercent IS NULL
   OR discountedSellingPrice IS NULL
   OR weightInGms IS NULL
   OR availableQuantity IS NULL
   OR outOfStock IS NULL
   OR quantity IS NULL;

# 4. List of unique product categories
SELECT category
FROM zepto
GROUP BY category
ORDER BY category ASC;

# 5. Count of in-stock vs out-of-stock items
SELECT outOfStock, COUNT(*) AS count
FROM zepto
GROUP BY outOfStock;

# 6. Product names that appear more than once
SELECT name, COUNT(*) AS sku_count
FROM zepto
GROUP BY name
HAVING COUNT(*) > 1
ORDER BY sku_count DESC;

# ENABLE UPDATES
SET SQL_SAFE_UPDATES = 0;

# DATA CLEANING

# 7. Identify products with invalid pricing
SELECT *
FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;

# 8. Remove products with MRP = 0
DELETE FROM zepto
WHERE mrp = 0;

# 9. Convert price from paise to rupees
UPDATE zepto
SET mrp = mrp / 100,
    discountedSellingPrice = discountedSellingPrice / 100;

# 10. Review updated prices
SELECT sku_id, name, mrp, discountedSellingPrice
FROM zepto
ORDER BY sku_id
LIMIT 15;

# DATA ANALYSIS

# Q1. 10th highest discount product
SELECT name, mrp, discountPercent
FROM (
    SELECT name, mrp, discountPercent,
           ROW_NUMBER() OVER (ORDER BY discountPercent DESC) AS rn
    FROM zepto
) AS ranked
WHERE rn = 10;

# Q2. Expensive out-of-stock products (MRP > 300)
SELECT name, mrp
FROM zepto
WHERE outOfStock = 'TRUE' AND mrp > 300
ORDER BY mrp DESC;

# Q3. Estimated revenue potential by category
SELECT category,
       ROUND(SUM(discountedSellingPrice * availableQuantity), 2) AS estimated_revenue
FROM zepto
GROUP BY category
ORDER BY estimated_revenue DESC;

# Q4. Products with high MRP but low discounts
SELECT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC;

# Q5. Top 5 categories by average discount
SELECT category,
       ROUND(AVG(discountPercent), 2) AS avg_discount_percent
FROM zepto
GROUP BY category
ORDER BY avg_discount_percent DESC
LIMIT 5;

# Q6. Price per gram for products 100g and above
SELECT name, weightInGms, discountedSellingPrice,
       ROUND(discountedSellingPrice / weightInGms, 3) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram ASC;

# Q7. Product size classification
SELECT name, weightInGms,
       CASE
           WHEN weightInGms < 1000 THEN 'Low'
           WHEN weightInGms BETWEEN 1000 AND 4999 THEN 'Medium'
           ELSE 'Bulk'
       END AS size_category
FROM zepto
ORDER BY weightInGms;

# Q8. Total inventory weight by category
SELECT category,
       SUM(weightInGms * availableQuantity) AS total_inventory_weight
FROM zepto
GROUP BY category
ORDER BY total_inventory_weight DESC;
