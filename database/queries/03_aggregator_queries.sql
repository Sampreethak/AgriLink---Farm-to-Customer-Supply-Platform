-- ============================================================
-- 03_aggregator_queries.sql
-- Aggregators, Warehouse Storage, and Capacity Utilization
-- ============================================================

-- Q3.1: Aggregator warehouse capacity and current inventory storage (BR-C001 to BR-C004)
SELECT 
    a.aggregator_id,
    a.company_name,
    w.warehouse_name,
    loc.city,
    loc.district,
    w.capacity_kg AS total_capacity_kg,
    w.is_cold_storage,
    COALESCE(SUM(ai.quantity_kg), 0) AS total_stored_kg,
    ROUND((COALESCE(SUM(ai.quantity_kg), 0) / w.capacity_kg) * 100, 2) AS utilization_pct
FROM aggregator a
JOIN warehouse w ON a.aggregator_id = w.aggregator_id
JOIN location loc ON w.location_id = loc.location_id
LEFT JOIN aggregator_inventory ai ON w.warehouse_id = ai.warehouse_id
GROUP BY a.aggregator_id, a.company_name, w.warehouse_id, w.warehouse_name, loc.city, loc.district, w.capacity_kg, w.is_cold_storage;

-- Q3.2: Procurement records between Aggregators and Farmers (BR-C006 to BR-C008)
SELECT 
    pr.procurement_id,
    a.company_name AS aggregator_name,
    f.farmer_code,
    c.crop_name,
    pr.quantity_kg,
    pr.unit_price,
    pr.total_price,
    pr.quality_status,
    pr.payment_status,
    pr.procurement_date
FROM procurement pr
JOIN aggregator a ON pr.aggregator_id = a.aggregator_id
JOIN farmer f ON pr.farmer_id = f.farmer_id
JOIN farmer_crop fc ON pr.farmer_crop_id = fc.farmer_crop_id
JOIN crop c ON fc.crop_id = c.crop_id
ORDER BY pr.procurement_date DESC;
