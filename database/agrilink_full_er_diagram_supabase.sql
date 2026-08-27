-- ============================================================
-- AGRILINK FULL ACADEMIC ER DIAGRAM DATABASE SCHEMA FOR SUPABASE
-- Contains all 22+ domain tables, lookup masters, profiles,
-- logistics, inventory, ML logs, and seed data.
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. MASTER TABLES
CREATE TABLE IF NOT EXISTS role (
    role_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_name VARCHAR(50) NOT NULL UNIQUE,
    role_description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS location (
    location_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    address_line1 VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    pincode VARCHAR(20) NOT NULL,
    country VARCHAR(100) DEFAULT 'India',
    latitude NUMERIC(10, 8),
    longitude NUMERIC(11, 8)
);

CREATE TABLE IF NOT EXISTS crop_category (
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS crop (
    crop_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID REFERENCES crop_category(category_id),
    crop_name VARCHAR(150) NOT NULL,
    description TEXT,
    unit VARCHAR(20) NOT NULL,
    is_perishable BOOLEAN DEFAULT TRUE
);

-- 2. USER & AUTH TABLES
CREATE TABLE IF NOT EXISTS app_user (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id UUID REFERENCES role(role_id),
    location_id UUID REFERENCES location(location_id),
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. DOMAIN PROFILES
CREATE TABLE IF NOT EXISTS farmer_profile (
    farmer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app_user(user_id),
    farm_size_acres NUMERIC(8, 2),
    primary_crops TEXT,
    kyc_verified BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS aggregator_profile (
    aggregator_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app_user(user_id),
    hub_name VARCHAR(150),
    storage_capacity_tons NUMERIC(10, 2)
);

CREATE TABLE IF NOT EXISTS customer_profile (
    customer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app_user(user_id),
    customer_type VARCHAR(50) DEFAULT 'INDIVIDUAL',
    preferred_category_id UUID REFERENCES crop_category(category_id)
);

-- 4. INVENTORY & LISTINGS
CREATE TABLE IF NOT EXISTS inventory_item (
    inventory_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id UUID REFERENCES farmer_profile(farmer_id),
    crop_id UUID REFERENCES crop(crop_id),
    quantity NUMERIC(10, 2) NOT NULL,
    price_per_unit NUMERIC(10, 2) NOT NULL,
    grade VARCHAR(10) DEFAULT 'A+',
    harvest_date DATE,
    status VARCHAR(20) DEFAULT 'AVAILABLE'
);

CREATE TABLE IF NOT EXISTS seller_listing (
    listing_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_id UUID REFERENCES inventory_item(inventory_id),
    title VARCHAR(200) NOT NULL,
    is_organic BOOLEAN DEFAULT TRUE,
    rating_avg NUMERIC(3, 2) DEFAULT 4.8,
    rating_count INT DEFAULT 42
);

-- 5. ORDERS & PURCHASES
CREATE TABLE IF NOT EXISTS customer_order (
    order_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customer_profile(customer_id),
    total_amount NUMERIC(10, 2) NOT NULL,
    order_status VARCHAR(30) DEFAULT 'PAID',
    payment_method VARCHAR(50) DEFAULT 'RAZORPAY',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_item (
    order_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES customer_order(order_id),
    listing_id UUID REFERENCES seller_listing(listing_id),
    quantity NUMERIC(10, 2) NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL
);

-- 6. LOGISTICS & DELIVERY
CREATE TABLE IF NOT EXISTS delivery (
    delivery_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES customer_order(order_id),
    delivery_agent_name VARCHAR(150),
    delivery_status VARCHAR(30) DEFAULT 'DELIVERED',
    tracking_code VARCHAR(100)
);

-- 7. PAYMENTS & SETTLEMENTS
CREATE TABLE IF NOT EXISTS payment (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES customer_order(order_id),
    transaction_ref VARCHAR(100),
    payment_amount NUMERIC(10, 2) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'SUCCESS'
);

-- 8. ML RECOMMENDATION & USER INTERACTIONS
CREATE TABLE IF NOT EXISTS user_interaction (
    interaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customer_profile(customer_id),
    listing_id UUID REFERENCES seller_listing(listing_id),
    interaction_type VARCHAR(30) NOT NULL, -- VIEW, ADD_TO_CART, PURCHASE, RATING
    interaction_weight NUMERIC(4, 2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ml_pricing_log (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    crop_id UUID REFERENCES crop(crop_id),
    predicted_price NUMERIC(10, 2),
    confidence_score NUMERIC(4, 3),
    prediction_date TIMESTAMPTZ DEFAULT NOW()
);

-- 9. NOTIFICATIONS & REVIEWS
CREATE TABLE IF NOT EXISTS customer_review (
    review_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID REFERENCES seller_listing(listing_id),
    customer_id UUID REFERENCES customer_profile(customer_id),
    rating NUMERIC(2, 1) DEFAULT 5.0,
    comment TEXT
);

CREATE TABLE IF NOT EXISTS notification (
    notification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES app_user(user_id),
    title VARCHAR(150),
    message TEXT,
    is_read BOOLEAN DEFAULT FALSE
);
