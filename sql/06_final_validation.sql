
-- SUPPLYFLOW: FINAL DATA QUALITY CHECKS

WITH lifecycle AS (
    SELECT
        p.order_id,
        p.is_late,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,

        EXTRACT(EPOCH FROM (
            o.order_delivered_carrier_date
            - o.order_approved_at
        )) / 86400.0 AS fulfillment_days,

        EXTRACT(EPOCH FROM (
            o.order_delivered_customer_date
            - o.order_delivered_carrier_date
        )) / 86400.0 AS transit_days

    FROM analytics.order_performance p
    JOIN raw.orders o
        ON p.order_id = o.order_id

    WHERE p.is_delivery_eligible
)

SELECT
    COUNT(*) AS eligible_orders,

    COUNT(*) FILTER (
        WHERE order_approved_at IS NULL
           OR order_delivered_carrier_date IS NULL
    ) AS missing_stage_dates,

    COUNT(*) FILTER (
        WHERE fulfillment_days < 0
           OR transit_days < 0
    ) AS negative_durations,

    COUNT(*) FILTER (
        WHERE fulfillment_days >= 0
          AND transit_days >= 0
    ) AS valid_lifecycle_orders,

    COUNT(*) FILTER (
        WHERE NOT (
            fulfillment_days >= 0
            AND transit_days >= 0
        ) OR fulfillment_days IS NULL
          OR transit_days IS NULL
    ) AS excluded_orders

FROM lifecycle;
