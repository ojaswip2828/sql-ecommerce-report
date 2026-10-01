-- SQL E-commerce Report | MySQL 8.0.16+ (CHECK constraints are enforced from 8.0.16)
DROP DATABASE IF EXISTS ecommerce_report;
CREATE DATABASE ecommerce_report;
USE ecommerce_report;

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(120) NOT NULL UNIQUE,
    phone       VARCHAR(15)  NULL,                     -- nullable on purpose
    city        VARCHAR(60)  NOT NULL,
    created_at  DATE NOT NULL DEFAULT (CURRENT_DATE)
) ENGINE=InnoDB;

CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(60) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE products (
    product_id  INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    category_id INT NULL,                              -- nullable on purpose
    price       DECIMAL(10,2) NOT NULL,
    stock       INT NOT NULL DEFAULT 0,
    CONSTRAINT chk_products_price CHECK (price > 0),
    CONSTRAINT chk_products_stock CHECK (stock >= 0),
    CONSTRAINT fk_products_category FOREIGN KEY (category_id)
        REFERENCES categories(category_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE orders (
    order_id    INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date  DATE NOT NULL,
    status      VARCHAR(10) NOT NULL,
    coupon_code VARCHAR(20) NULL,                      -- nullable on purpose
    CONSTRAINT chk_orders_status CHECK (status IN ('pending','shipped','delivered','cancelled')),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB;

CREATE TABLE order_items (
    order_id   INT NOT NULL,
    product_id INT NOT NULL,
    quantity   INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT chk_items_qty   CHECK (quantity > 0),
    CONSTRAINT chk_items_price CHECK (unit_price > 0),
    CONSTRAINT fk_items_order   FOREIGN KEY (order_id)   REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;
