-- ============================================================
-- 22_test_queries.sql
-- Validation and analytical queries to verify schema integrity
-- ============================================================

\echo '--- 1. Table Count Verification ---'
SELECT count(*) AS total_tables
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE';

\echo '--- 2. User & Role Summary ---'
SELECT u.user_id, u.phone, u.email, r.role_name, p.party_type, p.kyc_status
FROM users u
JOIN role r ON u.role_id = r.role_id
JOIN party p ON u.user_id = p.user_id;

\echo '--- 3. Farmer Dashboard View Output ---'
SELECT * FROM farmer_dashboard_view;

\echo '--- 4. Warehouse Inventory View Output ---'
SELECT * FROM warehouse_inventory_view;

\echo '--- 5. Order Summary View Output ---'
SELECT * FROM order_summary_view;
