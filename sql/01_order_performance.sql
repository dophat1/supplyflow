
CREATE SCHEMA IF NOT EXISTS analytics;

CREATE OR REPLACE VIEW analytics.order_performance AS

WITH latest_reviews AS (
    SELECT
        order_id,
        review_score,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY
                review_answer_timestamp DESC NULLS LAST,
                review_id DESC
        ) AS rn
    FROM raw.order_reviews
)

SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    c.customer_state,

    r.review_score,

    CASE
        WHEN o.order_status = 'delivered'
         AND o.order_delivered_customer_date IS NOT NULL
         AND o.order_estimated_delivery_date IS NOT NULL
        THEN TRUE
        ELSE FALSE
    END AS is_delivery_eligible,

    CASE
        WHEN o.order_status = 'delivered'
         AND o.order_delivered_customer_date IS NOT NULL
         AND o.order_estimated_delivery_date IS NOT NULL
        THEN
            o.order_delivered_customer_date
            > o.order_estimated_delivery_date
        ELSE NULL
    END AS is_late,

    EXTRACT(
        EPOCH FROM (
            o.order_delivered_customer_date
            - o.order_purchase_timestamp
        )
    ) / 86400.0 AS delivery_days

FROM raw.orders o

LEFT JOIN raw.customers c
    ON o.customer_id = c.customer_id

LEFT JOIN latest_reviews r
    ON o.order_id = r.order_id
   AND r.rn = 1;
