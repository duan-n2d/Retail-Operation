WITH rfm AS (
    SELECT
        RFMByMonth.persona,
        RFMByMonth.transaction_month,
        COUNT(RFMByMonth.customer_id) AS customer_count,
        SUM(RFMByMonth.monetary) AS total_spend
    FROM
        RFMByMonth
    GROUP BY
        RFMByMonth.persona,
        RFMByMonth.transaction_month
)
, rfm_next_month AS (
    SELECT
        rfm.persona,
        rfm.transaction_month,
        LEAD(rfm.transaction_month) OVER (PARTITION BY rfm.persona ORDER BY rfm.transaction_month) AS next_month,
        rfm.customer_count,
        rfm.total_spend
    FROM
        rfm
)
, rfm_movement AS (
    SELECT
        rfm.persona,
        rfm.transaction_month,
        rfm.customer_count,
        rfm.total_spend,
        COALESCE(rfm_next_month.customer_count, 0) AS next_month_customer_count,
        COALESCE(rfm_next_month.total_spend, 0) AS next_month_total_spend
    FROM
        rfm
    LEFT JOIN
        rfm_next_month ON rfm.persona = rfm_next_month.persona AND rfm.transaction_month = rfm_next_month.transaction_month
)
SELECT
    rfm_movement.persona,
    rfm_movement.transaction_month,
    rfm_movement.customer_count,
    rfm_movement.total_spend,
    rfm_movement.next_month_customer_count,
    rfm_movement.next_month_total_spend,
    (rfm_movement.next_month_customer_count - rfm_movement.customer_count) AS customer_change,
    (rfm_movement.next_month_total_spend - rfm_movement.total_spend) AS spend_change
FROM
    rfm_movement
ORDER BY
    rfm_movement.persona,
    rfm_movement.transaction_month;
-- This query analyzes the movement of customers between different RFM personas over time.