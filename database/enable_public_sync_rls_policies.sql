-- ==============================================================================
-- AgriLink Supabase Live Dynamic Sync RLS Enablement
-- Disables restrictive table RLS so web/mobile app actions sync live into Supabase
-- ==============================================================================

ALTER TABLE IF EXISTS app_user DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS farmer_profile DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS inventory_item DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS seller_listing DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS customer_order DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS order_item DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS customer_review DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS payment DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS user_interaction DISABLE ROW LEVEL SECURITY;

-- Grant full SELECT, INSERT, UPDATE permissions to anon and authenticated roles
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
