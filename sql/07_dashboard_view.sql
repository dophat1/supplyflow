
CREATE OR REPLACE VIEW analytics.dashboard_orders AS

SELECT
    p.order_id,
    p.order_status,
    p.order_purchase_timestamp::date AS purchase_date,

    DATE_TRUNC(
        'month', p.order_purchase_timestamp
    )::date AS purchase_month,

    p.customer_state,
    p.review_score,
    p.is_delivery_eligible,
    p.is_late,

    ROUND(p.delivery_days::numeric, 2) AS delivery_days,

    CASE
        WHEN p.review_score <= 2 THEN 1
        WHEN p.review_score IS NOT NULL THEN 0
        ELSE NULL
    END AS low_rating,

    CASE
        WHEN p.is_late THEN 'Late'
        WHEN p.is_late = FALSE THEN 'On time'
        ELSE 'Not eligible'
    END AS delivery_status,

    CASE
        WHEN o.order_approved_at IS NOT NULL
         AND o.order_delivered_carrier_date IS NOT NULL
         AND o.order_delivered_carrier_date
             >= o.order_approved_at
        THEN ROUND(
            (
                EXTRACT(EPOCH FROM (
                    o.order_delivered_carrier_date
                    - o.order_approved_at
                )) / 86400.0
            )::numeric, 2
        )
        ELSE NULL
    END AS fulfillment_days,

    CASE
        WHEN o.order_delivered_carrier_date IS NOT NULL
         AND o.order_delivered_customer_date IS NOT NULL
         AND o.order_delivered_customer_date
             >= o.order_delivered_carrier_date
        THEN ROUND(
            (
                EXTRACT(EPOCH FROM (
                    o.order_delivered_customer_date
                    - o.order_delivered_carrier_date
                )) / 86400.0
            )::numeric, 2
        )
        ELSE NULL
    END AS transit_days

FROM analytics.order_performance p

JOIN raw.orders o
    ON p.order_id = o.order_id;
