-- ============================================================
-- 02_farmer_queries.sql
-- Farmer Profiles, Farms, Crops, and Harvest Batch Queries
-- ============================================================

-- Q2.1: Overview of verified farmers, their farm locations, and active crop listings (BR-B001 to BR-B006)
SELECT 
    f.farmer_id,
    f.farmer_code,
    u.phone AS farmer_phone,
    fa.farm_name,
    fa.area_acres,
    loc.district,
    loc.state,
    c.crop_name,
    fc.harvest_quantity_kg,
    fc.available_quantity_kg,
    fc.unit_price,
    fc.is_organic
FROM farmer f
JOIN party p ON f.party_id = p.party_id
JOIN users u ON p.user_id = u.user_id
JOIN farm fa ON f.farmer_id = fa.farmer_id
JOIN location loc ON fa.location_id = loc.location_id
JOIN farmer_crop fc ON fa.farm_id = fc.farm_id
JOIN crop c ON fc.crop_id = c.crop_id
WHERE f.is_verified = true AND fa.is_active = true
ORDER BY fc.harvest_date DESC;

-- Q2.2: Organic certified crop batches available for direct sale (BR-B012, BR-B019)
SELECT 
    fc.farmer_crop_id,
    c.crop_name,
    fc.harvest_quantity_kg,
    fc.available_quantity_kg,
    fc.unit_price,
    fa.farm_name,
    f.farmer_code
FROM farmer_crop fc
JOIN crop c ON fc.crop_id = c.crop_id
JOIN farm fa ON fc.farm_id = fa.farm_id
JOIN farmer f ON fa.farmer_id = f.farmer_id
WHERE fc.is_organic = true AND fc.available_quantity_kg > 0;
