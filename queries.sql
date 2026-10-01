USE ecommerce_report;

-- MySQL 8.0 version. 46 queries. "Revenue" = line total (quantity * unit_price) of non-cancelled orders.
-- Each query starts with a "-- Q<n>:" line (run.py splits on it).

-- ===== A. BASICS =====
-- Q1: 5 priciest products
SELECT name, price FROM products ORDER BY price DESC LIMIT 5;
-- Q2: products under 1000
SELECT name, price FROM products WHERE price < 1000 ORDER BY price;
-- Q3: orders placed in August 2026
SELECT order_id, customer_id, order_date, status FROM orders WHERE order_date BETWEEN '2026-08-01' AND '2026-08-31';
-- Q4: customers in Bengaluru or Delhi
SELECT name, city FROM customers WHERE city IN ('Bengaluru','Delhi') ORDER BY city, name;
-- Q5: products whose name starts with S
SELECT name FROM products WHERE name LIKE 'S%';
-- Q6: order count per status
SELECT status, COUNT(*) AS orders FROM orders GROUP BY status ORDER BY orders DESC;

-- ===== B. TOP PRODUCTS =====
-- Q7: top 5 products by units sold
SELECT p.name, SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status <> 'cancelled'
GROUP BY p.product_id ORDER BY units_sold DESC LIMIT 5;
-- Q8: top 5 products by revenue
SELECT p.name, SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status <> 'cancelled'
GROUP BY p.product_id ORDER BY revenue DESC LIMIT 5;
-- Q9: revenue per category
SELECT c.name AS category, SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN categories c ON c.category_id = p.category_id
WHERE o.status <> 'cancelled'
GROUP BY c.category_id ORDER BY revenue DESC;
-- Q10: best-selling product (by revenue) in each category
WITH rev AS (
  SELECT c.name AS category, p.name AS product, SUM(oi.quantity * oi.unit_price) AS revenue
  FROM order_items oi
  JOIN orders o ON o.order_id = oi.order_id
  JOIN products p ON p.product_id = oi.product_id
  JOIN categories c ON c.category_id = p.category_id
  WHERE o.status <> 'cancelled'
  GROUP BY c.category_id, p.product_id
), ranked AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn FROM rev
)
SELECT category, product, revenue FROM ranked WHERE rn = 1;
-- Q11: products that never sold
SELECT p.name FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.product_id IS NULL;
-- Q12: products earning more than the average product revenue
SELECT p.name, SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status <> 'cancelled'
GROUP BY p.product_id
HAVING revenue > (
  SELECT AVG(r) FROM (
    SELECT SUM(oi2.quantity * oi2.unit_price) AS r
    FROM order_items oi2 JOIN orders o2 ON o2.order_id = oi2.order_id
    WHERE o2.status <> 'cancelled' GROUP BY oi2.product_id) AS per_product)
ORDER BY revenue DESC;
-- Q13: low-stock products (20 or fewer)
SELECT name, stock FROM products WHERE stock <= 20 ORDER BY stock;
-- Q14: monthly revenue
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month, SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status <> 'cancelled'
GROUP BY month ORDER BY month;

-- ===== C. CUSTOMER SPEND =====
-- Q15: top 5 customers by total spend
SELECT c.name, SUM(oi.quantity * oi.unit_price) AS total_spend
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status <> 'cancelled'
GROUP BY c.customer_id ORDER BY total_spend DESC LIMIT 5;
-- Q16: average order value per customer
SELECT c.name, ROUND(AVG(t.total), 2) AS avg_order_value
FROM customers c
JOIN (SELECT o.order_id, o.customer_id, SUM(oi.quantity * oi.unit_price) AS total
      FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
      WHERE o.status <> 'cancelled' GROUP BY o.order_id) t ON t.customer_id = c.customer_id
GROUP BY c.customer_id ORDER BY avg_order_value DESC;
-- Q17: customers who spent more than 5000
SELECT c.name, SUM(oi.quantity * oi.unit_price) AS total_spend
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status <> 'cancelled'
GROUP BY c.customer_id HAVING total_spend > 5000 ORDER BY total_spend DESC;
-- Q18: customers who never ordered
SELECT c.name FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;
-- Q19: repeat customers (2+ orders)
SELECT c.name, COUNT(*) AS orders FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id HAVING COUNT(*) >= 2 ORDER BY orders DESC;
-- Q20: spend by city
SELECT c.city, SUM(oi.quantity * oi.unit_price) AS revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status <> 'cancelled'
GROUP BY c.city ORDER BY revenue DESC;
-- Q21: first and last order date per customer
SELECT c.name, MIN(o.order_date) AS first_order, MAX(o.order_date) AS last_order
FROM customers c JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id ORDER BY first_order;
-- Q22: customer spend ranking (window function)
WITH spend AS (
  SELECT c.name, SUM(oi.quantity * oi.unit_price) AS total
  FROM customers c
  JOIN orders o ON o.customer_id = c.customer_id
  JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.status <> 'cancelled' GROUP BY c.customer_id)
SELECT name, total, RANK() OVER (ORDER BY total DESC) AS spend_rank FROM spend;
-- Q23: customer segments with CASE
WITH spend AS (
  SELECT c.name, SUM(oi.quantity * oi.unit_price) AS total
  FROM customers c
  JOIN orders o ON o.customer_id = c.customer_id
  JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.status <> 'cancelled' GROUP BY c.customer_id)
SELECT name, total,
  CASE WHEN total >= 8000 THEN 'Gold' WHEN total >= 3000 THEN 'Silver' ELSE 'Bronze' END AS segment
FROM spend ORDER BY total DESC;

-- ===== D. NULL HANDLING =====
-- Q24: customers missing a phone number
SELECT name FROM customers WHERE phone IS NULL;
-- Q25: COALESCE to show a default
SELECT name, COALESCE(phone, 'N/A') AS phone FROM customers;
-- Q26: uncategorised products
SELECT name FROM products WHERE category_id IS NULL;
-- Q27: gotcha - "= NULL" never matches (returns 0 rows)
SELECT name FROM customers WHERE phone = NULL;
-- Q28: COUNT(*) vs COUNT(column) ignores NULLs
SELECT COUNT(*) AS all_customers, COUNT(phone) AS with_phone, COUNT(*) - COUNT(phone) AS without_phone FROM customers;
-- Q29: orders with vs without a coupon
SELECT CASE WHEN coupon_code IS NULL THEN 'No coupon' ELSE 'Coupon used' END AS coupon_status, COUNT(*) AS orders
FROM orders GROUP BY coupon_status;
-- Q30: NULLIF avoids divide-by-zero (units sold per unit of stock)
SELECT p.name, p.stock, COALESCE(SUM(oi.quantity), 0) AS units_sold,
       ROUND(1.0 * COALESCE(SUM(oi.quantity), 0) / NULLIF(p.stock, 0), 2) AS sold_per_stock
FROM products p LEFT JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_id ORDER BY p.product_id;
-- Q31: coupon usage with a label for NULL
SELECT COALESCE(coupon_code, 'NO COUPON') AS coupon, COUNT(*) AS orders FROM orders GROUP BY coupon ORDER BY orders DESC;

-- ===== E. JOINS =====
-- Q32: INNER JOIN - full order lines
SELECT o.order_id, c.name AS customer, p.name AS product, oi.quantity, oi.quantity * oi.unit_price AS line_total
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
ORDER BY o.order_id LIMIT 10;
-- Q33: LEFT JOIN - products per category (empty categories show 0)
SELECT c.name AS category, COUNT(p.product_id) AS products
FROM categories c LEFT JOIN products p ON p.category_id = c.category_id
GROUP BY c.category_id ORDER BY products DESC;
-- Q34: LEFT JOIN - keep uncategorised products
SELECT p.name, COALESCE(c.name, 'Uncategorised') AS category
FROM products p LEFT JOIN categories c ON c.category_id = p.category_id
ORDER BY category, p.name;
-- Q35: LEFT JOIN - orders per customer incl. zero
SELECT c.name, COUNT(o.order_id) AS orders
FROM customers c LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id ORDER BY orders DESC, c.name;
-- Q36: SELF JOIN - customer pairs in the same city
SELECT a.name AS customer_1, b.name AS customer_2, a.city
FROM customers a JOIN customers b ON a.city = b.city AND a.customer_id < b.customer_id;
-- Q37: 5-table JOIN - top city/category revenue combos
SELECT cu.city, cat.name AS category, SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o
JOIN customers cu ON cu.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN categories cat ON cat.category_id = p.category_id
WHERE o.status <> 'cancelled'
GROUP BY cu.city, cat.name ORDER BY revenue DESC LIMIT 5;
-- Q38: EXISTS - customers who bought Electronics
SELECT c.name FROM customers c
WHERE EXISTS (
  SELECT 1 FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  JOIN products p ON p.product_id = oi.product_id
  JOIN categories cat ON cat.category_id = p.category_id
  WHERE o.customer_id = c.customer_id AND cat.name = 'Electronics' AND o.status <> 'cancelled');

-- ===== F. DDL + CONSTRAINTS =====
-- Q39: CREATE INDEX on a frequent join column
CREATE INDEX idx_orders_customer ON orders(customer_id);
-- Q40: CREATE VIEW for reusable order totals
CREATE VIEW v_order_totals AS
SELECT o.order_id, o.customer_id, o.order_date, o.status, SUM(oi.quantity * oi.unit_price) AS total
FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id;
-- Q41: query the view
SELECT status, COUNT(*) AS orders, SUM(total) AS order_value FROM v_order_totals GROUP BY status;
-- Q42: ALTER TABLE to add a column
ALTER TABLE customers ADD COLUMN loyalty_points INTEGER NOT NULL DEFAULT 0;
-- Q43: CHECK violation (expect error): negative price
INSERT INTO products (name, category_id, price, stock) VALUES ('Bad Product', 1, -5, 1);
-- Q44: FOREIGN KEY violation (expect error): customer 999 does not exist
INSERT INTO orders (customer_id, order_date, status) VALUES (999, '2026-09-20', 'pending');
-- Q45: UNIQUE violation (expect error): duplicate email
INSERT INTO customers (name, email, city) VALUES ('Dup User', 'aarav@mail.com', 'Pune');
-- Q46: NOT NULL violation (expect error): missing name
INSERT INTO customers (name, email, city) VALUES (NULL, 'x@mail.com', 'Pune');

-- Q47: (MySQL only) confirm the constraints exist
SELECT table_name, constraint_name, constraint_type FROM information_schema.table_constraints WHERE table_schema = 'ecommerce_report' ORDER BY table_name, constraint_type;
