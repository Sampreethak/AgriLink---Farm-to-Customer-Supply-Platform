-- ==========================================================
-- AGRILINK SUPABASE DATABASE SCHEMA
-- Target Database: Supabase PostgreSQL
-- Auth Integration: Works with Supabase auth.users & public.profiles
-- ==========================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. PROFILES TABLE (Linked with Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE, -- References auth.users(id) in Supabase
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    user_role VARCHAR(30) NOT NULL CHECK (user_role IN ('FARMER', 'BUYER', 'AGGREGATOR', 'ADMIN')),
    location VARCHAR(150),
    latitude NUMERIC(10, 8),
    longitude NUMERIC(11, 8),
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. CATEGORIES TABLE
CREATE TABLE IF NOT EXISTS public.categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    icon_name VARCHAR(50),
    image_url TEXT,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. CROP LISTINGS TABLE
CREATE TABLE IF NOT EXISTS public.listings (
    id SERIAL PRIMARY KEY,
    farmer_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    farmer_name VARCHAR(150) NOT NULL,
    title VARCHAR(200) NOT NULL,
    crop_name VARCHAR(100) NOT NULL,
    category_id INT REFERENCES public.categories(id) ON DELETE SET NULL,
    description TEXT,
    price_per_unit NUMERIC(10, 2) NOT NULL,
    unit VARCHAR(20) NOT NULL DEFAULT 'kg', -- 'kg', 'quintal', 'ton', 'box'
    available_quantity NUMERIC(10, 2) NOT NULL DEFAULT 0,
    is_organic BOOLEAN DEFAULT FALSE,
    grade VARCHAR(10) DEFAULT 'A', -- 'A+', 'A', 'B'
    location VARCHAR(150),
    latitude NUMERIC(10, 8),
    longitude NUMERIC(11, 8),
    image_url TEXT,
    rating_avg NUMERIC(3, 2) DEFAULT 4.5,
    rating_count INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'SOLD_OUT', 'INACTIVE')),
    harvest_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. USER INTERACTIONS TABLE (Crucial for LightFM ML Recommendation Engine)
CREATE TABLE IF NOT EXISTS public.user_interactions (
    id SERIAL PRIMARY KEY,
    buyer_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    listing_id INT REFERENCES public.listings(id) ON DELETE CASCADE,
    interaction_type VARCHAR(30) NOT NULL CHECK (interaction_type IN ('VIEW', 'SEARCH_CLICK', 'ADD_TO_CART', 'PURCHASE', 'RATING')),
    interaction_weight NUMERIC(4, 2) NOT NULL DEFAULT 1.0, -- VIEW=1, CLICK=2, CART=3, PURCHASE=5
    rating_value NUMERIC(3, 1), -- 1.0 to 5.0 if RATING
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. ORDERS TABLE
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    buyer_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    total_amount NUMERIC(10, 2) NOT NULL,
    status VARCHAR(30) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PAID', 'SHIPPED', 'DELIVERED', 'CANCELLED')),
    payment_method VARCHAR(50) DEFAULT 'RAZORPAY',
    payment_id VARCHAR(100),
    delivery_address TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. ORDER ITEMS TABLE
CREATE TABLE IF NOT EXISTS public.order_items (
    id SERIAL PRIMARY KEY,
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE,
    listing_id INT REFERENCES public.listings(id) ON DELETE SET NULL,
    crop_name VARCHAR(100) NOT NULL,
    quantity NUMERIC(10, 2) NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL,
    total_price NUMERIC(10, 2) NOT NULL
);

-- 7. REVIEWS TABLE
CREATE TABLE IF NOT EXISTS public.reviews (
    id SERIAL PRIMARY KEY,
    listing_id INT REFERENCES public.listings(id) ON DELETE CASCADE,
    buyer_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    buyer_name VARCHAR(150),
    rating NUMERIC(2, 1) CHECK (rating >= 1.0 AND rating <= 5.0),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for spatial, search, & ML queries
CREATE INDEX IF NOT EXISTS idx_listings_category ON public.listings(category_id);
CREATE INDEX IF NOT EXISTS idx_listings_status ON public.listings(status);
CREATE INDEX IF NOT EXISTS idx_interactions_buyer ON public.user_interactions(buyer_id);
CREATE INDEX IF NOT EXISTS idx_interactions_listing ON public.user_interactions(listing_id);

-- Enable Row Level Security (RLS) for Supabase
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Public read policies for Supabase API
CREATE POLICY "Allow public read listings" ON public.listings FOR SELECT USING (true);
CREATE POLICY "Allow public read categories" ON public.categories FOR SELECT USING (true);
CREATE POLICY "Allow public read reviews" ON public.reviews FOR SELECT USING (true);

-- Authenticated write policies
CREATE POLICY "Allow authenticated insert listings" ON public.listings FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow authenticated update listings" ON public.listings FOR UPDATE USING (true);
CREATE POLICY "Allow authenticated insert orders" ON public.orders FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow authenticated insert interactions" ON public.user_interactions FOR INSERT WITH CHECK (true);
