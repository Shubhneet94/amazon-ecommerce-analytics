-- ** Project Sales and Customer analytics ** --

-- creating database 

create database Amazon_data;
use Amazon_data;

-- Creating table of meta_data for raw data

select*from meta_data;
select count(user_id) from meta_data;
select count(*) from meta_data;
CREATE TABLE meta_data (
    user_id VARCHAR(20),
    product_id VARCHAR(20),
    category VARCHAR(100),
    subcategory VARCHAR(100),
    brand VARCHAR(100),

    price DECIMAL(10,2),
    discount DECIMAL(5,2),
    final_price DECIMAL(10,2),

    rating DECIMAL(2,1),
    review_count INT,
    stock INT,

    seller_id VARCHAR(20),
    seller_rating DECIMAL(2,1),

    purchase_date DATE,
    shipping_time_days INT,

    location VARCHAR(100),
    device VARCHAR(50),
    payment_method VARCHAR(50),

    is_returned VARCHAR(10),

    delivery_status VARCHAR(50)
);

-- calculating unique set of rows

select count(*) AS total_rows,
count(distinct concat(
user_id,
product_id,
purchase_date
)) as unique_rows
from meta_data;

-- Creating clean data set after removing dublicate rows

CREATE TABLE clean_meta_data AS
SELECT
    user_id,
    product_id,
    category,
    subcategory,
    brand,
    price,
    discount,
    final_price,
    rating,
    review_count,
    stock,
    seller_id,
    seller_rating,
    purchase_date,
    shipping_time_days,
    location,
    device,
    payment_method,
    is_returned,
    delivery_status
FROM meta_data
GROUP BY
    user_id,
    product_id,
    category,
    subcategory,
    brand,
    price,
    discount,
    final_price,
    rating,
    review_count,
    stock,
    seller_id,
    seller_rating,
    purchase_date,
    shipping_time_days,
    location,
    device,
    payment_method,
    is_returned,
    delivery_status;

-- Droping raw dataset DROP TABLE meta_data;

DROP TABLE meta_data;

-- Rename clean_meta_data to meta_data

RENAME TABLE clean_meta_data TO meta_data;

-- Data exploration 

select *from meta_data  
limit 10;

-- NULL Analysis : Checking Data Quality

SELECT 
	sum(case when user_id is null then 1 else 0 end) as null_product_id,
    sum(case when product_id is null then 1 else 0 end) as null_product_id,
    sum(case when price is null then 1 else 0 end) as null_price
FROM meta_data;

-- null_product_id  = 0, null_product_id = 0, null_price = 0

-- Creating Normalizing Table
-- Cutomers
-- Products
-- Sellers 
-- Orders
-- Reviews
-- category
-- Payment

-- Designing database of Amazon dataset 
-- Creating tables

-- Creating Customers table

CREATE TABLE customers (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(50),
    location VARCHAR(100),
    device VARCHAR(50)
);

 -- creating category table
 
 create table category (
	category_id int primary key auto_increment,
	category_name varchar (100),
	subcategory varchar(100)
 );
 
 -- creating products table
 
 create table products (
	product_id varchar(50) primary key,
	category_id int,
	brand varchar(100),
	price decimal(10,2),
	discount decimal(10,2),
	final_price decimal(10,2),
	stock int,
	rating decimal(2,1),
	review_count int,
 
 foreign key  (category_id)
 references category(category_id)
 );
 
 
 -- creating Sellers tabel
 
 CREATE TABLE sellers (
    seller_key INT AUTO_INCREMENT PRIMARY KEY,
    seller_id VARCHAR(50),
    seller_rating DECIMAL(2,1)
);


-- creating payments table

create table payments(
	payment_id int primary key auto_increment,
	payment_method Varchar(50)
);

-- Creating Orders table

CREATE TABLE orders(
    order_id BIGINT PRIMARY KEY AUTO_INCREMENT,

    customer_key INT,
    product_key INT,
    seller_key INT,
    payment_id INT,

    purchase_date DATE,
    shipping_time_days INT,
    is_returned VARCHAR(50),
    delivery_status VARCHAR(50),

    FOREIGN KEY (customer_key)
    REFERENCES customers(customer_key),

    FOREIGN KEY (product_key)
    REFERENCES products(product_key),

    FOREIGN KEY (seller_key)
    REFERENCES sellers(seller_key),

    FOREIGN KEY (payment_id)
    REFERENCES payments(payment_id)
);

 
 create table reviews(
	review_id Bigint auto_increment primary key ,
	customer_id varchar(50),
	product_key int,
	order_id bigint,
	rating decimal(2,1),
 
	foreign key (customer_id)
	references customers(customer_id),
    
	foreign key (product_key)
	references products(product_key),
    
	foreign key (order_id)
	references orders(order_id)
 );
 
 -- Database designing completed , all tables created with relationship
 -- Inserting data in created database from meta_data
 
 -- Inserting data in category table
 
 insert into category(
	category_name,
	subcategory)
 select distinct
	category,
	subcategory
 from meta_data;
 
 select *from category; 
 
-- inserting customers data in customers table

insert into customers(
	customer_id, location, device)
select distinct 
	user_id,
	location, 
	device
from meta_data;  

-- Due to error : dublicate entery in customer_id( as customer_id is primary key unique enteriws allowed 
-- only but user can login in different device with same customer_id) ,So creating new customer table

-- Dropping column from customer table

Alter table customers drop column location;
alter table customers drop column device;

-- Adding removed column (location, device) into orders table

alter table orders add column location varchar(100);
alter table orders add column device varchar(100);

-- Now inserting data into customers table

insert into customers(
	customer_id)
select distinct
	user_id
from meta_data;

-- insert data into seller table 

insert into sellers(
	seller_id
)
select distinct
	seller_id
From meta_data;

-- Inserting data in category

insert into category(
	category_name,
	subcategory )
select distinct 
	category,
	subcategory
from meta_data;

select*from products;

-- Inserting data in products table

CREATE TABLE products (
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_id VARCHAR(50),
    category_id INT,
    brand VARCHAR(100),
    price DECIMAL(10,2),
    discount DECIMAL(10,2),
    final_price DECIMAL(10,2),
    stock INT,
    rating DECIMAL(3,2),
    review_count INT,

    FOREIGN KEY (category_id)
    REFERENCES category(category_id)
);

    SHOW TABLES;
    
    
    select count(*) from orders;
    
    DESCRIBE orders;
    
    SELECT *
FROM orders
WHERE order_id IS NULL;

SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;
    
 CREATE TABLE reviews (
    review_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT,
    customer_key INT,
    product_key INT,
    rating DECIMAL(2,1),
    review_count INT,

    FOREIGN KEY (order_id)
    REFERENCES orders(order_id),

    FOREIGN KEY (customer_key)
    REFERENCES customers(customer_key),

    FOREIGN KEY (product_key)
    REFERENCES products(product_key)
);

select * from reviews;

DROP TABLE reviews;

CREATE TABLE reviews (
    review_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    customer_key INT,
    product_key INT,
    rating DECIMAL(2,1),
    review_count INT,

    FOREIGN KEY (customer_key)
    REFERENCES customers(customer_key),

    FOREIGN KEY (product_key)
    REFERENCES products(product_key)
);

select * 
from reviews;

DROP TABLE reviews;
DROP TABLE orders;


use amazon_data;

TRUNCATE TABLE reviews;
TRUNCATE TABLE orders;
SET FOREIGN_KEY_CHECKS = 0;

SET SESSION wait_timeout = 600;
SET SESSION interactive_timeout = 600;



SHOW TABLES;

SHOW TABLES;

CREATE TABLE products (
    product_key BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id VARCHAR(50) UNIQUE,
    category_id INT,
    brand VARCHAR(100),
    price DECIMAL(10,2),
    discount DECIMAL(5,2),
    final_price DECIMAL(10,2),
    stock INT,
    rating DECIMAL(2,1),
    review_count INT,

    FOREIGN KEY (category_id)
    REFERENCES categories(category_id)
);

SET GLOBAL net_read_timeout = 600;
SET GLOBAL net_write_timeout = 600;
SET GLOBAL wait_timeout = 600;
SET GLOBAL interactive_timeout = 600;

   SET FOREIGN_KEY_CHECKS = 0;
   
   TRUNCATE TABLE reviews;
   
   CREATE TABLE products (
    product_key BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id VARCHAR(50) UNIQUE,
    category_id INT,
    brand VARCHAR(100),
    price DECIMAL(10,2),
    discount DECIMAL(5,2),
    final_price DECIMAL(10,2),
    stock INT,
    rating DECIMAL(2,1),
    review_count INT,

    FOREIGN KEY (category_id)
    REFERENCES category(category_id)
);
CREATE TABLE reviews (
    review_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    customer_key INT,
    product_key BIGINT,
    rating DECIMAL(2,1),
    review_count INT,

    FOREIGN KEY (customer_key)
    REFERENCES customers(customer_key),

    FOREIGN KEY (product_key)
    REFERENCES products(product_key)
);

SELECT * FROM meta_data;

CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY AUTO_INCREMENT,

    customer_key int,
    product_key BIGINT,
    seller_key int,
    payment_id INT,

    purchase_date DATE,
    shipping_time_days INT,
    is_returned VARCHAR(20),
    delivery_status VARCHAR(50),
    seller_rating DECIMAL(2,1),

    FOREIGN KEY (customer_key)
    REFERENCES customers(customer_key),

    FOREIGN KEY (product_key)
    REFERENCES products(product_key),

    FOREIGN KEY (seller_key)
    REFERENCES sellers(seller_key),

    FOREIGN KEY (payment_id)
    REFERENCES payments(payment_id)
);

orders_df.to_sql(
    "orders",
    con=engine,
    if_exists="append",
    index=False,
    chunksize=10000
)


SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM sellers;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM reviews;
SELECT COUNT(*) FROM payments;
SELECT COUNT(*) FROM category;


SELECT COUNT(*) FROM orders
WHERE customer_key IS NULL
OR product_key IS NULL
OR seller_key IS NULL
OR payment_id IS NULL;

SELECT COUNT(*) FROM reviews
WHERE customer_key IS NULL
OR product_key IS NULL;

CREATE INDEX idx_orders_customer ON orders(customer_key);
CREATE INDEX idx_orders_product ON orders(product_key);
CREATE INDEX idx_orders_seller ON orders(seller_key);

CREATE INDEX idx_reviews_customer ON reviews(customer_key);
CREATE INDEX idx_reviews_product ON reviews(product_key);

														
                                                        -- SALES ANALYSIS --
                                                        
-- Problem 1 : Idetifying Top 10 highest revenue products												


select
	p.product_id,
	c.category_name,
	c.subcategory,
	p.brand,
	sum(final_price) as revenue
from products p
join category c on c.category_id=p.category_id
group by p.product_id,
c.category_name,
c.subcategory,
p.brand
order by revenue DESC
Limit 10;	

-- Problem 2 : Identifying top customers by order count

select 
	dense_rank()over(order by count(o.order_id) DESC) as Ranking,
	c.customer_id,
    count(o.order_id) as total_order
from customers c
join orders o on c.customer_key=o.customer_key
group by c.customer_id
limit 10;

-- Problem 3: Idendtify best seller by sales

select*
	from 
		(select 
			s.seller_id,
			sum(final_price) as best_seller,
			dense_rank()over(order by sum(final_price) DESC) as ranking
		from sellers s

		join orders o on s.seller_key=o.seller_key

		join products p
		on p.product_key=o.product_key

		group by
			s.seller_id,
			s.seller_key
)x


where ranking=1;
    
-- Problem 4 : identify Average Shipping time

select
	avg(shipping_time_days) as avg_shipping_time
from orders;


-- Problem 5:Identify return percentage

select 
	round( 
		sum(case
				when is_returned ='Yes'then 1 else 0 end)
                *100.0/count(*),
			2) as return_percentage
from orders;

-- Problem 6: Highest rated categories

select 
	c.category_id,
    c.category_name,
    avg(p.rating) as Highest_rating
from category c
join products p on c.category_id=p.category_id
group by c.category_id, c.category_name
order by Highest_rating DESC;

-- Problem 7: Most reviewed products

select 
	product_id,
    SUM(review_count) as total_reviews
from products
group by product_id
order by Most_reviews DESC;

-- Problem 8: Most Used Payment Method 

select
	p.payment_method,
	count(*) as total_orders
from orders o
join payments p on p.payment_id =o.payment_id
group by payment_method
order by total_orders DESC;

-- Problem 9: Monthly order trend

select 
	date_format(purchase_date,'%y-%m') as Months,
    count(order_id) as Total_orders
from orders
group by date_format(purchase_date,'%y-%m')
order by total_orders;

-- Problem 10: Monthly revenue

select 
	date_format(o.purchase_date,'%y-%m') as month,
    sum(p.final_price) as revenue
from orders o
join products p on p.product_key=o.product_key
group by date_format(o.purchase_date,'%y-%m')
order by revenue;
    
    
-- Identifying Top 5 Categories by Revenue
-- Using Category, products, orders table

select 
	c.category_id,
    c.category_name,
    SUM(p.final_price) as revenue,
    count(o.order_id) as Total_orders
from category c
join products p on p.category_id=c.category_id
join orders o on p.product_key=o.product_key
group by c.category_id,c.category_name
order by revenue DESC;

-- Identifying Monthly revenue Trend 
-- using, total_sales, total_orders, average_order_value

select 
	date_format(o.purchase_date,'%y-%m') as month,
	sum(p.final_price) as Total_sales,
    count(o.order_id) as total_orders,
    avg(p.final_price) as avg_order_value
from orders o
join products p on o.product_key=p.product_key
group by date_format(o.purchase_date,'%y-%m')
order by month;

-- Finding customers who never placed any orders 

select 
	c.customer_id,
    count(o.order_id) as Total_order
from customers c
left join orders o on c.customer_key=o.customer_key
where order_id= NULL
group by c.customer_id
order by Total_order;


-- Finding Customers with more than 5 orders 
-- using total orders, customers, total_spent

select 
	c.customer_id,
    count(o.order_id) as total_orders,
    sum(p.final_price) as total_purchase
    
from customers c

join orders o on c.customer_key=o.customer_key
join products p on p.product_key=o.product_key
group by c.customer_id
having total_orders>5
order by total_orders DESC;

-- Resolving lost connection error by increasing timeout

SET GLOBAL net_read_timeout = 600;
SET GLOBAL net_write_timeout = 600;
SET GLOBAL wait_timeout = 600;
SET GLOBAL interactive_timeout = 600;  

-- USing performance optimization as after increasing time_out still lost connection

SELECT 
    c.customer_id,
    x.total_orders,
    x.total_purchase

FROM customers c

JOIN
(
    SELECT 
        o.customer_key,
        COUNT(*) AS total_orders,
        SUM(p.final_price) AS total_purchase

    FROM orders o

    JOIN products p
        ON o.product_key = p.product_key

    GROUP BY o.customer_key

    HAVING COUNT(*) >= 5
) x

ON c.customer_key = x.customer_key

ORDER BY x.total_orders DESC;


-- *Return Analysis*

-- find 

-- total returns orders
-- total delivered orders
-- return percentage 
-- Also identify top 10 products with highest return rate

with return_analysis as
(
	select 
		o.order_id,
        p.product_id as product_id,
        o.delivery_status as delivery_status	
    
    from orders o 
    
    join products p on
		p.product_key = o.product_key
)
select 
	product_id,
    count(order_id) as total_order,

    sum(Case
			when delivery_status='Returned'
			then 1
			else 0
	end) as total_order_returned,
    
    sum( case
			when delivery_status='Delivered'
			then 1
			else 0
	end) as total_deliverd_order,
    
	round(sum(case
				when delivery_status='returned'
				then 1
				else 0
			end)/ count(order_id)*100,2) as return_percentage
        
from return_analysis
group by product_id
order by return_percentage DESC
limit 10;   

 
SET GLOBAL net_read_timeout = 600;
SET GLOBAL net_write_timeout = 600;
SET GLOBAL wait_timeout = 600;
SET GLOBAL interactive_timeout = 600;  

-- Seller Performance Dashboard

-- For every seller calculate:

-- total orders 
-- total revenue
-- average seller rating
-- return percentage
 
 select 
	s.seller_id,
	count(o.order_id) as Total_orders,
    sum(p.final_price) as Total_revenue,
    avg(s.seller_rating) as avg_seller_rating,
    round(sum(case
				when o.delivery_status='Returned'
                then 1
                else 0
			  end)/count(o.order_id)*100,2) as return_percentage
from sellers s
join orders o on s.seller_key=o.seller_key
join products p on p.product_key=o.product_key
group by seller_id 
order by Total_revenue DESC;

-- Due to Lost connection using Performance Optimization (For large Dataset)

with seller_analysis as
( 
	select
		o.seller_key,
        
        count(*) as Total_orders,
        sum(p.final_price) as Total_revenue,
        
        Round(
				100*sum(
						case
							when o.delivery_status='Returned'
							then 1
							else 0
						end)/count(o.order_id),2) as return_percentage
	
    from orders o
    
    join products p on
		p.product_key=o.product_key
        
	group by o.seller_key
    
)
select
	s.seller_id,
    ss.total_orders,
    ss.total_revenue,
    ss.return_percentage,
    s.seller_rating as avg_seller_rating

from seller_analysis ss

join sellers s
		on s.seller_key= ss.seller_key

order by ss.total_revenue DESC
limit 100;
							
    
-- Most Popular Payment Method

-- Find:

-- payment method
-- total orders
-- total revenue
-- percentage contribution

select 
	p.payment_method,
    count(o.order_id) as Total_orders,
    sum(ps.final_price) as Total_revenue,
    round(sum(ps.final_price)/count(p.payment_id)*100,2) as percentage_contribution
from payments p
	join orders o
		on o.payment_id = p.payment_id
	join products ps 
		on ps.product_key =o.product_key
group by payment_method
order by percentage_contribution DESC
limit 10;


-- Product Price Bucket Analysis

-- Create buckets :

-- Below 500
-- 500 - 1000
-- 1000 - 5000
-- Above 5000

-- Find :
-- Total products
-- Total Sales
-- Average Rating 

	select 
		count(product_id) as Total_products,
        sum(final_price) as Total_sales,
        round(avg(rating),2) as avg_rating,
        Case
			when final_price > 5000
            then 'high_price'
            
            when final_price >1000 and final_price <=5000
            then 'Medium_price'
            
            when final_price >500 and final_price <=1000
            then 'Low_price'
            
            else 'Very_Low_price'
            
		end as product_price_bucket
        
	from products 
    group by product_price_bucket
    order by Total_sales DESC; 
    

-- Running Revenue Calculation 
-- Calculate cumulative revenue month by month 

with monthly_revenue as
(
select 
    date_format(purchase_date,'%y-%m') as month,
    sum(final_price) as revenue

from products p
join orders o on p.product_key = o.product_key
group by date_format(purchase_date,'%y-%m')
)

 select   
	month,
    revenue,
	sum(revenue)over( 
    order by month ) as monthly_sales
from monthly_revenue;


-- Customer Segmentation
-- segment customers into:

-- VIP --> spent > 100000
-- Regular --> spent between 20000 and 100000
-- Low value --> below 20000

WITH customer_spend AS
(
    SELECT
        c.customer_id,

        SUM(p.final_price) AS total_spent

    FROM orders o

    JOIN customers c
        ON o.customer_key = c.customer_key

    JOIN products p
        ON o.product_key = p.product_key

    GROUP BY c.customer_id
),

customer_segment AS
(
    SELECT
        customer_id,
        total_spent,

        CASE
            WHEN total_spent > 100000
                THEN 'VIP'

            WHEN total_spent BETWEEN 20000 AND 100000
                THEN 'Regular'

            ELSE 'Low Value'
        END AS segment

    FROM customer_spend
)

SELECT
    segment,

    COUNT(customer_id) AS customer_count,

    ROUND(AVG(total_spent),2) AS average_spend

FROM customer_segment

GROUP BY segment

ORDER BY average_spend DESC;
 
 
												-- Business KPI Analytics--
                                                
-- Analyzing Overall Business Health 

-- Find

-- Total_revenue
-- Total orders 
-- Total customers 
-- average order value 
-- return percentage


with Business_Analysis as 
(
	select 
		c.customer_id as customer_id,
        p.final_price as final_price,
        o.delivery_status as delivery_status,
        o.order_id as order_id
	From customers c
    join orders o on c.customer_key = o.customer_key
    join products p on p.product_key = o.product_key
)
select 
	count(distinct customer_id) as Total_Customers,
	sum(final_price) as Total_revenue,
	count(order_id) as Total_orders,
	avg(final_price) as avg_order_value,
    round(sum(case
			when delivery_status = 'Returned'
			then 1
        
			else 0
		end) / count(order_id) *100,2) as return_percentage
        
	from Business_Analysis;



-- Monthly Business Growth 

-- Find:

-- Monthly revenue
-- Monthly order growth %
-- MoM revenue growth %


with Business_growth as 
(
	select 
		sum(p.final_price) as monthly_revenue,
        date_format(o.purchase_date, '%y-%m') as month,
       count(o.order_id) as Total_orders
        
	From orders o 
    join products p on p.product_key=o.product_key
    group by date_format(o.purchase_date, '%y-%m')
)
select 
	month ,
    Total_orders,
     monthly_revenue,
     
    
    round((Total_orders - lag(Total_orders)over(order by month))/ 
    lag(total_orders)over(order by month)*100,2) as Order_growth,
    
    round((monthly_revenue -lag(monthly_revenue)over(order by month))/
    lag(monthly_revenue)over(order by month)*100,2) as revenue_growth
    
From Business_growth 
order by month ;


-- Finding Top Categories

-- Top 10 categories by revenue
-- contribution percentage

with Category_analysis  as 
(
	select 
		c.category_id,
        c.category_name,
        sum(p.final_price) as revenue
	from category c
	join products p on c.category_id=p.category_id
    group by category_id, category_name
),
total_sales AS
(
    SELECT
        SUM(revenue) AS overall_revenue
    FROM category_analysis
)
select 
	category_id,
    category_name,
    revenue,
    round(ca.revenue/ts.overall_revenue *100,2) as contribuiton_percenatge
from category_analysis ca
cross  join total_sales ts
order by revenue DESC
limit 10;
    
    
-- Finding Customer Retention

-- repeat customers
-- one-time customers
-- retention rate 

with customer_retention as 
(
	select 
		c.customer_id as customer_id,
		count(order_id) as total_orders
        
from customers c
join orders o
	on c.customer_key=o.customer_key
group by customer_id
)
select
    sum(case
			when total_orders > 1
			then 1
			else 0
		end) as repeated_customer,
    
    sum(case
			when total_orders=1
            then 1
            else 0
		end) as one_time_customers ,
        
		round(sum(case
					when total_orders > 1
					then 1
					else 0
				end)/ count(customer_id)*100,2) as retention_rate

from customer_retention ;



-- RFM Analysis

-- Calculate:

-- Recency 
-- Frequancy 
-- Monetary value

WITH rfm_analysis AS
(
    SELECT
        c.customer_id,

        DATEDIFF(
            MAX(o.purchase_date),
            MIN(o.purchase_date)
        ) AS recency,

        COUNT(o.order_id) AS frequency,

        ROUND(SUM(p.final_price),2) AS monetary

    FROM orders o

    JOIN customers c
        ON o.customer_key = c.customer_key

    JOIN products p
        ON o.product_key = p.product_key

    GROUP BY c.customer_id
)

SELECT
    customer_id,
    recency,
    frequency,
    monetary

FROM rfm_analysis

ORDER BY monetary DESC;


-- Creating Customer Cohorts

-- Defination 
-- cohort_month = first purchase month 
-- order_month = any later purchase month

WITH customer_first_purchase AS
(
    SELECT
        c.customer_id,

        MIN(DATE_FORMAT(o.purchase_date,'%Y-%m-01')) AS cohort_month

    FROM orders o

    JOIN customers c
        ON o.customer_key = c.customer_key

    GROUP BY c.customer_id
),

customer_orders AS
(
    SELECT
        c.customer_id,

        DATE_FORMAT(o.purchase_date,'%Y-%m-01') AS order_month

    FROM orders o

    JOIN customers c
        ON o.customer_key = c.customer_key
),

cohort_data AS
(
    SELECT
        fp.customer_id,
        fp.cohort_month,
        co.order_month,

        TIMESTAMPDIFF(
            MONTH,
            fp.cohort_month,
            co.order_month
        ) AS month_number

    FROM customer_first_purchase fp

    JOIN customer_orders co
        ON fp.customer_id = co.customer_id
)

SELECT
    cohort_month,

    month_number,

    COUNT(DISTINCT customer_id) AS retained_customers

FROM cohort_data

GROUP BY
    cohort_month,
    month_number

ORDER BY
    cohort_month,
    month_number;
    
    
-- Repeat Customer Rate

-- What percentage of customers place more than one order?

-- This is one of the most important e-commerce KPIs.

WITH customer_orders AS
(
    SELECT
        c.customer_id,

        COUNT(o.order_id) AS total_orders

    FROM orders o

    JOIN customers c
        ON o.customer_key = c.customer_key

    GROUP BY c.customer_id
)

SELECT
    COUNT(
        CASE
            WHEN total_orders > 1
            THEN customer_id
        END
    ) AS repeat_customers,

    COUNT(customer_id) AS total_customers,

    ROUND(
        (
            COUNT(
                CASE
                    WHEN total_orders > 1
                    THEN customer_id
                END
            )
            /
            COUNT(customer_id)
        ) * 100,
        2
    ) AS repeat_customer_rate

FROM customer_orders;



-- Customer Churn Analysis
-- Business Definition

-- Customers with:

-- no purchase in last 90 days

-- are considered churned.
    
    
    WITH last_purchase AS
(
    SELECT
        c.customer_id,

        MAX(o.purchase_date) AS last_order_date

    FROM orders o

    JOIN customers c
        ON o.customer_key = c.customer_key

    GROUP BY c.customer_id
)

SELECT
    COUNT(customer_id) AS churned_customers

FROM last_purchase

WHERE DATEDIFF(
        CURDATE(),
        last_order_date
      ) > 90;
      
      
-- Customer Lifetime Value (CLV)

-- How much revenue does each customer generate overall?

SELECT
    c.customer_id,

    COUNT(o.order_id) AS total_orders,

    ROUND(SUM(p.final_price),2) AS lifetime_value

FROM orders o

JOIN customers c
    ON o.customer_key = c.customer_key

JOIN products p
    ON o.product_key = p.product_key

GROUP BY c.customer_id

ORDER BY lifetime_value DESC;


-- Average Order Value (AOV)

-- What is the average value of each order?

-- One of the most important e-commerce KPIs.

SELECT
    ROUND(
        SUM(p.final_price)
        /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value

FROM orders o

JOIN products p
    ON o.product_key = p.product_key;
    

use amazon_data

