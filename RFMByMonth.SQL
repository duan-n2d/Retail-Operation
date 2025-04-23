-- Run this script to get the RFM movement of customers
SELECT
    rfm.customer_id,
    rfm.tracked_month,
    rfm.recency_score,
    rfm.recency_days,
    rfm.frequency_score,
    rfm.monetary_score,
    rfm.frequency,
    rfm.monetary,
    rfm.rfm_score,
    rfm.rfm_persona
FROM
    CustomerSegmentByRFM AS rfm 
-- Write mode: insert new and update existing records. Keys: customer_id, tracked_month