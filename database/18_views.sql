-- ============================================================
-- 18_views.sql
-- Business analytics & reporting views
-- Views: farmer_dashboard_view, warehouse_inventory_view, order_summary_view
-- ============================================================

CREATE OR REPLACE VIEW farmer_dashboard_view AS
SELECT
    f.farmer_id,
    f.farmer_code,
    u.phone AS farmer_phone,
    u.email AS farmer_email,
    COUNT(DISTINCT fm.farm_id) AS total_farms,
    COALESCE(SUM(fm.total_area), 0) AS total_area_acres,
    COUNT(DISTINCT fc.farmer_crop_id) AS total_crop_batches,
    COALESCE(SUM(p.total_price), 0) AS total_earnings
FROM farmer f
JOIN party pt ON f.party_id = pt.party_id
JOIN users u ON pt.user_id = u.user_id
LEFT JOIN farm fm ON f.farmer_id = fm.farmer_id
LEFT JOIN farmer_crop fc ON fm.farm_id = fc.farm_id
LEFT JOIN procurement p ON f.farmer_id = p.farmer_id AND p.payment_status = 'Paid'
GROUP BY f.farmer_id, f.farmer_code, u.phone, u.email;

CREATE OR REPLACE VIEW warehouse_inventory_view AS
SELECT
    w.warehouse_id,
    w.warehouse_name,
    a.business_name AS aggregator_name,
    w.total_capacity_kg,
    w.occupied_capacity_kg,
    ROUND((w.occupied_capacity_kg / NULLIF(w.total_capacity_kg, 0)) * 100, 2) AS capacity_utilization_pct,
    COUNT(DISTINCT inv.inventory_batch_id) AS total_batches,
    COALESCE(SUM(inv.available_quantity_kg), 0) AS total_available_kg
FROM warehouse w
JOIN aggregator a ON w.aggregator_id = a.aggregator_id
LEFT JOIN aggregator_inventory inv ON w.warehouse_id = inv.warehouse_id
GROUP BY w.warehouse_id, w.warehouse_name, a.business_name, w.total_capacity_kg, w.occupied_capacity_kg;

CREATE OR REPLACE VIEW order_summary_view AS
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    o.payment_status,
    o.total_amount,
    c.customer_id,
    u.phone AS customer_phone,
    COUNT(oi.order_item_id) AS total_items,
    d.delivery_status
FROM orders o
JOIN customer c ON o.customer_id = c.customer_id
JOIN party pt ON c.party_id = pt.party_id
JOIN users u ON pt.user_id = u.user_id
LEFT JOIN order_item oi ON o.order_id = oi.order_id
LEFT JOIN delivery d ON o.order_id = d.order_id
GROUP BY o.order_id, o.order_date, o.order_status, o.payment_status, o.total_amount, c.customer_id, u.phone, d.delivery_status;
