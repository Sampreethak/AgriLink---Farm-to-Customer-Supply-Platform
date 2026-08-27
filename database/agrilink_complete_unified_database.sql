-- ============================================================
-- AGRILINK COMPLETE UNIFIED DATABASE MASTER SCRIPT
-- Includes 100% of Runtime Application Tables AND Full ER Diagram Entities
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- SECTION 1: RUNTIME APPLICATION TABLES (FastAPI & Supabase API)
-- ============================================================

CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE,
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

CREATE TABLE IF NOT EXISTS public.categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    icon_name VARCHAR(50),
    image_url TEXT,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.listings (
    id SERIAL PRIMARY KEY,
    farmer_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    farmer_name VARCHAR(150) NOT NULL,
    title VARCHAR(200) NOT NULL,
    crop_name VARCHAR(100) NOT NULL,
    category_id INT REFERENCES public.categories(id) ON DELETE SET NULL,
    description TEXT,
    price_per_unit NUMERIC(10, 2) NOT NULL,
    unit VARCHAR(20) NOT NULL DEFAULT 'kg',
    available_quantity NUMERIC(10, 2) NOT NULL DEFAULT 0,
    is_organic BOOLEAN DEFAULT FALSE,
    grade VARCHAR(10) DEFAULT 'A',
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

CREATE TABLE IF NOT EXISTS public.user_interactions (
    id SERIAL PRIMARY KEY,
    buyer_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    listing_id INT REFERENCES public.listings(id) ON DELETE CASCADE,
    interaction_type VARCHAR(30) NOT NULL CHECK (interaction_type IN ('VIEW', 'SEARCH_CLICK', 'ADD_TO_CART', 'PURCHASE', 'RATING')),
    interaction_weight NUMERIC(4, 2) NOT NULL DEFAULT 1.0,
    rating_value NUMERIC(3, 1),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

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

CREATE TABLE IF NOT EXISTS public.order_items (
    id SERIAL PRIMARY KEY,
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE,
    listing_id INT REFERENCES public.listings(id) ON DELETE SET NULL,
    crop_name VARCHAR(100) NOT NULL,
    quantity NUMERIC(10, 2) NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL,
    total_price NUMERIC(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.reviews (
    id SERIAL PRIMARY KEY,
    listing_id INT REFERENCES public.listings(id) ON DELETE CASCADE,
    buyer_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    buyer_name VARCHAR(150),
    rating NUMERIC(2, 1) CHECK (rating >= 1.0 AND rating <= 5.0),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Row Level Security & Policies
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read listings" ON public.listings FOR SELECT USING (true);
CREATE POLICY "Allow public read categories" ON public.categories FOR SELECT USING (true);
CREATE POLICY "Allow public read reviews" ON public.reviews FOR SELECT USING (true);

-- Seed Data for Runtime Tables
INSERT INTO public.categories (id, name, icon_name, description) VALUES
(1, 'Vegetables', 'eco', 'Fresh organic and farm-direct vegetables'),
(2, 'Fruits', 'apple', 'Fresh seasonal orchard fruits'),
(3, 'Grains & Pulses', 'grain', 'High quality wheat, rice, pulses and pulses'),
(4, 'Spices & Herbs', 'spa', 'Aromatic spices and fresh herbs'),
(5, 'Dairy & Honey', 'local_drink', 'Pure farm milk, ghee, and natural honey')
ON CONFLICT (id) DO NOTHING;

SELECT setval('public.categories_id_seq', (SELECT MAX(id) FROM public.categories));

INSERT INTO public.profiles (id, full_name, email, phone, user_role, location, latitude, longitude) VALUES
('11111111-1111-1111-1111-111111111111', 'Ramesh Kumar (Farmer)', 'ramesh.farmer@agrilink.com', '+919876543210', 'FARMER', 'Nashik, Maharashtra', 20.0059, 73.7898),
('22222222-2222-2222-2222-222222222222', 'Suresh Patel (Farmer)', 'suresh.farmer@agrilink.com', '+919876543211', 'FARMER', 'Anand, Gujarat', 22.5645, 72.9289),
('33333333-3333-3333-3333-333333333333', 'Anita Sharma (Organic Farm)', 'anita.farmer@agrilink.com', '+919876543212', 'FARMER', 'Shimla, Himachal Pradesh', 31.1048, 77.1734),
('44444444-4444-4444-4444-444444444444', 'Vikram Singh (Farmer)', 'vikram.farmer@agrilink.com', '+919876543213', 'FARMER', 'Ludhiana, Punjab', 30.9010, 75.8573),
('55555555-5555-5555-5555-555555555555', 'Priya Verma (Buyer)', 'priya.buyer@agrilink.com', '+919811122233', 'BUYER', 'Mumbai, Maharashtra', 19.0760, 72.8777),
('66666666-6666-6666-6666-666666666666', 'Amit Roy (Hotel Chain Buyer)', 'amit.buyer@agrilink.com', '+919811122234', 'BUYER', 'Pune, Maharashtra', 18.5204, 73.8567),
('77777777-7777-7777-7777-777777777777', 'Sneha Kapoor (Retail Buyer)', 'sneha.buyer@agrilink.com', '+919811122235', 'BUYER', 'Delhi NCR', 28.7041, 77.1025),
('88888888-8888-8888-8888-888888888888', 'Rajesh Joshi (Wholesaler)', 'rajesh.buyer@agrilink.com', '+919811122236', 'BUYER', 'Ahmedabad, Gujarat', 23.0225, 72.5714)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.listings (id, farmer_id, farmer_name, title, crop_name, category_id, description, price_per_unit, unit, available_quantity, is_organic, grade, location, latitude, longitude, image_url, rating_avg, rating_count, status) VALUES
(101, '11111111-1111-1111-1111-111111111111', 'Ramesh Kumar', 'Fresh Red Tomatoes (Nashik Special)', 'Tomato', 1, 'Farm fresh grade A red juicy tomatoes harvested yesterday directly from Nashik farm fields.', 28.00, 'kg', 1500, true, 'A+', 'Nashik, Maharashtra', 20.0059, 73.7898, 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500', 4.8, 42, 'ACTIVE'),
(102, '11111111-1111-1111-1111-111111111111', 'Ramesh Kumar', 'Organic Red Onions', 'Onion', 1, 'High quality dried red onions stored in ventilated sheds. Ideal for long shelf life.', 22.50, 'kg', 3000, true, 'A', 'Nashik, Maharashtra', 20.0059, 73.7898, 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cf?w=500', 4.6, 28, 'ACTIVE'),
(103, '22222222-2222-2222-2222-222222222222', 'Suresh Patel', 'Premium Sharbati Wheat', 'Wheat', 3, 'Golden grain Sharbati wheat cleaned and bagged in 50kg sacks.', 42.00, 'kg', 5000, false, 'A+', 'Anand, Gujarat', 22.5645, 72.9289, 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=500', 4.9, 56, 'ACTIVE'),
(104, '22222222-2222-2222-2222-222222222222', 'Suresh Patel', 'Fresh Green Capsicum', 'Capsicum', 1, 'Crisp crunchy green bell peppers harvested at peak ripeness.', 45.00, 'kg', 800, false, 'A', 'Anand, Gujarat', 22.5645, 72.9289, 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=500', 4.4, 19, 'ACTIVE'),
(105, '33333333-3333-3333-3333-333333333333', 'Anita Sharma', 'Shimla Royal Delicious Apples', 'Apple', 2, 'Juicy sweet crisp apples grown at high altitudes without chemical pesticides.', 120.00, 'kg', 1200, true, 'A+', 'Shimla, Himachal Pradesh', 31.1048, 77.1734, 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500', 4.95, 65, 'ACTIVE'),
(106, '33333333-3333-3333-3333-333333333333', 'Anita Sharma', 'Organic Himachal Honey', 'Honey', 5, 'Pure raw unfiltered wild forest honey packed in glass jars.', 380.00, 'kg', 250, true, 'A+', 'Shimla, Himachal Pradesh', 31.1048, 77.1734, 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=500', 5.0, 31, 'ACTIVE'),
(107, '44444444-4444-4444-4444-444444444444', 'Vikram Singh', 'Organic Basmati Rice 1121', 'Rice', 3, 'Aromatic long grain extra white 1121 Basmati rice.', 95.00, 'kg', 4000, true, 'A+', 'Ludhiana, Punjab', 30.9010, 75.8573, 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500', 4.7, 38, 'ACTIVE'),
(108, '44444444-4444-4444-4444-444444444444', 'Vikram Singh', 'Fresh Yellow Sweet Corn', 'Corn', 1, 'Sweet juicy corn cobs directly harvested.', 18.00, 'kg', 2000, false, 'B', 'Ludhiana, Punjab', 30.9010, 75.8573, 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=500', 4.3, 14, 'ACTIVE')
ON CONFLICT (id) DO NOTHING;

SELECT setval('public.listings_id_seq', (SELECT MAX(id) FROM public.listings));

INSERT INTO public.user_interactions (buyer_id, listing_id, interaction_type, interaction_weight, rating_value) VALUES
('55555555-5555-5555-5555-555555555555', 101, 'PURCHASE', 5.0, 5.0),
('55555555-5555-5555-5555-555555555555', 102, 'ADD_TO_CART', 3.0, NULL),
('55555555-5555-5555-5555-555555555555', 105, 'PURCHASE', 5.0, 4.5),
('55555555-5555-5555-5555-555555555555', 106, 'VIEW', 1.0, NULL),
('66666666-6666-6666-6666-666666666666', 101, 'PURCHASE', 5.0, 5.0),
('66666666-6666-6666-6666-666666666666', 103, 'PURCHASE', 5.0, 4.8),
('66666666-6666-6666-6666-666666666666', 107, 'PURCHASE', 5.0, 4.7),
('77777777-7777-7777-7777-777777777777', 105, 'PURCHASE', 5.0, 5.0),
('77777777-7777-7777-7777-777777777777', 106, 'PURCHASE', 5.0, 5.0);
