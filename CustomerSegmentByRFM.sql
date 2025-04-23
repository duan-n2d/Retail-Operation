-- RFM Analysis Monthly
WITH trans_last_year AS (
    SELECT
        t.customer_id,
        MIN(date_diff('day', t.tracked_time, date_trunc('month', now()))) AS recency_days,
        COUNT(DISTINCT t.id) AS frequency,
        SUM(t.revenue) AS monetary
    FROM
        Transaction t
    WHERE
        t.tracked_time >= date_add('month', -12, date_trunc('month', now()))
        AND t.tracked_time < date_trunc('month', now())
        AND t.customer_id IS NOT NULL
    GROUP BY
        t.customer_id
)
, customer_rfm AS (
-- Assuming: Recency 21, 50, 130, 258 respectively. Frequency 1, 2, 3, 4 respectively. Monetary 200000, 400000, 550000, 1200000 respectively.
    SELECT
        trans_last_year.customer_id,
        date_trunc('month', now()) AS tracked_month,
        CASE
            WHEN trans_last_year.recency_days <= 21 THEN 5
            WHEN trans_last_year.recency_days <= 50 THEN 4
            WHEN trans_last_year.recency_days <= 130 THEN 3
            WHEN trans_last_year.recency_days <= 258 THEN 2
            ELSE 1
        END AS recency_score,
        trans_last_year.recency_days,
        CASE
            WHEN trans_last_year.frequency > 4 THEN 5
            WHEN trans_last_year.frequency > 3 THEN 4
            WHEN trans_last_year.frequency > 2 THEN 3
            WHEN trans_last_year.frequency > 1 THEN 2
            ELSE 1
        END AS frequency_score,
        trans_last_year.frequency,
        CASE
            WHEN trans_last_year.monetary > 1200000 THEN 5
            WHEN trans_last_year.monetary > 550000 THEN 4
            WHEN trans_last_year.monetary > 400000 THEN 3
            WHEN trans_last_year.monetary > 200000 THEN 2
            ELSE 1
        END AS monetary_score,
        trans_last_year.monetary
    FROM trans_last_year
, rfm_score AS (
    SELECT
        customer_rfm.customer_id,
        customer_rfm.tracked_month,
        customer_rfm.recency_score,
        customer_rfm.recency_days,
        customer_rfm.frequency_score,
        customer_rfm.monetary_score,
        customer_rfm.frequency,
        customer_rfm.monetary,
        customer_rfm.recency_score*100 + customer_rfm.frequency_score*10 + customer_rfm.monetary_score AS rfm_score
    FROM customer_rfm
)
-- , rfm_persona AS (
    SELECT
        rfm_score.customer_id,
        rfm_score.tracked_month,
        rfm_score.recency_score,
        rfm_score.recency_days,
        rfm_score.frequency_score,
        rfm_score.monetary_score,
        rfm_score.frequency,
        rfm_score.monetary,
        rfm_score.rfm_score,
        -- Group 11 segmentation
        CASE
            WHEN rfm_score.rfm_score IN (555, 554, 544, 545, 454, 455, 445) THEN '1. Champion'
            WHEN rfm_score.rfm_score IN (543, 444, 435, 355, 354, 345, 344, 335) THEN '2. Loyal'
            WHEN rfm_score.rfm_score IN (553, 551, 552, 541, 542, 533, 532, 531, 452, 451, 442, 441, 431, 453, 433, 432, 423, 353, 352, 351, 342, 341, 333) THEN '3. Potential Loyalist'
            WHEN rfm_score.rfm_score IN (512,511 ,422 ,421 ,412 ,411 ,311) THEN '4 New Customers'
            WHEN rfm_score.rfm_score IN (525 ,524 ,523 ,522 ,521 ,515 ,514 ,513 ,425 ,424 ,413 ,414 ,415 ,315 ,314 ,313) THEN '5. Promising'
            WHEN rfm_score.rfm_score IN (155 ,154 ,144 ,214 ,215 ,115 ,114 ,113) THEN '6 Cannot Lose Them'
            WHEN rfm_score.rfm_score IN (535 ,534 ,443 ,434 ,343 ,334 ,325 ,324) THEN '7 Needs attention'
            WHEN rfm_score.rfm_score IN (332 ,322 ,231 ,241 ,251 ,233 ,232) THEN '8 Hibernating customers'
            WHEN rfm_score.rfm_score IN (255 ,254) THEN '9 At Risk'
            WHEN rfm_score.rfm_score IN (245 ) THEN '10 About To Sleep'
            WHEN rfm_score.rfm_score IN (111 ) THEN '11 Lost customers'
        END AS rfm_persona
    FROM rfm_score
-- )
-- Note: RFM look back period is 12 months, and the RFM score is calculated based on the last month of the look back period.
-- Write mode: OVERWRITE