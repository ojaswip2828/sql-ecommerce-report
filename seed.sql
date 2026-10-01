USE ecommerce_report;

INSERT INTO customers (customer_id, name, email, phone, city, created_at) VALUES
(1,'Aarav Sharma','aarav@mail.com','9876500001','Bengaluru','2026-05-01'),
(2,'Diya Patel','diya@mail.com',NULL,'Mumbai','2026-05-03'),
(3,'Rohan Mehta','rohan@mail.com','9876500003','Delhi','2026-05-10'),
(4,'Sneha Iyer','sneha@mail.com',NULL,'Chennai','2026-05-15'),
(5,'Kabir Singh','kabir@mail.com','9876500005','Bengaluru','2026-06-01'),
(6,'Meera Nair','meera@mail.com','9876500006','Kochi','2026-06-05'),
(7,'Arjun Rao','arjun@mail.com',NULL,'Hyderabad','2026-06-20'),
(8,'Ishita Das','ishita@mail.com','9876500008','Kolkata','2026-07-01'),
(9,'Vikram Joshi','vikram@mail.com','9876500009','Pune','2026-07-10'),
(10,'Ananya Gupta','ananya@mail.com','9876500010','Delhi','2026-07-15');

INSERT INTO categories (category_id, name) VALUES
(1,'Electronics'),(2,'Books'),(3,'Home'),(4,'Fitness'),(5,'Fashion');

INSERT INTO products (product_id, name, category_id, price, stock) VALUES
(1,'Wireless Earbuds',1,2499,50),
(2,'Smartwatch',1,4999,30),
(3,'Power Bank',1,1499,100),
(4,'Python Crash Course',2,699,80),
(5,'SQL Cookbook',2,899,60),
(6,'Desk Lamp',3,799,40),
(7,'Coffee Maker',3,3499,20),
(8,'Yoga Mat',4,999,70),
(9,'Dumbbell Set',4,2999,25),
(10,'Notebook Pack',2,249,200),
(11,'Mystery Gadget',NULL,1999,10),
(12,'Air Fryer',3,5499,0);

INSERT INTO orders (order_id, customer_id, order_date, status, coupon_code) VALUES
(1,1,'2026-06-03','delivered','WELCOME10'),
(2,2,'2026-06-10','delivered',NULL),
(3,3,'2026-06-15','delivered',NULL),
(4,1,'2026-07-02','delivered',NULL),
(5,4,'2026-07-08','cancelled',NULL),
(6,5,'2026-07-12','delivered','FIT15'),
(7,6,'2026-07-20','delivered',NULL),
(8,2,'2026-07-25','shipped',NULL),
(9,3,'2026-08-01','delivered',NULL),
(10,7,'2026-08-05','delivered',NULL),
(11,10,'2026-08-11','delivered','WELCOME10'),
(12,5,'2026-08-18','pending',NULL),
(13,1,'2026-08-22','delivered',NULL),
(14,6,'2026-09-03','delivered',NULL),
(15,10,'2026-09-09','delivered',NULL),
(16,4,'2026-09-15','delivered',NULL);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1,1,1,2499),(1,4,2,699),
(2,2,1,4999),
(3,6,2,799),(3,10,5,249),
(4,3,1,1499),(4,5,1,899),
(5,7,1,3499),
(6,8,1,999),(6,9,1,2999),
(7,1,2,2499),
(8,4,1,699),(8,5,1,899),(8,10,2,249),
(9,7,1,3499),
(10,3,2,1499),(10,11,1,1999),
(11,2,1,4999),(11,3,1,1499),
(12,1,1,2499),
(13,8,2,999),
(14,9,1,2999),(14,4,1,699),
(15,5,3,899),
(16,6,1,799),(16,8,1,999);
