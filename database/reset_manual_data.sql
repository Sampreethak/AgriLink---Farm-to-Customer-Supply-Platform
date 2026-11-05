-- ============================================================
-- AgriLink: RESET ALL MANUALLY ENTERED DATA
-- Run this in Supabase SQL Editor (Dashboard > SQL Editor)
-- This DELETES all manually inserted rows but KEEPS the schema,
-- RLS policies, functions, triggers, and seed categories intact.
-- ============================================================

-- Disable triggers temporarily to avoid FK cascade conflicts
SET session_replication_role = replica;

-- 1. Application data tables (child → parent order)
TRUNCATE TABLE public.reviews           RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.user_interactions RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.order_items       RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.orders            RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.listings          RESTART IDENTITY CASCADE;

-- 2. Profile table (user metadata linked to auth.users)
TRUNCATE TABLE public.profiles          RESTART IDENTITY CASCADE;

-- 3. Keep categories (they are seed/config data, not manually entered)
-- If you also want to clear categories, uncomment:
-- TRUNCATE TABLE public.categories RESTART IDENTITY CASCADE;

-- Re-enable triggers
SET session_replication_role = DEFAULT;

-- ============================================================
-- IMPORTANT: Also delete users from Supabase Auth
-- You CANNOT do this from SQL Editor directly.
-- Go to: Dashboard → Authentication → Users → select all → Delete
-- OR use the service_role key via the Admin API (see notes below)
-- ============================================================

-- Verify everything is empty
SELECT 'profiles'         AS tbl, COUNT(*) FROM public.profiles
UNION ALL
SELECT 'listings'         AS tbl, COUNT(*) FROM public.listings
UNION ALL
SELECT 'orders'           AS tbl, COUNT(*) FROM public.orders
UNION ALL
SELECT 'order_items'      AS tbl, COUNT(*) FROM public.order_items
UNION ALL
SELECT 'user_interactions'AS tbl, COUNT(*) FROM public.user_interactions
UNION ALL
SELECT 'reviews'          AS tbl, COUNT(*) FROM public.reviews;
