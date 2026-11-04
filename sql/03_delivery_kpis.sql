
-- KPI 1: Overall delivery performance
SELECT
    COUNT(*) AS delivered_orders,

    COUNT(*) FILTER (
        WHERE is_late
    ) AS late_orders,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE is_late
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS late_delivery_rate_pct,

    ROUND(
        AVG(delivery_days)::numeric, 2
    ) AS avg_delivery_days

FROM analytics.order_performance
WHERE is_delivery_eligible;


-- KPI 2: Average customer review scores
SELECT
    is_late,
    COUNT(*) AS orders,
    COUNT(review_score) AS reviewed_orders,
    ROUND(
        AVG(review_score)::numeric, 2
    ) AS avg_review_score
FROM analytics.order_performance
WHERE is_delivery_eligible
GROUP BY is_late;


-- KPI 3: Monthly delivery performance
SELECT
    DATE_TRUNC(
        'month', order_purchase_timestamp
    )::date AS order_month,

    COUNT(*) AS delivered_orders,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE is_late
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS late_delivery_rate_pct

FROM analytics.order_performance
WHERE is_delivery_eligible
GROUP BY 1
ORDER BY 1;
