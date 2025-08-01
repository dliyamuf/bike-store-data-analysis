-- ORDER & SALES ANALYSIS
-- Q1 what's total revenue of all bike stores each year?
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
 -- insight: the highest revenue is on 2017, the trend shows total revenue is fluctuative with 2018 has lowest revenue.

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

-- Q2 what's total revenue per month?
 SELECT 
 YEAR(o.order_date) AS order_year,
 MONTH(o.order_date) AS order_month,
 SUM(i.total_price) AS total_revenue
 FROM sales_orders AS o
 JOIN sales_order_items AS i
 ON o.order_id = i.order_id 
 GROUP BY YEAR(o.order_date), MONTH(o.order_date)
ORDER BY YEAR(o.order_date), MONTH(o.order_date);

-- insight: the highest revenue is on April 2018

-- Q3 how much total revenue each month across product category?
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
-- insight: the highest revenue is generated by road bikes at April 2018

-- Q4 how much total unit sold each year?
SELECT 
YEAR(o.order_date) AS order_year,
SUM(i.quantity) AS total_unit
FROM sales_orders AS o
JOIN sales_order_items AS i
ON o.order_id = i.order_id
GROUP BY YEAR(o.order_date)
ORDER BY YEAR(o.order_date);
-- insight: most unit sold happened in 2017

-- STORES ANALYSIS
-- Q5 what's total revenue per stores?
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
-- insight: Baldwin Bikes store generated highest total revenue

-- Q6 how much total revenue per store each year?
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
-- insight: the highest total revenue happened on Baldwin Bikes in 2017

-- Q7 how much is total order per store?
SELECT 
s.store_name,
COUNT(o.store_id) AS total_units
FROM sales_orders AS o
JOIN production_stores AS s
ON o.store_id = s.store_id
GROUP BY s.store_id
ORDER BY COUNT(o.store_id) DESC;
-- insight: Baldwin Bikes store is the store that sold most units

-- PRODUCTS AND STOCKS ANALYSIS
-- Q8 what's total revenue per product category?
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
-- insight: most highest revenue was generated by Mountain Bikes category

-- Q9 what's most sold product per category?
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
-- insight: Cruisers Bicycles product category was most sold unit

 -- Q10 what's most favorite brand name?
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
-- insight: most favorite brand that most orders was Electra

-- Q11 how much is total stock each store?
SELECT
s.store_name,
SUM(sto.quantity) AS total_stock
FROM production_stores AS s
JOIN production_stocks AS sto
ON s.store_id = sto.store_id
GROUP BY s.store_name
ORDER BY SUM(sto.quantity) DESC;
-- insight: Stock on Rowlett Bikes is the highest

-- Q12 how much is total stocks per product ?
SELECT 
p.product_name,
SUM(sto.quantity) AS total_stocks
FROM production_product AS p
JOIN production_stocks AS sto
ON p.product_id = sto.product_id
GROUP BY p.product_name
ORDER BY SUM(sto.quantity) DESC;
-- Electra Towie Original 7D - 2017 has the highest total stocks

-- CUSTOMER BEHAVIOUR ANALYSIS
-- Q13 top 5 customer based on their spent
-- create new column named customer name
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
-- Customer named Pamelia Newman spent highest on bike store

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

-- Q14 top 5 customers based on their total orders
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
-- insight: most orders came from customer named Tameka Fisher

-- STAFFS ANALYSIS
-- Q15 who's best staff based their revenue generated?
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
-- insight: staff named Marcelene Boyer from Baldwin Bikes generated highest revenue

-- OPERATIONAL ANALYSIS
-- Q16 how much order is pending (1), processing (2), rejected (3), completed (4)
SELECT order_status, COUNT(*) AS total_days FROM sales_orders
GROUP BY order_status
ORDER BY COUNT(*) DESC;
-- insight: most orders are completed

-- Q17 how much shipping late based on the store?
-- shipping late means the shipping date is greater that required date
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
-- insight: Baldwin Bikes has highest total shipped day late from required date



