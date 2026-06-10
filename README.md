# Retail Sales Analysis

A comprehensive SQL-based retail sales analysis project covering database design, data cleaning, and business intelligence queries.

## 🛠️ Technologies Used
- SQL (MySQL)
- Database Management
- Business Intelligence & Analytics

## 📁 Project Structure
```
retail-sales-analysis/
├── retail_sales_analysis.sql   # All SQL queries
├── dataset.csv                  # Raw sales data (2000 transactions)
└── README.md
```

## 🗃️ Database Schema
- **customers** – customer demographics (gender, age)
- **categories** – product categories (Beauty, Clothing, Electronics)
- **products** – product details with pricing
- **orders** – transaction records with sales, COGS, and quantities

## 🔍 Analysis Highlights
- **Top Customers** – Identified highest-revenue customers by total spend
- **Category Revenue** – Category-wise revenue breakdown with profit margins
- **Seasonal Trends** – Monthly & quarterly sales trend analysis
- **Customer Behavior** – Purchase patterns by gender and age group
- **Peak Hours** – Sales performance by hour of day
- **Cumulative Revenue** – Running total revenue using Window Functions

## 📊 SQL Techniques Used
- JOINs (INNER, multiple table)
- CTEs (Common Table Expressions)
- Subqueries (correlated and non-correlated)
- Window Functions (`RANK()`, `SUM() OVER`)
- Aggregations (`SUM`, `AVG`, `COUNT`)
- Indexing for query optimization
- Data cleaning with `DELETE` on null values

## 🚀 How to Run
1. Install MySQL
2. Run `retail_sales_analysis.sql` in MySQL Workbench or CLI:
```sql
source retail_sales_analysis.sql;
```
3. Load `dataset.csv` into the `orders` table
