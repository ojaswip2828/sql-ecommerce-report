# SQL E-commerce Report

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/ojaswip2828/sql-ecommerce-report/blob/main/sql_ecommerce_report.ipynb)

46 SQL queries on a small e-commerce database: top products, customer spend, NULL handling, JOINs and DDL constraints. Runs in SQLite with nothing to install.

## Quick start

**Google Colab (easiest):** click the badge above → Runtime → Run all.

**Local:**
```bash
git clone https://github.com/ojaswip2828/sql-ecommerce-report.git
cd sql-ecommerce-report
python3 run.py              # builds the DB in memory and runs all 46 queries
python3 run.py > output.txt # save the results
```

## MySQL version

A tested MySQL 8.0 port is in `mysql/` (checked on 8.0.46). Same tables, data and 46 queries, plus Q47 listing constraints from `information_schema`.

```bash
cd mysql
mysql -u root -p < schema.sql        # creates database ecommerce_report
mysql -u root -p < seed.sql
mysql -u root -p --force --table < queries.sql   # --force: keep going past Q43-Q46 errors
```
Requires MySQL 8.0.16+ (older versions parse CHECK but ignore it). Or in MySQL Workbench: open each file and run it in order.

## Database

```
customers ──< orders ──< order_items >── products >── categories
```

| Table | Key columns | Constraints |
|---|---|---|
| `customers` | customer_id, name, email, phone, city | PK, `email` UNIQUE, NOT NULL, `phone` nullable |
| `categories` | category_id, name | PK, `name` UNIQUE |
| `products` | product_id, name, category_id, price, stock | FK (`ON DELETE SET NULL`), CHECK `price > 0`, CHECK `stock >= 0`, DEFAULT 0 |
| `orders` | order_id, customer_id, order_date, status, coupon_code | FK, CHECK status IN (pending, shipped, delivered, cancelled) |
| `order_items` | order_id, product_id, quantity, unit_price | composite PK, FKs (`ON DELETE CASCADE`), CHECK `quantity > 0` |

Seed data: 10 customers, 5 categories, 12 products, 16 orders, 26 order lines. It is deliberately imperfect so the edge cases show up: 3 customers with no phone, 2 customers who never ordered, 1 uncategorised product, 1 product that never sold, 1 empty category, 1 cancelled order.

## What's covered

| Section | Queries | Skills |
|---|---|---|
| A. Basics | Q1-Q6 | `WHERE`, `ORDER BY`, `LIMIT`, `IN`, `LIKE`, `GROUP BY` |
| B. Top products | Q7-Q14 | units and revenue rankings, best seller per category (`ROW_NUMBER`), never-sold products, monthly revenue |
| C. Customer spend | Q15-Q23 | top spenders, average order value, `HAVING`, repeat buyers, `RANK()`, `CASE` segments |
| D. NULL handling | Q24-Q31 | `IS NULL`, `COALESCE`, `NULLIF`, `COUNT(*)` vs `COUNT(col)`, the `= NULL` gotcha |
| E. JOINs | Q32-Q38 | INNER, LEFT, self, 5-table, `EXISTS` |
| F. DDL + constraints | Q39-Q46 | `CREATE INDEX`, `CREATE VIEW`, `ALTER TABLE`, CHECK / FK / UNIQUE / NOT NULL violations |

Revenue means `quantity * unit_price` on non-cancelled orders.

## Sample findings

- **Electronics** earns the most revenue (25,990), more than Fitness and Books.
- **Smartwatch** is the top product by revenue (9,998) and the only one above the average product revenue.
- **Air Fryer** never sold, and it has zero stock.
- **Ananya Gupta** is the top customer (9,195). Delhi is the top city (15,537).
- 3 of 10 customers have no phone number, so `COUNT(phone)` is 7 while `COUNT(*)` is 10.

## Things to know

- **Q43-Q46 are meant to fail.** They try to break a CHECK, FOREIGN KEY, UNIQUE and NOT NULL constraint to prove each one works.
- **SQLite vs MySQL:** the root files are SQLite (foreign keys need `PRAGMA foreign_keys = ON`, dates use `strftime`). The `mysql/` port uses `AUTO_INCREMENT`, `DECIMAL(10,2)`, `DATE`, named constraints and `DATE_FORMAT`.

## Files

| File | Purpose |
|---|---|
| `sql_ecommerce_report.ipynb` | Colab notebook, one query per cell |
| `schema.sql` | Tables and constraints |
| `seed.sql` | Sample data |
| `queries.sql` | All 46 queries |
| `run.py` | Local runner |
| `output.txt` | Saved results from `run.py` |
| `mysql/` | MySQL 8.0 `schema.sql`, `seed.sql`, `queries.sql`, `output.txt` |
