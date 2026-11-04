
-- Check 1: Order uniqueness
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(*) - COUNT(DISTINCT order_id) AS duplicates
FROM analytics.order_performance;


-- Check 2: Delivery eligibility
SELECT
    order_status,
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (
        WHERE is_delivery_eligible
    ) AS eligible_orders
FROM analytics.order_performance
GROUP BY order_status
ORDER BY total_orders DESC;


-- Check 3: Missing reviews
SELECT
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (
        WHERE review_score IS NULL
    ) AS missing_review_scores
FROM analytics.order_performance;


-- Check 4: Invalid delivery durations
SELECT
    COUNT(*) AS negative_delivery_durations
FROM analytics.order_performance
WHERE delivery_days < 0;
