-- Customers table
CREATE TABLE customers (
    customer_id VARCHAR PRIMARY KEY,
    customer_unique_id VARCHAR,
    customer_city VARCHAR,
    customer_state VARCHAR
);

-- Orders table
CREATE TABLE orders (
    order_id VARCHAR PRIMARY KEY,
    customer_id VARCHAR,
    order_status VARCHAR,
    order_purchase_timestamp TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


-- Products table
CREATE TABLE products (
    product_id VARCHAR PRIMARY KEY,
    product_category_name VARCHAR
);

-- Sellers table
CREATE TABLE sellers (
    seller_id VARCHAR PRIMARY KEY
);

-- Order Items table
CREATE TABLE order_items (
    order_id VARCHAR,
    product_id VARCHAR,
    seller_id VARCHAR,
    price NUMERIC,
    freight_value NUMERIC,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

-- Payments table
CREATE TABLE payments (
    order_id VARCHAR,
    payment_type VARCHAR,
    payment_value NUMERIC,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';


select * from customers;
select * from orders;
select * from order_items;
select * from payments;
select * from products;
select * from sellers;

--check row counts
SELECT COUNT(*) AS customers_count FROM customers;
SELECT COUNT(*) AS orders_count FROM orders;
SELECT COUNT(*) AS order_items_count FROM order_items;
SELECT COUNT(*) AS payments_count FROM payments;

--Preview Data
SELECT * FROM customers LIMIT 5;
SELECT * FROM orders LIMIT 5;
SELECT * FROM order_items LIMIT 5;

--Check null values
SELECT COUNT(*) AS null_delivered_date
FROM orders
WHERE order_delivered_customer_date IS NULL;

--Validate Relationship
SELECT o.order_id, c.customer_city
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
LIMIT 5;

--Total Revenue
SELECT SUM(payment_value) AS total_revenue
FROM payments;

--Which payment method company prefers
SELECT payment_type,
       SUM(payment_value) AS revenue
FROM payments
GROUP BY payment_type
ORDER BY revenue DESC;

--Total customers
SELECT COUNT(DISTINCT customer_unique_id) AS total_customers
FROM customers;

--Identify loyal customers
SELECT c.customer_unique_id,
       COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC;

--Best selling products
SELECT p.product_category_name,
       COUNT(oi.product_id) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_sales DESC;

--Logistics efficiency (Average delivery time)
SELECT AVG(
    order_delivered_customer_date - order_purchase_timestamp
) AS avg_delivery_time
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

--Rank products by revenue
WITH product_revenue AS (
    SELECT p.product_category_name,
           oi.product_id,
           SUM(oi.price) AS revenue
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.product_category_name, oi.product_id
)
SELECT *,
       RANK() OVER (
           PARTITION BY product_category_name
           ORDER BY revenue DESC
       ) AS rank_in_category
FROM product_revenue;

SELECT order_id,
       payment_value,
       SUM(payment_value) OVER (
           ORDER BY order_id
       ) AS running_revenue
FROM payments;





