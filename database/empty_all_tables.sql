-- ============================================================
-- AgriLink: EMPTY ALL DATABASE TABLES (RESET FOR LIVE APP INPUTS)
-- Run this in Supabase SQL Editor:
-- Dashboard -> SQL Editor -> New Query -> Paste & Run (Ctrl + Enter)
-- ============================================================

-- Disable foreign key triggers temporarily during cleanup
SET session_replication_role = replica;

-- 1. Clear Transactional & Activity Tables (Child tables)
TRUNCATE TABLE public.customer_review     RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.user_interaction    RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.payment             RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.delivery            RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.order_item          RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.customer_order      RESTART IDENTITY CASCADE;

-- 2. Clear Listings & Inventory Tables
TRUNCATE TABLE public.seller_listing      RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.inventory_item      RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.ml_pricing_log      RESTART IDENTITY CASCADE;

-- 3. Clear User Profiles & Stakeholders
TRUNCATE TABLE public.customer_profile    RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.farmer_profile      RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.aggregator_profile  RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.app_user            RESTART IDENTITY CASCADE;

-- 4. Clear Runtime Tables (if created by unified schema)
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'reviews') THEN
        TRUNCATE TABLE public.reviews RESTART IDENTITY CASCADE;
    END IF;
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'orders') THEN
        TRUNCATE TABLE public.orders RESTART IDENTITY CASCADE;
    END IF;
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'listings') THEN
        TRUNCATE TABLE public.listings RESTART IDENTITY CASCADE;
    END IF;
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'profiles') THEN
        TRUNCATE TABLE public.profiles RESTART IDENTITY CASCADE;
    END IF;
END $$;

-- Re-enable foreign key constraints & triggers
SET session_replication_role = DEFAULT;

-- ============================================================
-- VERIFICATION: Count rows in all tables
-- ============================================================
SELECT 'app_user' AS table_name, count(*) AS row_count FROM public.app_user
UNION ALL
SELECT 'farmer_profile', count(*) FROM public.farmer_profile
UNION ALL
SELECT 'customer_profile', count(*) FROM public.customer_profile
UNION ALL
SELECT 'inventory_item', count(*) FROM public.inventory_item
UNION ALL
SELECT 'seller_listing', count(*) FROM public.seller_listing
UNION ALL
SELECT 'customer_order', count(*) FROM public.customer_order
UNION ALL
SELECT 'order_item', count(*) FROM public.order_item;
