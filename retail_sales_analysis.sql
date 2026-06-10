-- ============================================================
-- Retail Sales Analysis
-- SQL, Database Management, Business Insights
-- ============================================================

-- Create Database
CREATE DATABASE IF NOT EXISTS retail_sales_db;
USE retail_sales_db;

-- ============================================================
-- Table Creation
-- ============================================================

CREATE TABLE IF NOT EXISTS customers (
    customer_id INT PRIMARY KEY,
    gender VARCHAR(10),
    age INT
);

CREATE TABLE IF NOT EXISTS categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) UNIQUE
);

CREATE TABLE IF NOT EXISTS products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT,
    price_per_unit DECIMAL(10,2),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE IF NOT EXISTS orders (
    transaction_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    product_id INT,
    quantity INT,
    cogs DECIMAL(10,2),
    total_sale DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ============================================================
-- Indexing for Query Optimization
-- ============================================================

CREATE INDEX idx_sale_date ON orders(sale_date);
CREATE INDEX idx_customer_id ON orders(customer_id);
CREATE INDEX idx_total_sale ON orders(total_sale);

-- ============================================================
-- Data Cleaning
-- ============================================================

-- Remove rows with null values
DELETE FROM orders WHERE quantity IS NULL OR total_sale IS NULL OR cogs IS NULL;

-- ============================================================
-- Business Analysis Queries
-- ============================================================

-- 1. Total Revenue by Category
SELECT 
    c.category_name,
    SUM(o.total_sale) AS total_revenue,
    COUNT(o.transaction_id) AS total_orders,
    ROUND(AVG(o.total_sale), 2) AS avg_order_value
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_revenue DESC;

-- 2. Top 10 Customers by Revenue
SELECT 
    o.customer_id,
    cu.gender,
    cu.age,
    SUM(o.total_sale) AS total_spent,
    COUNT(o.transaction_id) AS total_orders
FROM orders o
JOIN customers cu ON o.customer_id = cu.customer_id
GROUP BY o.customer_id, cu.gender, cu.age
ORDER BY total_spent DESC
LIMIT 10;

-- 3. Monthly Sales Trend
SELECT 
    YEAR(sale_date) AS year,
    MONTH(sale_date) AS month,
    MONTHNAME(sale_date) AS month_name,
    SUM(total_sale) AS monthly_revenue,
    COUNT(transaction_id) AS total_transactions
FROM orders
GROUP BY YEAR(sale_date), MONTH(sale_date)
ORDER BY year, month;

-- 4. Seasonal Trends (Quarterly)
SELECT 
    YEAR(sale_date) AS year,
    QUARTER(sale_date) AS quarter,
    SUM(total_sale) AS quarterly_revenue,
    COUNT(transaction_id) AS total_orders
FROM orders
GROUP BY YEAR(sale_date), QUARTER(sale_date)
ORDER BY year, quarter;

-- 5. Best Selling Products by Quantity
SELECT 
    c.category_name,
    SUM(o.quantity) AS total_quantity_sold,
    SUM(o.total_sale) AS total_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_quantity_sold DESC;

-- 6. Customer Purchasing Behavior by Gender
SELECT 
    cu.gender,
    COUNT(DISTINCT o.customer_id) AS num_customers,
    SUM(o.total_sale) AS total_revenue,
    ROUND(AVG(o.total_sale), 2) AS avg_purchase_value,
    COUNT(o.transaction_id) AS total_orders
FROM orders o
JOIN customers cu ON o.customer_id = cu.customer_id
GROUP BY cu.gender;

-- 7. Age Group Analysis using CTE
WITH age_groups AS (
    SELECT 
        o.transaction_id,
        o.total_sale,
        CASE 
            WHEN cu.age < 25 THEN 'Under 25'
            WHEN cu.age BETWEEN 25 AND 40 THEN '25-40'
            WHEN cu.age BETWEEN 41 AND 55 THEN '41-55'
            ELSE 'Above 55'
        END AS age_group
    FROM orders o
    JOIN customers cu ON o.customer_id = cu.customer_id
)
SELECT 
    age_group,
    COUNT(transaction_id) AS total_orders,
    SUM(total_sale) AS total_revenue,
    ROUND(AVG(total_sale), 2) AS avg_order_value
FROM age_groups
GROUP BY age_group
ORDER BY total_revenue DESC;

-- 8. Revenue Ranking using Window Functions
SELECT 
    YEAR(sale_date) AS year,
    MONTH(sale_date) AS month,
    SUM(total_sale) AS monthly_revenue,
    RANK() OVER (PARTITION BY YEAR(sale_date) ORDER BY SUM(total_sale) DESC) AS revenue_rank
FROM orders
GROUP BY YEAR(sale_date), MONTH(sale_date);

-- 9. Running Total Revenue (Cumulative)
SELECT 
    sale_date,
    daily_revenue,
    SUM(daily_revenue) OVER (ORDER BY sale_date) AS cumulative_revenue
FROM (
    SELECT sale_date, SUM(total_sale) AS daily_revenue
    FROM orders
    GROUP BY sale_date
) daily_sales;

-- 10. Profit Margin Analysis
SELECT 
    c.category_name,
    SUM(o.total_sale) AS total_revenue,
    SUM(o.cogs) AS total_cogs,
    SUM(o.total_sale - o.cogs) AS gross_profit,
    ROUND((SUM(o.total_sale - o.cogs) / SUM(o.total_sale)) * 100, 2) AS profit_margin_pct
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY profit_margin_pct DESC;

-- 11. Peak Sales Hours Analysis
SELECT 
    HOUR(sale_time) AS hour_of_day,
    COUNT(transaction_id) AS total_orders,
    SUM(total_sale) AS total_revenue
FROM orders
GROUP BY HOUR(sale_time)
ORDER BY total_revenue DESC;

-- 12. Subquery: Customers who spent above average
SELECT 
    customer_id,
    total_spent
FROM (
    SELECT customer_id, SUM(total_sale) AS total_spent
    FROM orders
    GROUP BY customer_id
) customer_totals
WHERE total_spent > (
    SELECT AVG(total_spent) 
    FROM (SELECT SUM(total_sale) AS total_spent FROM orders GROUP BY customer_id) avg_calc
)
ORDER BY total_spent DESC;
