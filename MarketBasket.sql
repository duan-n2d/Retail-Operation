-- This script performs market basket analysis to find product (Customer will be bought after last purchase) associations based on transaction data.
-- Look back 3 months from the last purchase date to find the next product purchased.
WITH trans AS (
    SELECT
        t.customer_id,
        t.date_created,
        t.id AS transaction_id
    FROM Transaction t
    WHERE t.flag <> 2
)
-- More than 2 transactions
, cus AS (
    SELECT
        trans.customer_id,
        COUNT(trans.transaction_id) AS number_of_transactions,
        MIN(trans.date_created) AS first_date_created
    FROM trans
    GROUP BY trans.customer_id
    HAVING COUNT(trans.transaction_id) > 2
)
, rank_trans AS (
    SELECT
        trans.customer_id,
        trans.transaction_id,
        trans.date_created AS transaction_date,
        ROW_NUMBER() OVER (PARTITION BY trans.customer_id ORDER BY trans.date_created) AS trans_no
    FROM trans
    JOIN cus ON trans.customer_id = cus.customer_id
)
, grouped_trans AS (
    SELECT
        r1.transaction_id AS first_transaction_id,
        r2.transaction_id AS second_transaction_id,
        r3.transaction_id AS third_transaction_id,
        r1.customer_id,
        r1.transaction_date AS start_date,
        r3.transaction_date AS end_date,
    FROM rank_trans r1
    JOIN rank_trans r2 ON r1.customer_id = r2.customer_id
    AND (r1.trans_no + 1) = r2.trans_no
    JOIN rank_trans r3 ON r1.customer_id = r3.customer_id
    AND (r1.trans_no + 2) = r3.trans_no
    WHERE
        date_diff('day', r3.transaction_date, r1.transaction_date) <= 90
)
,grouped_item AS (
    SELECT
        gt.customer_id,
        gt.start_date,
        gt.end_date,
        trans.product_id
    FROM grouped_trans gt
    JOIN trans ON gt.first_transaction = trans.transaction_id
    UNION ALL
    SELECT
        gt.customer_id,
        gt.start_date,
        gt.end_date,
        t2.product_id
    FROM grouped_item gt
    JOIN trans t2 ON gt.second_transaction = t2.transaction_id
    UNION ALL
    SELECT
        gt.customer_id,
        gt.start_date,
        gt.end_date,
        t3.product_id
    FROM grouped_item gt
    JOIN trans t3 ON gt.third_transaction_id = t3.transaction_id
)
, product_info AS (
    SELECT
        DISTINCT
        grouped_item.customer_id,
        p.name,
        grouped_item.start_date,
        grouped_item.end_date
    FROM grouped_item
    JOIN Product p ON grouped_item.product_id = p.id
)
, product_grouped AS (
    SELECT
        p1.customer_id,
        p1.name AS based_product,
        p2.name AS uplift_product,
        CONCAT(P1.name, ' || ', p2.name) AS product_pair
    FROM product_info p1
    JOIN product_info p2 
        ON p1.customer_id = p2.customer_id
        AND p1.start_date = p2.start_date
        AND p1.end_date = p2.end_date
        AND p1.name <> p2.name
)
, pre_gr AS (
    SELECT
        product_grouped.customer_id,
        product_grouped.based_product,
        product_grouped.uplift_product,
        COUNT(product_grouped.customer_id) AS customer_count
    FROM product_grouped
    GROUP BY
        product_grouped.customer_id,
        product_grouped.based_product,
        product_grouped.uplift_product
)
, count_name_1 AS (
    SELECT
        product_info.name AS product_name,
        COUNT(DISTINCT product_info.customer_id) AS customer_base_count
    FROM product_info
    GROUP BY product_info.name
    ORDER BY customer_base_count DESC
)
SELECT
    pre_gr.based_product,
    count_name_1.customer_base_count,
    pre_gr.uplift_product,
    pre_gr.product_pair,
    pre_gr.customer_count AS combo_count,
    ROUND(100 * CAST(pre_gr.customer_count AS DOUBLE) / count_name_1.customer_base_count, 2) AS combo_ratio
FROM pre_gr
JOIN count_name_1 ON pre_gr.based_product = count_name_1.product_name
ORDER BY count_name_1.customer_base_count DESC, combo_ratio DESC;