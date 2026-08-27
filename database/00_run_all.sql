-- ============================================================
-- 00_run_all.sql
-- AgriLink Database Master Migration Runner
-- Runs all 22 migration scripts in sequence against PostgreSQL
-- Usage: psql -U postgres -d agrilink_db -f 00_run_all.sql
-- ============================================================

\echo '============================================================'
\echo ' AgriLink Master Database Deployment'
\echo '============================================================'

\echo '>> [01/22] Extensions...'
\i 01_extensions.sql

\echo '>> [02/22] Enums & Domain Types...'
\i 02_enums.sql

\echo '>> [03/22] Master Lookup Tables...'
\i 03_master_tables.sql

\echo '>> [04/22] User & Auth Tables...'
\i 04_user_tables.sql

\echo '>> [05/22] Farmer & Farm Tables...'
\i 05_farmer_tables.sql

\echo '>> [06/22] Aggregator & Warehouse Tables...'
\i 06_aggregator_tables.sql

\echo '>> [07/22] Customer & Address Tables...'
\i 07_customer_tables.sql

\echo '>> [08/22] Inventory & Procurement Tables...'
\i 08_inventory_tables.sql

\echo '>> [09/22] Order & Allocation Tables...'
\i 09_order_tables.sql

\echo '>> [10/22] Delivery & Logistics Tables...'
\i 10_delivery_tables.sql

\echo '>> [11/22] Payment & Settlement Tables...'
\i 11_payment_tables.sql

\echo '>> [12/22] Customer Engagement Tables...'
\i 12_engagement_tables.sql

\echo '>> [13/22] Pricing & ML Prediction Tables...'
\i 13_pricing_ml_tables.sql

\echo '>> [14/22] Returns & Refunds Tables...'
\i 14_return_tables.sql

\echo '>> [15/22] Notification & Messaging Tables...'
\i 15_notification_tables.sql

\echo '>> [16/22] Constraints & Domain Checks...'
\i 16_constraints.sql

\echo '>> [17/22] Database Indexes...'
\i 17_indexes.sql

\echo '>> [18/22] Business Views...'
\i 18_views.sql

\echo '>> [19/22] Automated Triggers...'
\i 19_triggers.sql

\echo '>> [20/22] Stored Functions & Procedures...'
\i 20_functions.sql

\echo '>> [21/22] Seed Dataset...'
\i 21_seed_data.sql

\echo '>> [22/22] Test Queries & Verification...'
\i 22_test_queries.sql

\echo '============================================================'
\echo ' ✅ AgriLink Database Deployment Completed Successfully!'
\echo '============================================================'
