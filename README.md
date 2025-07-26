# **BIKE STORE DATA ANALYSIS**
## **PROJECT OVERVIEW**
Healthy lifestyle is one of most important things. With many sport and healthy communities, the demand of sport facilities also increasing. One of the most favorite sport is bicycling. From younger until old ones ...

## **DATASET**
The dataset used is [BikeStore](https://www.kaggle.com/datasets/dillonmyrick/bike-store-sample-database) from Kaggle which comprise of 9 csv files:
- brands:
- categories:
- customers:
- order_items:
- orders:
- products:
- staffs:
- stocks:
- stores:

## **DATABASE SETUP**
### **SCHEMA DIAGRAM**
I used snowflake schema to define relationship between tables. I split into two parts: sales and production.
[gambar]

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
```

