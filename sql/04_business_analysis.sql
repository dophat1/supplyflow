
-- Analysis 1: Delivery performance by state
SELECT
    customer_state,
    COUNT(*) AS delivered_orders,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE is_late
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS late_rate_pct,

    ROUND(
        AVG(delivery_days)::numeric, 2
    ) AS avg_delivery_days,

    ROUND(
        AVG(review_score)::numeric, 2
    ) AS avg_review_score

FROM analytics.order_performance
WHERE is_delivery_eligible
GROUP BY customer_state
ORDER BY late_rate_pct DESC;


-- Analysis 2: Delivery times and review ratings
SELECT
    CASE
        WHEN delivery_days < 7 THEN 'Under 7 days'
        WHEN delivery_days < 14 THEN '7-13 days'
        WHEN delivery_days < 21 THEN '14-20 days'
        ELSE '21+ days'
    END AS delivery_time_group,

    COUNT(*) AS orders,

    ROUND(
        AVG(review_score)::numeric, 2
    ) AS avg_review_score,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE is_late
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS late_rate_pct

FROM analytics.order_performance
WHERE is_delivery_eligible
GROUP BY 1
ORDER BY 1;


-- Analysis 3: Orders that experienced
-- the longest delivery times
SELECT
    order_id,
    customer_state,
    ROUND(delivery_days::numeric, 2) AS delivery_days,
    is_late,
    review_score

FROM analytics.order_performance
WHERE is_delivery_eligible
ORDER BY delivery_days DESC
LIMIT 20;
