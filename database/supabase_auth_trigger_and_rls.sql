-- ============================================================
-- AgriLink: Supabase Auth Auto-Profile Trigger & Role Setup
-- Run ONCE in Supabase SQL Editor (Dashboard > SQL Editor)
-- Enables:
-- 1. All roles (FARMER, CUSTOMER, BUYER, AGGREGATOR, DELIVERY, ADMIN)
-- 2. Automatic profiles row creation on signup
-- 3. Database-backed password retrieval and autofill
-- 4. Clean RLS policies for seamless mobile app connectivity
-- ============================================================

-- 1. Ensure required columns exist in public.profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS user_id UUID UNIQUE;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS demo_password TEXT;

-- 2. Update role constraint on public.profiles to accept ALL AgriLink roles
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_user_role_check;
ALTER TABLE public.profiles ADD CONSTRAINT profiles_user_role_check 
  CHECK (user_role IN ('FARMER', 'BUYER', 'CUSTOMER', 'AGGREGATOR', 'DELIVERY', 'DELIVERY_PARTNER', 'ADMIN'));

-- 3. Function: called by trigger whenever a new user registers in Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  parsed_role VARCHAR;
BEGIN
  -- Normalize incoming role
  parsed_role := UPPER(REPLACE(COALESCE(NEW.raw_user_meta_data->>'role', 'CUSTOMER'), ' ', '_'));
  IF parsed_role NOT IN ('FARMER', 'BUYER', 'CUSTOMER', 'AGGREGATOR', 'DELIVERY', 'DELIVERY_PARTNER', 'ADMIN') THEN
    parsed_role := 'CUSTOMER';
  END IF;

  INSERT INTO public.profiles (
    id,
    user_id,
    full_name,
    email,
    phone,
    user_role,
    location,
    demo_password,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'AgriLink User'),
    COALESCE(NEW.email, ''),
    COALESCE(NEW.raw_user_meta_data->>'phone', ''),
    parsed_role,
    COALESCE(NEW.raw_user_meta_data->>'region', 'Bengaluru / Mandya Corridor'),
    COALESCE(NEW.raw_user_meta_data->>'demo_password', NULL),
    NOW(),
    NOW()
  )
  ON CONFLICT (user_id) DO UPDATE
    SET
      full_name     = EXCLUDED.full_name,
      email         = EXCLUDED.email,
      phone         = EXCLUDED.phone,
      user_role     = EXCLUDED.user_role,
      location      = EXCLUDED.location,
      demo_password = COALESCE(EXCLUDED.demo_password, public.profiles.demo_password),
      updated_at    = NOW();

  RETURN NEW;
END;
$$;

-- 4. Recreate auth trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_auth_user();

-- ============================================================
-- 5. RPC Functions for Database Password Retrieval & Autofill
-- ============================================================

-- Function 1: Lookup password for a specific email (used when user types an email)
CREATE OR REPLACE FUNCTION public.get_account_autofill(lookup_email TEXT)
RETURNS TABLE (
  email VARCHAR,
  full_name VARCHAR,
  user_role VARCHAR,
  demo_password TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT p.email, p.full_name, p.user_role, p.demo_password
  FROM public.profiles p
  WHERE LOWER(TRIM(p.email)) = LOWER(TRIM(lookup_email))
    AND p.demo_password IS NOT NULL
  LIMIT 1;
END;
$$;

-- Function 2: List all registered accounts with autofill passwords (used by account picker)
CREATE OR REPLACE FUNCTION public.get_registered_accounts()
RETURNS TABLE (
  email VARCHAR,
  full_name VARCHAR,
  user_role VARCHAR,
  demo_password TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT p.email, p.full_name, p.user_role, p.demo_password
  FROM public.profiles p
  WHERE p.demo_password IS NOT NULL
  ORDER BY p.created_at DESC;
END;
$$;

-- Grant RPC execution permissions to anonymous & authenticated mobile clients
GRANT EXECUTE ON FUNCTION public.get_account_autofill(TEXT) TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.get_registered_accounts() TO anon, authenticated, service_role;

-- ============================================================
-- 6. RLS Policies
-- ============================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Allow reading profiles so login autofill and profile views work seamlessly
DROP POLICY IF EXISTS "Allow public read for profiles autofill" ON public.profiles;
CREATE POLICY "Allow public read for profiles autofill"
  ON public.profiles FOR SELECT
  USING (true);

-- Allow authenticated users to update their own profile
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = user_id);

-- Allow profile inserts
DROP POLICY IF EXISTS "Allow insert profiles" ON public.profiles;
CREATE POLICY "Allow insert profiles"
  ON public.profiles FOR INSERT
  WITH CHECK (true);

-- Allow reading listings, categories, reviews publicly
DROP POLICY IF EXISTS "Allow public read listings" ON public.listings;
CREATE POLICY "Allow public read listings" ON public.listings FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow public read categories" ON public.categories;
CREATE POLICY "Allow public read categories" ON public.categories FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public read reviews" ON public.reviews;
CREATE POLICY "Public read reviews" ON public.reviews FOR SELECT USING (true);

-- Seed pre-configured credentials for all 5 roles into public.profiles for instant demo testing
INSERT INTO public.profiles (id, user_id, full_name, email, phone, user_role, location, demo_password)
VALUES
  ('11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Ramesh Kumar', 'ramesh.farmer@agrilink.com', '+91 98765 43210', 'FARMER', 'Mandya Corridor', 'AgriLink@123'),
  ('99999999-9999-9999-9999-999999999999', '99999999-9999-9999-9999-999999999999', 'Priya Verma', 'priya.buyer@agrilink.com', '+91 98111 22233', 'CUSTOMER', 'Bengaluru Urban', 'AgriLink@123'),
  ('aaaa1111-bbbb-2222-cccc-333333333333', 'aaaa1111-bbbb-2222-cccc-333333333333', 'Kolar Hub Manager', 'aggregator.kolar@agrilink.com', '+91 98000 00096', 'AGGREGATOR', 'Kolar Market Yard', 'AgriLink@123'),
  ('dddd1111-eeee-2222-ffff-333333333333', 'dddd1111-eeee-2222-ffff-333333333333', 'Raju Express Rider', 'delivery.partner@agrilink.com', '+91 98777 66655', 'DELIVERY', 'Mandya-Bengaluru Express', 'AgriLink@123'),
  ('00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'System Administrator', 'admin@agrilink.com', '+91 80000 12345', 'ADMIN', 'AgriLink HQ (Bengaluru)', 'AgriLink@123')
ON CONFLICT (user_id) DO UPDATE
SET
  demo_password = EXCLUDED.demo_password,
  user_role     = EXCLUDED.user_role,
  full_name     = EXCLUDED.full_name;
