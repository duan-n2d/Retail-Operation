WITH delivered_customer AS (
    -- Assuming delivered Journey 'Journey Test'
    SELECT
        Delivery.allocated_audience AS customer_id,
        Delivery.tracked_time,
        Delivery.journey_id,
        Delivery.id AS event_id,
        Journey.name AS journey_name,
        Journey.tracked_type,
        Journey.start_time,
        Journey.end_time,
        Journey.duration,
        Journey.tracked_type,
        Journey.status
    FROM
        Delivery
        JOIN Journey ON Delivery.journey_id = Journey.id
    WHERE
        Journey.name = 'Journey Test'
        AND Delivery.tracked_time BETWEEN timestamp '2025-01-01 00:00:00'
        and now()
),
trans_use_coupon AS (
    SELECT
        Promotion_Code.transaction_id,
        Promotion_Code.id AS promotion_code,
        Promotion_Code.journey_id,
        Transaction.customer_id,
        Transaction.tracked_time AS data_created,
        Transaction.revenue,
        Transaction.store_id,
        Promotion_Code.data_created AS allocated_time
    FROM
        Promotion_Code
        JOIN Transaction ON Promotion_Code.transaction_id = Transaction.id
    WHERE
        Promotion_Code.journey_id = 'Journey Test'
        AND Transaction.tracked_time BETWEEN timestamp '2025-01-01 00:00:00'
        and now()
),
trans_no_coupon AS (
    -- Customers are attracted by the journey but do not use the promotion code
    SELECT
        tnc.transaction_id,
        tnc.customer_id,
        tnc.data_created,
        tnc.revenue,
        tnc.store_id,
        tnc.promotion_code,
        tnc.journey_id,
        tnc.start_time,
        tnc.end_time,
        tnc.duration,
        tnc.tracked_type,
        tnc.tracked_time,
    FROM
        (
            SELECT
                Transaction.id AS transaction_id,
                Transaction.customer_id,
                Transaction.tracked_time AS date_created,
                Transaction.revenue,
                Transaction.store_id,
                NULL AS promotion_code,
                delivered_customer.journey_id,
                delivered_customer.start_time,
                delivered_customer.end_time,
                delivered_customer.duration,
                delivered_customer.tracked_type,
                delivered_customer.tracked_time,
                ROW_NUMBER() OVER (
                    PARTITION BY Transaction.id
                    ORDER BY
                        delivered_customer.tracked_time DESC
                ) AS index_transaction_story
            FROM
                Transaction
                JOIN delivered_customer ON Transaction.customer_id = delivered_customer.customer_id
            WHERE
                Transaction.tracked_time BETWEEN timestamp '2025-01-01 00:00:00'
                and now()
                AND Transaction.tracked_time BETWEEN delivered_customer.start_time
                AND delivered_customer.end_time
                AND Transaction.id NOT IN (
                    SELECT
                        trans_use_coupon.transaction_id
                    FROM
                        trans_use_coupon
                )
        ) AS tnc
    WHERE
        tnc.index_transaction_story = 1
),
trans_convert AS (
    SELECT
        tc.transaction_id,
        tc.promotion_code,
        tc.journey_id,
        tc.customer_id,
        tc.data_created,
        tc.revenue,
        tc.store_id,
        tc.allocated_time,
        Store.name AS store_name,
        Store.area AS store_area,
        Store.city AS store_city
    FROM
        (
            SELECT
                trans_use_coupon.transaction_id,
                trans_use_coupon.promotion_code,
                trans_use_coupon.journey_id,
                trans_use_coupon.customer_id,
                trans_use_coupon.data_created,
                trans_use_coupon.revenue,
                trans_use_coupon.store_id,
                trans_use_coupon.allocated_time
            FROM
                trans_use_coupon
            UNION
            ALL
            SELECT
                tnc.transaction_id,
                tnc.promotion_code,
                tnc.journey_id,
                tnc.customer_id,
                tnc.data_created,
                tnc.revenue,
                tnc.store_id,
                NULL AS allocated_time
            FROM
                trans_no_coupon tnc
        ) AS tc
        LEFT JOIN Store ON tc.store_id = Store.id
) -- Final result: Delivered LEFT JOIN Transaction Convert
SELECT
    dc.customer_id,
    dc.event_id,
    dc.journey_name,
    dc.tracked_type,
    dc.start_time,
    dc.end_time,
    dc.duration,
    dc.status,
    tc.transaction_id,
    tc.promotion_code,
    tc.revenue,
    tc.store_id,
    tc.store_name,
    tc.store_area,
    tc.store_city
FROM
    delivered_customer dc
    JOIN trans_convert tc ON dc.journey_id = tc.journey_id
    AND dc.customer_id = tc.customer_id