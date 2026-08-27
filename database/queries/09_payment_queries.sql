-- ============================================================
-- 09_payment_queries.sql
-- Payments, Gateway Transactions, and Multi-Entity Settlement Splits
-- ============================================================

-- Q9.1: Payment & Settlement Distribution Breakdown (BR-F001 to BR-F013)
-- Customer Payment -> Settlement -> Settlement Details (Farmer, Aggregator, Delivery Partner, Platform)
SELECT 
    p.payment_id,
    o.order_id,
    p.amount AS customer_paid_amount,
    p.payment_method,
    p.payment_status,
    s.settlement_id,
    sd.entity_type,
    sd.percentage,
    sd.amount AS entity_payout_amount,
    sd.remarks
FROM payment p
JOIN orders o ON p.order_id = o.order_id
LEFT JOIN settlement s ON p.payment_id = s.payment_id
LEFT JOIN settlement_detail sd ON s.settlement_id = sd.settlement_id
ORDER BY p.payment_id, sd.entity_type;
