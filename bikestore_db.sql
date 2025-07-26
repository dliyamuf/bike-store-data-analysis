-- create database
CREATE DATABASE bikestore_db;
USE bikestore_db;

-- create sales_customers table
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

-- create sales_order_items table
CREATE TABLE sales_order_items(
order_id INT,
item_id INT,
product_id INT,
quantity INT,
list_price FLOAT,
discount FLOAT
);

-- create sales_staffs table
CREATE TABLE sales_staffs(
staff_id INT PRIMARY KEY,
first_name VARCHAR(30),
last_name VARCHAR(30),
email VARCHAR(50),
phone VARCHAR(20),
is_active INT,
store_id INT,
manager_id INT
);

-- create sales_orders table ->fact table
CREATE TABLE sales_orders(
order_id INT PRIMARY KEY,
customer_id INT,
order_status INT, -- 1: pending, 2: processing, 3:rejected, 4:completed
order_date DATE,
required_date DATE,
shipped_date DATE,
store_id INT,
staff_id INT
);

-- create production_stores table
CREATE TABLE production_stores(
store_id INT PRIMARY KEY,
store_name VARCHAR(30), 
phone VARCHAR(20), 
email VARCHAR(50), 
street VARCHAR(25),
city VARCHAR(25),
state VARCHAR(50), 
zip_code VARCHAR(10)
);


-- create production_stocks table
CREATE TABLE production_stocks(
store_id INT, 
product_id INT, 
quantity INT
);

-- create production_brands table
CREATE TABLE production_brands(
brand_id INT PRIMARY KEY, 
brand_name VARCHAR(15)
);

-- create production_categories table
CREATE TABLE production_categories(
category_id INT PRIMARY KEY, 
category_name VARCHAR(30)
);

-- create production_product table -> fact table
CREATE TABLE production_product(
product_id INT PRIMARY KEY, 
product_name VARCHAR(50), 
brand_id INT, 
category_id INT, 
model_year YEAR, 
list_price FLOAT
);

-- load data table sales_customers
LOAD DATA INFILE 'C:\Users\hp\Downloads\bikestore\customers.csv'
INTO TABLE sales_customers
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- load data table sales_order_items
LOAD DATA INFILE 'C:\Users\hp\Downloads\bikestore\order_items.csv'
INTO TABLE sales_order_items
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- load data table sales_staffs
LOAD DATA INFILE 'C:\Users\hp\Downloads\bikestore\staffs.csv'
INTO TABLE sales_staffs
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- load data table sales_orders
LOAD DATA INFILE 'C:\Users\hp\Downloads\bikestore\orders.csv'
INTO TABLE sales_orders
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- load data table production_stores
LOAD DATA INFILE 'C:\Users\hp\Downloads\bikestore\stores.csv'
INTO TABLE production_stores
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- load data table production_stocks
LOAD DATA INFILE 'C:\Users\hp\Downloads\bikestore\stocks.csv'
INTO TABLE production_stocks
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- load data table production_brands
LOAD DATA INFILE 'C:\Users\hp\Downloads\bikestore\brands.csv'
INTO TABLE production_brands
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- load data table production_categories
LOAD DATA INFILE 'C:\Users\hp\Downloads\bikestore\categories.csv'
INTO TABLE production_categories
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

-- load data table production_product
LOAD DATA INFILE 'C:\Users\hp\Downloads\bikestore\product.csv'
INTO TABLE production_product
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;