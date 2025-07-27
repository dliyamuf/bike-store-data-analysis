# **BIKE STORE DATA ANALYSIS**
## **PROJECT OVERVIEW**
With many sports and healthy communities, the demand for sports facilities is also increasing. One of the favorite sports is bicycling. Analysing the bike store is able to deliver information about sales, customers' behaviour, products and stocks, stores and staff performance, and operational.

[Bike store Sales Dashboard](https://lookerstudio.google.com/reporting/d0b9f824-0f9e-4118-adf0-09c514a458a0)
## **DATASET**
The dataset used is [BikeStore](https://www.kaggle.com/datasets/dillonmyrick/bike-store-sample-database) from Kaggle which comprise of 9 csv files:
- brands: information about product's brand, including brand_id and brand_name.
- categories: information of bike's categories, including category_id and category_name.
- customers: information about customers, consist of customer_id, first_name, last_name, phone, email, street, city, state, zip_code.
- order_items: information of items order. Each item belong to sales order categorized by order_id. This file consist of order_id, item_id, product_id, quantity, list_price, and discount.
- orders: the sales order’s header information including customer, order status, order date, required date, shipped date. It also stores the information on where the sales transaction was created (store) and who created it (staff). Each sales order has a row in the sales_orders table. A sales order has one or many line items stored in the order_items table.
- products: information about products, including product_id, product_name, brand_id, category_id, model_year, list_price
- staffs: information about staffs or sales representative each store. It consist of staff_id, first_name, last_name, email, phone, active, store_id, and manager_id.
- stocks: information about product's stock each store, including store_id, product_id, and quantity.
- stores: information about stores, including store_id, store_name, phone, email, street, city, state, zip_code.

## **DATABASE SETUP**
### **SCHEMA DIAGRAM**
I used snowflake schema to define relationship between tables. I split into two parts: sales and production.
[Schema Diagram](https://github.com/dliyamuf/bike-store-data-analysis/blob/main/fig/database-model.png)

### **CREATE DATABASE**
```sql
CREATE DATABASE bikestore_db;
USE bikestore_db;
```
### **CREATE AND LOAD TABLES**
Tables comprises of sales_customers, sales_order_items, sales_orders, sales_staffs, production_brands, production_categories, production_product, production_stocks, and production_stores.
```sql
CREATE TABLE sales_customers(
customer_id INT PRIMARY KEY,
first_name VARCHAR(30),
last_name VARCHAR(30),
phone VARCHAR(20),
email VARCHAR(50),
street VARCHAR(50),
city VARCHAR(25),
state VARCHAR(25),
zip_code VARCHAR(10)
);
```
Then, load the data of tables from csv files.
```sql
-- load data table sales_customers
LOAD DATA INFILE 'C:\Users\hp\Downloads\bikestore\customers.csv'
INTO TABLE sales_customers
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

## **SQL QUERIES**
### **ORDER AND SALES ANALYSIS**
- **What's total revenue of all bike stores each year?**
```sql
-- creating new table named total_price
ALTER TABLE sales_order_items
ADD total_price FLOAT;
UPDATE sales_order_items
SET total_price = (quantity*list_price - (1-list_price*discount));

-- total revenue per year
SELECT 
YEAR(o.order_date) AS order_year,
SUM(i.total_price) AS total_revenue
FROM sales_orders AS o
JOIN sales_order_items AS i
ON o.order_id = i.order_id
GROUP BY
YEAR(o.order_date)
ORDER BY
YEAR(o.order_date) DESC;

-- alternative solution for Q1 without creating new column
WITH total_order_data AS (
SELECT 
order_id, 
quantity, 
list_price, 
discount,
(quantity* list_price - (1-list_price*discount)) AS total_price
FROM sales_order_items
)
SELECT 
YEAR(o.order_date) AS order_year,
SUM(i.total_price) AS total_revenue
FROM sales_orders AS o
JOIN total_order_data AS i
ON o.order_id = i.order_id
GROUP BY
YEAR(o.order_date)
ORDER BY
YEAR(o.order_date);
```
Insight: The highest revenue is in 2017, the trend shows total revenue is fluctuating, with 2018 having the lowest revenue.

- **What's total revenue per month?**
```sql
SELECT 
 YEAR(o.order_date) AS order_year,
 MONTH(o.order_date) AS order_month,
 SUM(i.total_price) AS total_revenue
 FROM sales_orders AS o
 JOIN sales_order_items AS i
 ON o.order_id = i.order_id 
 GROUP BY YEAR(o.order_date), MONTH(o.order_date)
ORDER BY YEAR(o.order_date), MONTH(o.order_date);
```
Insight: The highest revenue was in April 2018.

- **How much total revenue each month across product category?**
```sql
SELECT 
 c.category_name,
 YEAR(o.order_date) AS order_year,
 MONTH(o.order_date) AS order_month,
 SUM(i.total_price) AS total_revenue
 FROM sales_orders AS o
 JOIN sales_order_items AS i
 ON o.order_id = i.order_id 
 JOIN production_product AS p
 ON i.product_id = p.product_id
 JOIN production_categories AS c
 ON p.category_id = c.category_id
 GROUP BY c.category_name, YEAR(o.order_date), MONTH(o.order_date)
 ORDER BY YEAR(o.order_date), MONTH(o.order_date);
```
Insight: The highest revenue from the product category was generated by road bikes in April 2018.

- **How much total unit sold each year?**
```sql
SELECT 
YEAR(o.order_date) AS order_year,
SUM(i.quantity) AS total_unit
FROM sales_orders AS o
JOIN sales_order_items AS i
ON o.order_id = i.order_id
GROUP BY YEAR(o.order_date)
ORDER BY YEAR(o.order_date);
```
Insight: Most unit sold happened in 2017.

### **STORES ANALYSIS**
- **What's total revenue per stores?**
```sql
SELECT  
s.store_name,
SUM(i.total_price) AS total_revenue
FROM sales_orders AS o
JOIN production_stores AS s
ON o.store_id = s.store_id
JOIN sales_order_items AS i
ON o.order_id = i.order_id
GROUP BY s.store_name
ORDER BY SUM(i.total_price) DESC;
```
Insight: Baldwin Bikes store was achieving the highest total revenue among stores.

- **How much total revenue per store each year?**
```sql
SELECT  
s.store_name,
SUM(i.total_price) AS total_revenue,
YEAR(o.order_date) AS order_year
FROM sales_orders AS o
JOIN production_stores AS s
ON o.store_id = s.store_id
JOIN sales_order_items AS i
ON o.order_id = i.order_id
GROUP BY s.store_name, YEAR(o.order_date)
ORDER BY YEAR(o.order_date);
```
Insight: The highest total revenue was producing at Baldwin Bikes store in 2017.

- **How much is total order per store?**
```sql
SELECT 
s.store_name,
COUNT(o.store_id) AS total_units
FROM sales_orders AS o
JOIN production_stores AS s
ON o.store_id = s.store_id
GROUP BY s.store_id
ORDER BY COUNT(o.store_id) DESC;
```
Insight: Baldwin Bikes store sold most units among other stores.

### **PRODUCTS AND STOCKS ANALYSIS**
- **what's total revenue per product category?**
```sql
SELECT 
c.category_name,
SUM(i.total_price) AS total_revenue
FROM production_product AS p
JOIN production_categories AS c
ON p.category_id = c.category_id
JOIN sales_order_items AS i
ON p.product_id = i.product_id
GROUP BY c.category_name
ORDER BY SUM(i.total_price) DESC;
```
Insight: The highest revenue was producing by Mountain Bike product category.

- **What's most sold product per category?**
```sql
SELECT 
c.category_name,
SUM(i.quantity) AS total_unit
FROM production_product AS p
JOIN production_categories AS c
ON p.category_id = c.category_id
JOIN sales_order_items AS i
ON p.product_id = i.product_id
GROUP BY c.category_name
ORDER BY SUM(i.quantity) DESC;
```
Insight: Most sold product category was earning by Cruisers Bicycles.

- **What's most favorite brand name?**
```sql
SELECT
b.brand_name,
SUM(i.quantity) AS total_orders
FROM production_product AS p 
JOIN production_brands AS b
ON p.brand_id = b.brand_id
JOIN sales_order_items AS i
ON p.product_id = i.product_id 
GROUP BY b.brand_name
ORDER BY SUM(i.quantity) DESC;
```
Insight: Most favorite brand's name that sold most units was Electra.

- **How much is total stock each store?**
```sql
SELECT
s.store_name,
SUM(sto.quantity) AS total_stock
FROM production_stores AS s
JOIN production_stocks AS sto
ON s.store_id = sto.store_id
GROUP BY s.store_name
ORDER BY SUM(sto.quantity) DESC;
```
Insight: Rowless Bike store has the highest product stocks.

- **How much is total stocks per product?**
```sql
SELECT 
p.product_name,
SUM(sto.quantity) AS total_stocks
FROM production_product AS p
JOIN production_stocks AS sto
ON p.product_id = sto.product_id
GROUP BY p.product_name
ORDER BY SUM(sto.quantity) DESC;
```
Insight: The product with highest total stock was Electra Towie Original 7D - 2017.

### **CUSTOMER BEHAVIOUR ANALYSIS**
- **Top 5 customer based on their spent**
```sql
-- create new column named customer_name
ALTER TABLE sales_customers
ADD customer_name VARCHAR(30);
UPDATE sales_customers
SET customer_name = CONCAT(first_name, ' ', last_name);

 -- customers based on their spent
SELECT
cu.customer_name,
SUM(i.total_price) AS total_revenue
FROM sales_orders AS o
JOIN sales_customers AS cu 
ON o.customer_id = cu.customer_id
JOIN sales_order_items AS i
ON o.order_id = i.order_id
GROUP BY cu.customer_name
ORDER BY SUM(i.total_price) DESC
LIMIT 5;

-- alternative solution Q13 without creating new column
WITH cust_name_data AS(
SELECT 
customer_id,
first_name, 
last_name,
CONCAT(first_name, ' ', last_name) AS customer_name
FROM
sales_customers
)
SELECT
cu.customer_name,
SUM(i.total_price) AS total_revenue
FROM sales_orders AS o
JOIN cust_name_data AS cu 
ON o.customer_id = cu.customer_id
JOIN sales_order_items AS i
ON o.order_id = i.order_id
GROUP BY cu.customer_name
ORDER BY SUM(i.total_price) DESC
LIMIT 5;
```
Insight: Customer named Pamelia Newman spent highest on bike store.

- **Top 5 customers based on their total orders**
```sql
SELECT
cu.customer_name,
SUM(i.quantity) AS total_orders
FROM sales_orders AS o
JOIN sales_customers AS cu 
ON o.customer_id = cu.customer_id
JOIN sales_order_items AS i
ON o.order_id = i.order_id
GROUP BY cu.customer_name
ORDER BY SUM(i.quantity) DESC
LIMIT 5;
```
Insight: Most orders came from customer named Tameka Fisher.

### **STAFFS' PERFORMANCE ANALYSIS**
- **Who's best staff based their revenue generated?**
```sql
WITH staff_name_data AS(
SELECT
staff_id,
first_name,
last_name,
CONCAT(first_name, ' ', last_name) AS staff_name
FROM 
sales_staffs
)
SELECT 
st.staff_name,
s.store_name,
SUM(i.total_price) AS total_revenue
FROM sales_orders AS o 
JOIN staff_name_data AS st
ON o.staff_id = st.staff_id
JOIN production_stores AS s
ON o.store_id = s.store_id
JOIN sales_order_items AS i
ON o.order_id = i.order_id
GROUP BY st.staff_name, s.store_name
ORDER BY SUM(i.total_price) DESC;
```

### **OPERATIONAL ANALYSIS**
- **how's order status of all orders?**
Note: (1) means pending; (2) means processing; (3) means rejected; (4) means completed.
```sql
SELECT order_status, COUNT(*) AS total_days FROM sales_orders
GROUP BY order_status
ORDER BY COUNT(*) DESC;
```
Insight: Most of orders was completed.

- **How much days is shipping late based on the store?**
Note: Shipping late means the shipping date is greater that required date.
```sql
WITH difference_date_data AS(
SELECT
order_id,
store_id,
required_date,
shipped_date,
(shipped_date - required_date) AS difference_date
FROM 
sales_orders
WHERE
(shipped_date-required_date) >0
)
SELECT 
s.store_name,
SUM(o.difference_date) AS total_day_late
FROM difference_date_data AS o
JOIN production_stores AS s
ON o.store_id = s.store_id
GROUP BY s.store_name
ORDER BY SUM(o.difference_date) DESC;
```
Insight: Baldwin Bikes has highest total shipped day late.

## **RECOMMENDATION ACTIONS**
- Increase productivity and operational by giving more estimated required date.
- Increase staffs' performance by delivering bonuses if they achieving more than the target goals.
- Add membership program and collaborate with brand to increasing sales and loyal customers.
