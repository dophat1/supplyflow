
WITH lifecycle AS (
    SELECT
        o.order_id,
        p.customer_state,
        p.is_late,

        EXTRACT(EPOCH FROM (
            o.order_delivered_carrier_date
            - o.order_approved_at::timestamp
        )) / 86400.0 AS fulfillment_days,

        EXTRACT(EPOCH FROM (
            o.order_delivered_customer_date
            - o.order_delivered_carrier_date
        )) / 86400.0 AS transit_days

    FROM raw.orders o

    JOIN analytics.order_performance p
        ON o.order_id = p.order_id

    WHERE p.is_delivery_eligible
)

SELECT
    CASE
        WHEN is_late THEN 'Late'
        ELSE 'On time'
    END AS delivery_status,

    COUNT(*) AS orders,

    ROUND(
        AVG(fulfillment_days)::numeric, 2
    ) AS avg_fulfillment_days,

    ROUND(
        AVG(transit_days)::numeric, 2
    ) AS avg_transit_days

FROM lifecycle

WHERE fulfillment_days >= 0
  AND transit_days >= 0

GROUP BY is_late
ORDER BY is_late;
