-- ============================================================
-- 07_allocation_queries.sql
-- Multi-Source Order Allocation & Traceability Queries
-- ============================================================

-- Q7.1: Multi-table traceability query (7+ tables joined) (BR-D008 to BR-D018)
-- Customer -> Order -> OrderItem -> OrderAllocation -> FulfillmentSource -> Farmer/Warehouse
SELECT 
    o.order_id,
    u_cust.phone AS customer_phone,
    c.crop_name,
    oi.quantity AS total_order_qty_kg,
    oa.allocated_quantity_kg,
    oa.source_type,
    fs.source_name,
    f.farmer_code AS contributing_farmer,
    fa.farm_name,
    oa.unit_price,
    oa.subtotal AS allocated_amount
FROM orders o
JOIN customer cust ON o.customer_id = cust.customer_id
JOIN party p_cust ON cust.party_id = p_cust.party_id
JOIN users u_cust ON p_cust.user_id = u_cust.user_id
JOIN order_item oi ON o.order_id = oi.order_id
JOIN crop c ON oi.crop_id = c.crop_id
JOIN order_allocation oa ON oi.order_item_id = oa.order_item_id
JOIN fulfillment_source fs ON oa.fulfillment_source_id = fs.fulfillment_source_id
LEFT JOIN farmer f ON fs.farmer_id = f.farmer_id
LEFT JOIN farmer_crop fc ON fc.crop_id = c.crop_id
LEFT JOIN farm fa ON fc.farm_id = fa.farm_id
ORDER BY o.order_id, oa.allocation_sequence;
