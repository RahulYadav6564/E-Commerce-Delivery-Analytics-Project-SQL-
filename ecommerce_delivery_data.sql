CREATE DATABASE ecommerce_delivery_analysis;
USE ecommerce_delivery_analysis;

CREATE TABLE ecommerce_delivery_data (
    order_id VARCHAR(20),
    customer_id VARCHAR(20),
    platform VARCHAR(50),
    order_datetime DATETIME,
    delivery_time_minutes INT,
    product_category VARCHAR(100),
    order_value_inr INT,
    customer_feedback TEXT,
    service_rating INT,
    delivery_delay VARCHAR(10),
    refund_requested VARCHAR(10)
);
LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Ecommerce_Delivery_Analytics_New.csv'
INTO TABLE ecommerce_delivery_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SHOW VARIABLES LIKE 'secure_file_priv';


-- Q1 Which platform generates the highest total revenue?
SELECT platform,
       SUM(order_value_inr) AS total_revenue
FROM ecommerce_delivery_data
GROUP BY platform
ORDER BY total_revenue DESC; 


-- Q2 Which platform has the highest number of orders?
SELECT platform,
       COUNT(order_id) AS total_orders
FROM ecommerce_delivery_data
GROUP BY platform
ORDER BY total_orders DESC; 

-- Q3 What is the average order value by platform?
SELECT platform,
AVG(order_value_inr) AS average_order_value
FROM ecommerce_delivery_data
GROUP BY platform; 

-- Q4 Which product category generates the highest revenue?
SELECT product_category,
SUM(order_value_inr) AS total_revenue
FROM ecommerce_delivery_data
GROUP BY product_category
ORDER BY total_revenue DESC LIMIT 1;

-- Q5 What percentage of orders are delayed?
SELECT 
(SUM(CASE WHEN delivery_delay = 'Yes' THEN 1 ELSE 0 END) 
/ COUNT(order_id)) * 100 AS delay_percentage
FROM ecommerce_delivery_data;

-- Q6 Does delivery delay impact service rating?
SELECT delivery_delay,
AVG(service_rating) AS average_rating
FROM ecommerce_delivery_data
GROUP BY delivery_delay;

-- Q7 What is the refund percentage?
SELECT 
ROUND(
SUM(CASE WHEN refund_requested LIKE '%Yes%' THEN 1 END) * 100.0 / COUNT(*),
2
) AS refund_percentage
FROM ecommerce_delivery_data;

-- Q8 Which platforms have average delivery time above 29.6 minutes?
SELECT platform,
AVG(delivery_time_minutes) AS average_delivery_time
FROM ecommerce_delivery_data
GROUP BY platform
HAVING AVG(delivery_time_minutes) > 29.6; 

-- Q9 Which customers spend more than average?
SELECT customer_id,
SUM(order_value_inr) AS total_spent
FROM ecommerce_delivery_data
GROUP BY customer_id
HAVING total_spent > (
    SELECT AVG(customer_total)
    FROM (
        SELECT SUM(order_value_inr) AS customer_total
        FROM ecommerce_delivery_data
        GROUP BY customer_id
    ) AS subquery_table
)
ORDER BY total_spent DESC; 

-- Q10 Top 3 product categories contributing highest percentage of revenue
SELECT product_category,
SUM(order_value_inr) * 100 /
(SELECT SUM(order_value_inr) FROM ecommerce_delivery_data) 
AS revenue_percentage
FROM ecommerce_delivery_data
GROUP BY product_category
ORDER BY revenue_percentage DESC
LIMIT 3; 

-- Q11 Rank platforms based on total revenue
 SELECT platform,
SUM(order_value_inr) AS total_revenue,
RANK() OVER (ORDER BY SUM(order_value_inr) DESC) AS revenue_rank
FROM ecommerce_delivery_data
GROUP BY platform;

-- Q 12 Which customers have placed more than 45 orders?
SELECT customer_id,
COUNT(order_id) AS total_orders FROM ecommerce_delivery_data 
GROUP BY customer_id 
HAVING COUNT(order_id) > 45;


-- Q13 Difference between maximum and minimum delivery time per platform 
SELECT platform,
MAX(delivery_time_minutes) - MIN(delivery_time_minutes) AS delivery_time_variation
FROM ecommerce_delivery_data
GROUP BY platform;
