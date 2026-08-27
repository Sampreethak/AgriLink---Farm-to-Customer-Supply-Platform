-- ============================================================
-- 10_analytics_queries.sql
-- Executive Dashboard, Revenue Analytics, and Supply Chain Insights
-- ============================================================

-- Q10.1: Top selling crops by volume (kg) and total revenue
SELECT 
    c.crop_name,
    cc.category_name,
    SUM(oi.quantity) AS total_kg_sold,
    SUM(oi.subtotal) AS gross_revenue
FROM order_item oi
JOIN crop c ON oi.crop_id = c.crop_id
JOIN crop_category cc ON c.category_id = cc.category_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status != 'Cancelled'
GROUP BY c.crop_name, cc.category_name
ORDER BY gross_revenue DESC;

-- Q10.2: Farmer payout summary by district
SELECT 
    loc.district,
    COUNT(DISTINCT f.farmer_id) AS active_farmers,
    SUM(sd.amount) AS total_farmer_payouts
FROM settlement_detail sd
JOIN farmer f ON sd.entity_id = f.farmer_id
JOIN farm fa ON f.farmer_id = fa.farmer_id
JOIN location loc ON fa.location_id = loc.location_id
WHERE sd.entity_type = 'Farmer'
GROUP BY loc.district
ORDER BY total_farmer_payouts DESC;
