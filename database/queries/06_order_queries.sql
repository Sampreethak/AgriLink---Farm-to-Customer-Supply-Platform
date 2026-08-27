-- ============================================================
-- 06_order_queries.sql
-- Customer Orders, Line Items, Coupons, and Status Tracking
-- ============================================================

-- Q6.1: Customer Order Summary with line item breakdown and payment status (BR-D001 to BR-D007)
SELECT 
    o.order_id,
    u.phone AS customer_phone,
    o.order_date,
    o.order_status,
    o.payment_status,
    c.crop_name,
    oi.quantity AS ordered_qty,
    oi.unit_price,
    oi.subtotal AS item_subtotal,
    o.total_amount AS order_total
FROM orders o
JOIN customer cust ON o.customer_id = cust.customer_id
JOIN party p ON cust.party_id = p.party_id
JOIN users u ON p.user_id = u.user_id
JOIN order_item oi ON o.order_id = oi.order_id
JOIN crop c ON oi.crop_id = c.crop_id
ORDER BY o.order_date DESC;

-- Q6.2: Order tracking history timeline (BR-D006)
SELECT 
    ot.tracking_id,
    o.order_id,
    ot.status,
    ot.status_updated_at,
    ot.remarks
FROM order_tracking ot
JOIN orders o ON ot.order_id = o.order_id
ORDER BY o.order_id, ot.status_updated_at ASC;
