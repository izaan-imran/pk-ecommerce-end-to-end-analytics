USE pk_ecommerce;
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id) AS total_orders,
       COUNT(DISTINCT customer_id) AS total_customers,
       MIN(created_at) AS first_order,
       MAX(created_at) AS last_order
FROM orders_clean;

-- 1. MONTHLY ORDERS AND REVENUE TREND
-- Question: How are orders and revenue changing month by month?
SELECT `year_month`,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(SUM(item_total)) AS gross_revenue,
       ROUND(SUM(net_revenue)) AS net_revenue
FROM orders_clean
GROUP BY `year_month`
ORDER BY `year_month`;

-- 2. ORDER STATUS BREAKDOWN
-- Question: What % of orders are Completed, Cancelled, Refunded?
SELECT status_clean,
       COUNT(*) AS order_lines,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM orders_clean
GROUP BY status_clean
ORDER BY order_lines DESC;

-- 3. COD vs PREPAID FAILURE RATE (MAIN QUESTION)
-- Question: Do COD orders fail more than prepaid orders?

SELECT payment_type,
       COUNT(*) AS final_orders,
       ROUND(100 * AVG(is_cancelled), 2) AS cancel_rate_pct,
       ROUND(100 * AVG(is_refunded), 2) AS refund_rate_pct,
       ROUND(100 * AVG(is_failed), 2) AS failed_rate_pct
FROM orders_clean
WHERE is_final = 1
  AND payment_type <> 'Store Credit'
GROUP BY payment_type
ORDER BY failed_rate_pct DESC;

-- 3A. FAILURE RATE BY INDIVIDUAL PAYMENT METHOD
-- Question: Which prepaid method is driving the high cancellation rate?
SELECT payment_method,
       COUNT(*) AS final_orders,
       ROUND(100 * AVG(is_cancelled), 2) AS cancel_rate_pct,
       ROUND(100 * AVG(is_refunded), 2) AS refund_rate_pct
FROM orders_clean
WHERE is_final = 1
GROUP BY payment_method
HAVING COUNT(*) > 500
ORDER BY cancel_rate_pct DESC;

-- 3B. FAILURE RATE BY PAYMENT TYPE AND YEAR
-- Question: Is the prepaid cancellation problem constant or limited to a period?
SELECT year,
       payment_type,
       COUNT(*) AS final_orders,
       ROUND(100 * AVG(is_cancelled), 2) AS cancel_rate_pct,
       ROUND(100 * AVG(is_refunded), 2) AS refund_rate_pct
FROM orders_clean
WHERE is_final = 1
  AND payment_type <> 'Store Credit'
GROUP BY year, payment_type
ORDER BY year, payment_type;

-- 3C. PREPAID CANCELLATION RATE BY CATEGORY
-- Question: Is it one category or everywhere?
SELECT category_name_1 AS category,
       COUNT(*) AS final_orders,
       ROUND(100 * AVG(is_cancelled), 2) AS cancel_rate_pct
FROM orders_clean
WHERE is_final = 1
  AND payment_type = 'Prepaid'
GROUP BY category_name_1
HAVING COUNT(*) > 500
ORDER BY cancel_rate_pct DESC;

-- 4. CATEGORY-WISE FAILURE RATE
-- Question: Which categories have the highest cancel/refund rate?
SELECT category_name_1 AS category,
       COUNT(*) AS final_orders,
       ROUND(100 * AVG(is_cancelled), 2) AS cancel_rate_pct,
       ROUND(100 * AVG(is_refunded), 2) AS refund_rate_pct,
       ROUND(100 * AVG(is_failed), 2) AS failed_rate_pct
FROM orders_clean
WHERE is_final = 1
GROUP BY category_name_1
HAVING COUNT(*) > 500
ORDER BY failed_rate_pct DESC;

-- 5. DISCOUNT BAND vs FAILURE RATE
-- Question: Do heavily discounted orders fail more?
SELECT discount_band,
       COUNT(*) AS final_orders,
       ROUND(100 * AVG(is_failed), 2) AS failed_rate_pct
FROM orders_clean
WHERE is_final = 1
GROUP BY discount_band
ORDER BY FIELD(discount_band, 'No discount', '1-10%', '11-25%', '26-50%', '50%+');

-- 5B. DISCOUNT BAND AND PAYMENT TYPE
-- Question: Is the discount pattern explained by payment type?
SELECT discount_band,
       payment_type,
       COUNT(*) AS final_orders,
       ROUND(100 * AVG(is_failed), 2) AS failed_rate_pct
FROM orders_clean
WHERE is_final = 1
  AND payment_type <> 'Store Credit'
GROUP BY discount_band, payment_type
ORDER BY FIELD(discount_band, 'No discount', '1-10%', '11-25%', '26-50%', '50%+'), payment_type;

-- 6. ORDER VALUE BAND vs FAILURE RATE
-- Question: Do high-value orders fail more than low-value ones?
SELECT value_band,
       COUNT(*) AS final_orders,
       ROUND(100 * AVG(is_failed), 2) AS failed_rate_pct
FROM orders_clean
WHERE is_final = 1
GROUP BY value_band
ORDER BY FIELD(value_band, 'Low', 'Medium', 'High', 'Premium');

-- 6B. ORDER VALUE BAND AND PAYMENT TYPE
-- Question: Does order value still matter after separating COD and Prepaid?
SELECT value_band,
       payment_type,
       COUNT(*) AS final_orders,
       ROUND(100 * AVG(is_failed), 2) AS failed_rate_pct
FROM orders_clean
WHERE is_final = 1
  AND payment_type <> 'Store Credit'
GROUP BY value_band, payment_type
ORDER BY FIELD(value_band, 'Low', 'Medium', 'High', 'Premium'), payment_type;

-- 7. MONTHLY FAILURE RATE AND MONTH-OVER-MONTH CHANGE
-- Question: In which months did failures spike?
WITH monthly AS (
    SELECT `year_month`,
           COUNT(*) AS final_orders,
           ROUND(100 * AVG(is_failed), 2) AS failed_rate_pct
    FROM orders_clean
    WHERE is_final = 1
    GROUP BY `year_month`
)
SELECT `year_month`,
       final_orders,
       failed_rate_pct,
       LAG(failed_rate_pct) OVER (ORDER BY `year_month`) AS prev_month_rate,
       ROUND(failed_rate_pct - LAG(failed_rate_pct) OVER (ORDER BY `year_month`), 2) AS change_pts
FROM monthly
ORDER BY `year_month`;

-- 8. GROSS vs NET REVENUE BY CATEGORY
-- Question: How much revenue is lost to cancellations/refunds per category?
WITH category_revenue AS (
    SELECT category_name_1 AS category,
           SUM(item_total) AS gross_revenue,
           SUM(net_revenue) AS net_revenue
    FROM orders_clean
    GROUP BY category_name_1
)
SELECT category,
       ROUND(gross_revenue) AS gross_revenue,
       ROUND(net_revenue) AS net_revenue,
       ROUND(gross_revenue - net_revenue) AS revenue_lost,
       ROUND(100 * (gross_revenue - net_revenue) / gross_revenue, 2) AS lost_pct
FROM category_revenue
ORDER BY gross_revenue DESC;

-- 9. REPEAT vs ONE-TIME CUSTOMERS
-- Question: What % of customers come back, and do they fail less?
WITH customer_orders AS (
    SELECT customer_id,
           COUNT(DISTINCT order_id) AS total_orders
    FROM orders_clean
    GROUP BY customer_id
),
customer_segment AS (
    SELECT customer_id,
           CASE WHEN total_orders = 1 THEN 'One-time'
                WHEN total_orders BETWEEN 2 AND 3 THEN 'Repeat (2-3)'
                ELSE 'Loyal (4+)' END AS segment
    FROM customer_orders
)
SELECT s.segment,
       COUNT(DISTINCT s.customer_id) AS customers,
       ROUND(100 * COUNT(DISTINCT s.customer_id) / SUM(COUNT(DISTINCT s.customer_id)) OVER (), 2) AS pct_customers,
       ROUND(100 * AVG(o.is_failed), 2) AS failed_rate_pct
FROM customer_segment s
JOIN orders_clean o ON o.customer_id = s.customer_id
WHERE o.is_final = 1
GROUP BY s.segment
ORDER BY customers DESC;

-- 10. HIGH-RISK SEGMENT
-- Question: Which COD + value + discount combinations fail the most?
WITH segments AS (
    SELECT is_failed,
           CASE WHEN payment_type = 'COD'
                     AND value_band IN ('High', 'Premium')
                     AND discount_pct > 25 THEN '1. COD + High Value + Big Discount'
                WHEN payment_type = 'COD'
                     AND value_band IN ('High', 'Premium') THEN '2. COD + High Value'
                WHEN payment_type = 'COD' THEN '3. Other COD'
                ELSE '4. Prepaid' END AS risk_segment
    FROM orders_clean
    WHERE is_final = 1
      AND payment_type <> 'Store Credit'
)
SELECT risk_segment,
       COUNT(*) AS final_orders,
       ROUND(100 * AVG(is_failed), 2) AS failed_rate_pct,
       ROUND(100 * AVG(is_failed) -
             (SELECT 100 * AVG(is_failed) FROM orders_clean
              WHERE is_final = 1 AND payment_type <> 'Store Credit'), 2) AS diff_vs_overall_pts
FROM segments
GROUP BY risk_segment
ORDER BY risk_segment;

-- TOTAL REVENUE LEAKAGE (for the dashboard KPI card)
-- Question: How much money was lost to cancellations and refunds?
SELECT ROUND(SUM(item_total)) AS gross_revenue,
       ROUND(SUM(net_revenue)) AS net_revenue,
       ROUND(SUM(item_total) - SUM(net_revenue)) AS revenue_lost,
       ROUND(100 * (SUM(item_total) - SUM(net_revenue)) / SUM(item_total), 2) AS lost_pct
FROM orders_clean
WHERE is_final = 1;
