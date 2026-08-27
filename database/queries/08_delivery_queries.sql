-- ============================================================
-- 08_delivery_queries.sql
-- Delivery Partners, Vehicle Assignments, and Route Tracking
-- ============================================================

-- Q8.1: Delivery details with assigned partner, vehicle, route, and OTP proof status (BR-E001 to BR-E015)
SELECT 
    d.delivery_id,
    o.order_id,
    dp.license_number,
    u.phone AS delivery_partner_phone,
    v.vehicle_type,
    v.registration_number,
    d.delivery_type,
    d.delivery_status,
    d.scheduled_delivery_date,
    d.actual_delivery_date,
    dpf.proof_type,
    dpf.verified_at
FROM delivery d
JOIN orders o ON d.order_id = o.order_id
LEFT JOIN delivery_assignment da ON d.delivery_id = da.delivery_id
LEFT JOIN delivery_partner dp ON da.delivery_partner_id = dp.delivery_partner_id
LEFT JOIN party p ON dp.party_id = p.party_id
LEFT JOIN users u ON p.user_id = u.user_id
LEFT JOIN vehicle v ON da.vehicle_id = v.vehicle_id
LEFT JOIN delivery_proof dpf ON d.delivery_id = dpf.delivery_id;
