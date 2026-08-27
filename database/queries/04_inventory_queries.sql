-- ============================================================
-- 04_inventory_queries.sql
-- Aggregator Inventory Batches, Quality Control, and Stock Movement
-- ============================================================

-- Q4.1: Current available and reserved inventory batches per warehouse with quality grades (BR-H001 to BR-H011)
SELECT 
    ai.inventory_batch_id,
    ai.batch_no,
    w.warehouse_name,
    c.crop_name,
    f.farmer_code AS original_farmer,
    ai.quantity_kg,
    ai.available_quantity_kg,
    ai.reserved_quantity_kg,
    ai.unit_cost_price,
    qc.quality_grade,
    qc.qc_status,
    ai.expiry_date
FROM aggregator_inventory ai
JOIN warehouse w ON ai.warehouse_id = w.warehouse_id
JOIN farmer_crop fc ON ai.farmer_crop_id = fc.farmer_crop_id
JOIN crop c ON fc.crop_id = c.crop_id
LEFT JOIN farmer f ON ai.farmer_id = f.farmer_id
LEFT JOIN quality_check qc ON ai.inventory_batch_id = qc.inventory_batch_id
ORDER BY ai.expiry_date ASC;

-- Q4.2: Audit trail of inventory movements (IN, OUT, RESERVED) (BR-H014)
SELECT 
    im.movement_id,
    ai.batch_no,
    c.crop_name,
    im.movement_type,
    im.quantity_kg,
    im.reference_type,
    im.notes,
    im.movement_date
FROM inventory_movement im
JOIN aggregator_inventory ai ON im.inventory_batch_id = ai.inventory_batch_id
JOIN farmer_crop fc ON ai.farmer_crop_id = fc.farmer_crop_id
JOIN crop c ON fc.crop_id = c.crop_id
ORDER BY im.movement_date DESC;
