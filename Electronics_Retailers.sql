-- ============================================================
--  ELECTRONICS RETAILER PROJECT - SQL 
-- ============================================================

-- ============================================================
-- 1 DATABASE CONTEXT
-- ============================================================
-- Connect to your database
-- \c electronics_retailer;

-- ============================================================
-- 2️ DATA CLEANING
-- ============================================================

-- ALTER TABLE sales ADD COLUMN unit_price_usd NUMERIC(10,2);
-- UPDATE sales s
-- SET unit_price_usd = ROUND(p.unit_price_usd * c.conversion_to_usd, 2)
-- FROM currency c
-- WHERE s.currency_code = c.currency_code;

-- ============================================================
-- 3️ DATA VALIDATION
-- Check for missing or inconsistent data
-- ============================================================

SELECT * FROM sales WHERE quantity IS NULL;
SELECT DISTINCT currency_code FROM sales;

-- ============================================================
-- 4️ ANALYSIS QUERIES
-- ============================================================

-- Q1️1 Total revenue per customer
SELECT
    s.customer_key,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(p.unit_price_usd * s.quantity) AS total_revenue_usd
FROM sales s
JOIN products p ON s.product_key = p.product_key
JOIN customers c ON s.customer_key = c.customer_key
GROUP BY s.customer_key, customer_name
ORDER BY total_revenue_usd DESC;

-- Q2️ Revenue by store (CTE example)
WITH rev_by_store AS (
    SELECT
        st.store_key,
        st.country,
        st.states,
        SUM(p.unit_price_usd * s.quantity) AS revenue_usd
    FROM sales s
    JOIN products p ON s.product_key = p.product_key
    JOIN stores st ON s.store_key = st.store_key
    GROUP BY st.store_key, st.country, st.states
)
SELECT * FROM rev_by_store ORDER BY revenue_usd DESC;

-- Q3️ Top-selling products
SELECT
    p.product_name,
    p.category,
    SUM(s.quantity) AS total_units_sold,
    SUM(p.unit_price_usd * s.quantity) AS total_revenue_usd
FROM sales s
JOIN products p ON s.product_key = p.product_key
GROUP BY p.product_name, p.category
ORDER BY total_revenue_usd DESC;

-- Q4️ Monthly revenue trend
SELECT
    DATE_TRUNC('month', s.order_date) AS month,
    SUM(p.unit_price_usd * s.quantity) AS monthly_revenue
FROM sales s
JOIN products p ON s.product_key = p.product_key
GROUP BY month
ORDER BY month;

-- Q5️ Best customers (repeat buyers)
SELECT
    s.customer_key,
    COUNT(DISTINCT s.order_number) AS num_orders,
    SUM(p.unit_price_usd * s.quantity) AS total_spent
FROM sales s
JOIN products p ON s.product_key = p.product_key
GROUP BY s.customer_key
HAVING COUNT(DISTINCT s.order_number) > 1
ORDER BY total_spent DESC;

-- Q6️ Revenue by category
SELECT
    p.category,
    SUM(p.unit_price_usd * s.quantity) AS revenue_by_category
FROM sales s
JOIN products p ON s.product_key = p.product_key
GROUP BY p.category
ORDER BY revenue_by_category DESC;

-- Q7️ Top 3 stores per country (with revenue)
WITH store_revenue AS (
    SELECT 
        s.store_key,
        SUM(s.quantity * p.unit_price_usd) AS total_revenue_usd
    FROM sales s
    JOIN products p ON s.product_key = p.product_key
    GROUP BY s.store_key
),
ranked_stores AS (
    SELECT 
        st.store_key,
        st.country,
        st.states,
        sr.total_revenue_usd,
        ROW_NUMBER() OVER (
            PARTITION BY st.country 
            ORDER BY sr.total_revenue_usd DESC
        ) AS row_num
    FROM store_revenue sr
    JOIN stores st ON sr.store_key = st.store_key
)
SELECT 
    store_key,
    country,
    states,
    ROUND(total_revenue_usd, 2) AS total_revenue_usd
FROM ranked_stores
WHERE row_num <= 3
ORDER BY country, total_revenue_usd DESC;

-- Q8️ Store revenue share (%) within each country
WITH total_revenue AS (
    SELECT 
        s.store_key,
        st.country,
        st.states,
        SUM(s.quantity * p.unit_price_usd) AS total_revenue_usd,
        RANK() OVER (
            PARTITION BY st.country 
            ORDER BY SUM(s.quantity * p.unit_price_usd) DESC
        ) AS store_rank
    FROM sales s
    JOIN stores st ON s.store_key = st.store_key
    JOIN products p ON s.product_key = p.product_key
    GROUP BY s.store_key, st.country, st.states
)
SELECT 
    country,
    states,
    store_key,
    ROUND(total_revenue_usd, 2) AS store_revenue_usd,
    ROUND(SUM(total_revenue_usd) OVER (PARTITION BY country), 2) AS country_total_usd,
    ROUND(
        (total_revenue_usd * 100.0) / 
        SUM(total_revenue_usd) OVER (PARTITION BY country), 
        2
    ) AS revenue_share_percent,
    store_rank
FROM total_revenue
ORDER BY country, store_rank;

-- Q9️ Underperforming stores (bottom quartile)
WITH total_revenue AS (
    SELECT 
        s.store_key,
        st.country,
        st.states,
        SUM(s.quantity * p.unit_price_usd) AS total_revenue_usd,
        RANK() OVER (
            PARTITION BY st.country 
            ORDER BY SUM(s.quantity * p.unit_price_usd) DESC
        ) AS store_rank
    FROM sales s
    JOIN stores st ON s.store_key = st.store_key
    JOIN products p ON s.product_key = p.product_key
    GROUP BY s.store_key, st.country, st.states
),
Ranked_stores AS (
    SELECT 
        country,
        states,
        store_key,
        ROUND(total_revenue_usd, 2) AS store_revenue_usd,
        NTILE(4) OVER (
            PARTITION BY country 
            ORDER BY total_revenue_usd DESC
        ) AS quartile_partition,
        store_rank
    FROM total_revenue
)
SELECT 
    store_key, 
    country, 
    states, 
    store_revenue_usd,
    quartile_partition
FROM Ranked_stores
WHERE quartile_partition = 4
ORDER BY country, store_revenue_usd;

-- Q10️ Year-over-year revenue trend (by country)
WITH total_revenue AS (
    SELECT 
        st.country,
        EXTRACT(YEAR FROM s.order_date) AS year,
        SUM(s.quantity * p.unit_price_usd) AS country_revenue
    FROM sales s
    JOIN stores st ON s.store_key = st.store_key
    JOIN products p ON s.product_key = p.product_key
    GROUP BY st.country, EXTRACT(YEAR FROM s.order_date)
)
SELECT 
    country,
    year,  
    country_revenue,
    LAG(country_revenue) OVER (PARTITION BY country ORDER BY year) AS prev_year_revenue,
    ROUND(country_revenue - LAG(country_revenue) OVER (PARTITION BY country ORDER BY year), 2) AS change_over_year,
    ROUND(
        ((country_revenue - LAG(country_revenue) OVER (PARTITION BY country ORDER BY year)) * 100.0) /
        NULLIF(LAG(country_revenue) OVER (PARTITION BY country ORDER BY year), 0),
        2
    ) AS growth_percentage
FROM total_revenue
ORDER BY country, year;

-- Q11️ Category revenue growth year-over-year
WITH revenue_category AS (
    SELECT 
        p.category, 
        EXTRACT(YEAR FROM s.order_date) AS year,
        SUM(p.unit_price_usd * s.quantity) AS catg_revenue
    FROM sales s 
    JOIN products p ON s.product_key = p.product_key 
    GROUP BY p.category, EXTRACT(YEAR FROM s.order_date)
)
SELECT 
    category,
    year,
    ROUND(catg_revenue, 2) AS catg_revenue,
    LAG(catg_revenue) OVER (PARTITION BY category ORDER BY year) AS prev_year_rev,
    ROUND(catg_revenue - LAG(catg_revenue) OVER (PARTITION BY category ORDER BY year), 2) AS change_over_year,
    ROUND(
        ((catg_revenue - LAG(catg_revenue) OVER (PARTITION BY category ORDER BY year)) * 100.0) /
        NULLIF(LAG(catg_revenue) OVER (PARTITION BY category ORDER BY year), 0),
        2
    ) AS growth_percentage  
FROM revenue_category
ORDER BY change_over_year DESC;

-- Q12️ Profit margin by category (advanced)
SELECT
    p.category,
    ROUND(SUM((p.unit_price_usd - p.unit_cost_usd) * s.quantity), 2) AS total_profit_usd,
    ROUND(
        SUM((p.unit_price_usd - p.unit_cost_usd) * s.quantity) /
        NULLIF(SUM(p.unit_price_usd * s.quantity), 0) * 100, 
        2
    ) AS profit_margin_percent
FROM sales s
JOIN products p ON s.product_key = p.product_key
GROUP BY p.category
ORDER BY total_profit_usd DESC;


