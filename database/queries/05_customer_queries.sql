-- ============================================================
-- 05_customer_queries.sql
-- Customer Profiles, Delivery Addresses, Carts, and Reviews
-- ============================================================

-- Q5.1: Customer details with address count and active cart summary (BR-G001 to BR-G005)
SELECT 
    cust.customer_id,
    u.phone AS customer_phone,
    u.email AS customer_email,
    cust.loyalty_points,
    ca.address_line1,
    ca.city,
    ca.pincode,
    COUNT(DISTINCT ci.cart_item_id) AS items_in_cart,
    COALESCE(SUM(ci.quantity * ci.unit_price), 0) AS cart_total_amount
FROM customer cust
JOIN party p ON cust.party_id = p.party_id
JOIN users u ON p.user_id = u.user_id
LEFT JOIN customer_address ca ON cust.customer_id = ca.customer_id AND ca.is_default = true
LEFT JOIN cart crt ON cust.customer_id = crt.customer_id
LEFT JOIN cart_item ci ON crt.cart_id = ci.cart_id
GROUP BY cust.customer_id, u.phone, u.email, cust.loyalty_points, ca.address_line1, ca.city, ca.pincode;

-- Q5.2: Crop reviews submitted by customers with rating and feedback (BR-G009 to BR-G012)
SELECT 
    r.review_id,
    c.crop_name,
    u.phone AS customer_phone,
    r.rating,
    r.review_text,
    r.review_date
FROM review r
JOIN crop c ON r.crop_id = c.crop_id
JOIN customer cust ON r.customer_id = cust.customer_id
JOIN party p ON cust.party_id = p.party_id
JOIN users u ON p.user_id = u.user_id
ORDER BY r.review_date DESC;
