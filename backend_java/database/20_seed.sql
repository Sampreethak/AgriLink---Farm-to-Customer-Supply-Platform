-- ============================================================
-- 20_seed.sql
-- Complete realistic seed data for AgriLink database
-- Populates all 47 tables with Karnataka-based demo data
-- Run AFTER all 01_*.sql through 19_*.sql scripts
-- ============================================================

-- ============================================================
-- A. ROLES
-- ============================================================
INSERT INTO role (role_id, role_name, role_description) VALUES
    ('11111111-0000-0000-0000-000000000001', 'Admin',            'Platform administrator with full access'),
    ('11111111-0000-0000-0000-000000000002', 'Customer',         'End consumer who buys fresh produce'),
    ('11111111-0000-0000-0000-000000000003', 'Farmer',           'Agricultural producer and crop supplier'),
    ('11111111-0000-0000-0000-000000000004', 'Aggregator',       'Procurement agent and warehouse operator'),
    ('11111111-0000-0000-0000-000000000005', 'Delivery Partner', 'Last-mile delivery agent')
ON CONFLICT (role_name) DO NOTHING;

-- ============================================================
-- B. LOCATIONS
-- ============================================================
INSERT INTO location (location_id, address_line1, city, state, pincode, latitude, longitude) VALUES
    ('22222222-0001-0000-0000-000000000001', 'MG Road, Bengaluru',              'Bengaluru',   'Karnataka', '560001',  12.9716, 77.5946),
    ('22222222-0002-0000-0000-000000000002', 'Devanahalli Town',                'Bengaluru',   'Karnataka', '562110',  13.2480, 77.7134),
    ('22222222-0003-0000-0000-000000000003', 'Chikkaballapur Main Road',        'Chikkaballapur','Karnataka','562101', 13.4353, 77.7273),
    ('22222222-0004-0000-0000-000000000004', 'APMC Cold Storage Zone, Yelahanka','Bengaluru',  'Karnataka', '560064',  13.1005, 77.5963),
    ('22222222-0005-0000-0000-000000000005', 'JP Nagar 7th Phase',              'Bengaluru',   'Karnataka', '560078',  12.9038, 77.5932),
    ('22222222-0006-0000-0000-000000000006', 'Hassan Road, Tumkur',             'Tumkur',      'Karnataka', '572101',  13.3400, 77.1010),
    ('22222222-0007-0000-0000-000000000007', 'Indiranagar 100 Feet Road',       'Bengaluru',   'Karnataka', '560038',  12.9784, 77.6408),
    ('22222222-0008-0000-0000-000000000008', 'Koramangala 4th Block',           'Bengaluru',   'Karnataka', '560034',  12.9352, 77.6245),
    ('22222222-0009-0000-0000-000000000009', 'Kolar Gold Fields Road',          'Kolar',       'Karnataka', '563101',  13.1358, 78.1290),
    ('22222222-0010-0000-0000-000000000010', 'Mysuru Road, Ramanagara',         'Ramanagara',  'Karnataka', '562159',  12.7181, 77.2802)
ON CONFLICT DO NOTHING;

-- ============================================================
-- C. CROP CATEGORIES
-- ============================================================
INSERT INTO crop_category (category_id, category_name, description) VALUES
    ('33333333-0001-0000-0000-000000000001', 'Vegetables',   'Fresh seasonal vegetables from local farms'),
    ('33333333-0002-0000-0000-000000000002', 'Fruits',       'Seasonal and year-round fresh fruits'),
    ('33333333-0003-0000-0000-000000000003', 'Grains',       'Cereals, pulses, and millets'),
    ('33333333-0004-0000-0000-000000000004', 'Leafy Greens', 'Spinach, methi, curry leaves and more'),
    ('33333333-0005-0000-0000-000000000005', 'Dairy & Eggs', 'Farm-fresh milk, eggs and dairy products')
ON CONFLICT (category_name) DO NOTHING;

-- ============================================================
-- D. CROPS (Master Product Catalog)
-- ============================================================
INSERT INTO crop (crop_id, category_id, crop_name, description, unit, is_perishable, is_active) VALUES
    ('44444444-0001-0000-0000-000000000001', '33333333-0001-0000-0000-000000000001', 'Organic Tomato',    'Vine-ripened red tomatoes, chemical-free',             'kg',     TRUE,  TRUE),
    ('44444444-0002-0000-0000-000000000001', '33333333-0001-0000-0000-000000000001', 'Red Onion',         'Bellary red onions, top grade A',                     'kg',     FALSE, TRUE),
    ('44444444-0003-0000-0000-000000000001', '33333333-0001-0000-0000-000000000001', 'Carrot',            'Ooty carrots, fresh and crisp',                       'kg',     TRUE,  TRUE),
    ('44444444-0004-0000-0000-000000000001', '33333333-0001-0000-0000-000000000001', 'Green Capsicum',    'Hybrid green bell pepper, firm texture',              'kg',     TRUE,  TRUE),
    ('44444444-0005-0000-0000-000000000001', '33333333-0001-0000-0000-000000000001', 'Potato',            'Bangalore blue potato, good shelf life',              'kg',     FALSE, TRUE),
    ('44444444-0006-0000-0000-000000000002', '33333333-0002-0000-0000-000000000002', 'Alphonso Mango',    'Premium GI-tagged Alphonso from Ratnagiri',           'dozen',  TRUE,  TRUE),
    ('44444444-0007-0000-0000-000000000002', '33333333-0002-0000-0000-000000000002', 'Robusta Banana',    'Energy-rich bananas, naturally ripened',              'dozen',  TRUE,  TRUE),
    ('44444444-0008-0000-0000-000000000002', '33333333-0002-0000-0000-000000000002', 'Papaya',            'Semi-ripe papaya, great for digestion',               'kg',     TRUE,  TRUE),
    ('44444444-0009-0000-0000-000000000003', '33333333-0003-0000-0000-000000000003', 'Sona Masuri Rice',  'Premium fine grain rice, stone-free',                 'kg',     FALSE, TRUE),
    ('44444444-0010-0000-0000-000000000003', '33333333-0003-0000-0000-000000000003', 'Toor Dal',          'Fresh yellow split pigeon peas',                      'kg',     FALSE, TRUE),
    ('44444444-0011-0000-0000-000000000004', '33333333-0004-0000-0000-000000000004', 'Palak (Spinach)',   'Tender fresh spinach leaves, morning harvest',        'bunch',  TRUE,  TRUE),
    ('44444444-0012-0000-0000-000000000004', '33333333-0004-0000-0000-000000000004', 'Methi Leaves',      'Aromatic fenugreek leaves',                           'bunch',  TRUE,  TRUE),
    ('44444444-0013-0000-0000-000000000005', '33333333-0005-0000-0000-000000000005', 'Farm Fresh Eggs',   'Free-range country eggs, no hormones',                'dozen',  FALSE, TRUE),
    ('44444444-0014-0000-0000-000000000005', '33333333-0005-0000-0000-000000000005', 'Buffalo Milk',      'Fresh unprocessed buffalo milk',                      'litre',  TRUE,  TRUE)
ON CONFLICT DO NOTHING;

-- ============================================================
-- E. USERS
-- ============================================================
INSERT INTO users (user_id, role_id, email, phone, password_hash, status) VALUES
    -- Admin
    ('55550001-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001', 'admin@agrilink.in',        '+919900000001', '$2a$10$hashedpassword_admin',   'Active'),
    -- Farmers
    ('55550002-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000003', 'ramu.farmer@gmail.com',   '+919900000002', '$2a$10$hashedpassword_farmer1', 'Active'),
    ('55550003-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000003', 'lakshmi.farm@gmail.com',  '+919900000003', '$2a$10$hashedpassword_farmer2', 'Active'),
    ('55550004-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000003', 'krishna.organic@gmail.com','+919900000004','$2a$10$hashedpassword_farmer3', 'Active'),
    -- Customers
    ('55550005-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000002', 'priya.customer@gmail.com', '+919900000005', '$2a$10$hashedpassword_cust1',   'Active'),
    ('55550006-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000002', 'arjun.buyer@gmail.com',    '+919900000006', '$2a$10$hashedpassword_cust2',   'Active'),
    ('55550007-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000002', 'sunitha.family@gmail.com', '+919900000007', '$2a$10$hashedpassword_cust3',   'Active'),
    -- Aggregators
    ('55550008-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000004', 'agrihub1@aggregator.in',   '+919900000008', '$2a$10$hashedpassword_agg1',    'Active'),
    ('55550009-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000004', 'krishiseva@aggregator.in', '+919900000009', '$2a$10$hashedpassword_agg2',    'Active'),
    -- Delivery Partners
    ('55550010-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000005', 'suresh.delivery@gmail.com','+919900000010', '$2a$10$hashedpassword_del1',    'Active'),
    ('55550011-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000005', 'mohan.rider@gmail.com',    '+919900000011', '$2a$10$hashedpassword_del2',    'Active')
ON CONFLICT DO NOTHING;

-- ============================================================
-- F. PARTIES
-- ============================================================
INSERT INTO party (party_id, user_id, party_type, kyc_status) VALUES
    ('66660001-0000-0000-0000-000000000001', '55550001-0000-0000-0000-000000000001', 'Admin',            'Approved'),
    ('66660002-0000-0000-0000-000000000001', '55550002-0000-0000-0000-000000000001', 'Farmer',           'Approved'),
    ('66660003-0000-0000-0000-000000000001', '55550003-0000-0000-0000-000000000001', 'Farmer',           'Approved'),
    ('66660004-0000-0000-0000-000000000001', '55550004-0000-0000-0000-000000000001', 'Farmer',           'Pending'),
    ('66660005-0000-0000-0000-000000000001', '55550005-0000-0000-0000-000000000001', 'Customer',         'Approved'),
    ('66660006-0000-0000-0000-000000000001', '55550006-0000-0000-0000-000000000001', 'Customer',         'Approved'),
    ('66660007-0000-0000-0000-000000000001', '55550007-0000-0000-0000-000000000001', 'Customer',         'Pending'),
    ('66660008-0000-0000-0000-000000000001', '55550008-0000-0000-0000-000000000001', 'Aggregator',       'Approved'),
    ('66660009-0000-0000-0000-000000000001', '55550009-0000-0000-0000-000000000001', 'Aggregator',       'Approved'),
    ('66660010-0000-0000-0000-000000000001', '55550010-0000-0000-0000-000000000001', 'Delivery Partner', 'Approved'),
    ('66660011-0000-0000-0000-000000000001', '55550011-0000-0000-0000-000000000001', 'Delivery Partner', 'Approved')
ON CONFLICT DO NOTHING;

-- ============================================================
-- G. CUSTOMERS
-- ============================================================
INSERT INTO customer (customer_id, party_id, loyalty_points) VALUES
    ('77770001-0000-0000-0000-000000000001', '66660005-0000-0000-0000-000000000001', 250),
    ('77770002-0000-0000-0000-000000000001', '66660006-0000-0000-0000-000000000001', 100),
    ('77770003-0000-0000-0000-000000000001', '66660007-0000-0000-0000-000000000001', 0)
ON CONFLICT DO NOTHING;

-- CUSTOMER ADDRESSES
INSERT INTO customer_address (address_id, customer_id, location_id, address_type, address_line1, city, state, pincode, is_default) VALUES
    ('88880001-0000-0000-0000-000000000001', '77770001-0000-0000-0000-000000000001', '22222222-0001-0000-0000-000000000001', 'Home', 'Flat 301, Green Valley Apts', 'Bengaluru', 'Karnataka', '560001', TRUE),
    ('88880002-0000-0000-0000-000000000001', '77770001-0000-0000-0000-000000000001', '22222222-0005-0000-0000-000000000005', 'Work', 'Tech Park, JP Nagar',          'Bengaluru', 'Karnataka', '560078', FALSE),
    ('88880003-0000-0000-0000-000000000001', '77770002-0000-0000-0000-000000000001', '22222222-0007-0000-0000-000000000007', 'Home', 'No. 45, 3rd Cross, Indiranagar','Bengaluru', 'Karnataka', '560038', TRUE),
    ('88880004-0000-0000-0000-000000000001', '77770003-0000-0000-0000-000000000001', '22222222-0008-0000-0000-000000000008', 'Home', 'Villa 12, Palm Residency',    'Bengaluru', 'Karnataka', '560034', TRUE)
ON CONFLICT DO NOTHING;

-- Update customer default addresses
UPDATE customer SET default_address_id = '88880001-0000-0000-0000-000000000001' WHERE customer_id = '77770001-0000-0000-0000-000000000001';
UPDATE customer SET default_address_id = '88880003-0000-0000-0000-000000000001' WHERE customer_id = '77770002-0000-0000-0000-000000000001';
UPDATE customer SET default_address_id = '88880004-0000-0000-0000-000000000001' WHERE customer_id = '77770003-0000-0000-0000-000000000001';

-- ============================================================
-- H. FARMERS
-- ============================================================
INSERT INTO farmer (farmer_id, party_id, farmer_code, bio, kyc_status, is_verified) VALUES
    ('99990001-0000-0000-0000-000000000001', '66660002-0000-0000-0000-000000000001', 'FRMER-001', 'Organic farmer from Chikkaballapur with 15 years experience.', 'Approved', TRUE),
    ('99990002-0000-0000-0000-000000000001', '66660003-0000-0000-0000-000000000001', 'FRMER-002', 'Vegetable specialist from Kolar with focus on pesticide-free crops.', 'Approved', TRUE),
    ('99990003-0000-0000-0000-000000000001', '66660004-0000-0000-0000-000000000001', 'FRMER-003', 'New farmer from Tumkur growing heritage grains and millets.', 'Pending', FALSE)
ON CONFLICT DO NOTHING;

-- FARMS
INSERT INTO farm (farm_id, farmer_id, farm_name, total_area, location_id, description, organic_certified, is_active) VALUES
    ('aaaa0001-0000-0000-0000-000000000001', '99990001-0000-0000-0000-000000000001', 'Ramu Organic Farm',       3.50, '22222222-0003-0000-0000-000000000003', 'Mixed vegetable and fruit farm with organic certification.', TRUE,  TRUE),
    ('aaaa0002-0000-0000-0000-000000000001', '99990001-0000-0000-0000-000000000001', 'Ramu Fruit Orchard',      2.00, '22222222-0002-0000-0000-000000000002', 'Dedicated mango and banana orchard.',                        TRUE,  TRUE),
    ('aaaa0003-0000-0000-0000-000000000001', '99990002-0000-0000-0000-000000000001', 'Lakshmi Vegetable Farm',  5.00, '22222222-0009-0000-0000-000000000009', 'Large vegetable farm near Kolar.',                           FALSE, TRUE),
    ('aaaa0004-0000-0000-0000-000000000001', '99990003-0000-0000-0000-000000000001', 'Krishna Grain Farm',      8.00, '22222222-0006-0000-0000-000000000006', 'Traditional grain farm, growing rice, dal and millets.',     FALSE, TRUE)
ON CONFLICT DO NOTHING;

-- FARMER_CROP (Harvest Batches)
INSERT INTO farmer_crop (farmer_crop_id, farm_id, crop_id, variety, sowing_date, expected_harvest_date, organic_level, grade, is_active) VALUES
    ('bbbb0001-0000-0000-0000-000000000001', 'aaaa0001-0000-0000-0000-000000000001', '44444444-0001-0000-0000-000000000001', 'Pusa Ruby',       '2026-04-01', '2026-07-15', 'Fully Organic',  'A', TRUE),
    ('bbbb0002-0000-0000-0000-000000000001', 'aaaa0001-0000-0000-0000-000000000001', '44444444-0002-0000-0000-000000000001', 'Bellary Red',     '2026-04-10', '2026-07-20', 'Conventional',   'A', TRUE),
    ('bbbb0003-0000-0000-0000-000000000001', 'aaaa0002-0000-0000-0000-000000000001', '44444444-0006-0000-0000-000000000002', 'Alphonso Hybrid', '2026-02-15', '2026-06-30', 'Fully Organic',  'A', TRUE),
    ('bbbb0004-0000-0000-0000-000000000001', 'aaaa0002-0000-0000-0000-000000000001', '44444444-0007-0000-0000-000000000002', 'Robusta',         '2026-03-01', '2026-06-15', 'Conventional',   'B', TRUE),
    ('bbbb0005-0000-0000-0000-000000000001', 'aaaa0003-0000-0000-0000-000000000001', '44444444-0003-0000-0000-000000000001', 'Ooty Queen',      '2026-04-15', '2026-07-10', 'Partially Organic','A', TRUE),
    ('bbbb0006-0000-0000-0000-000000000001', 'aaaa0003-0000-0000-0000-000000000001', '44444444-0005-0000-0000-000000000001', 'Local Blue',      '2026-05-01', '2026-08-15', 'Conventional',   'A', TRUE),
    ('bbbb0007-0000-0000-0000-000000000001', 'aaaa0004-0000-0000-0000-000000000001', '44444444-0009-0000-0000-000000000003', 'Sona Masuri',     '2026-01-15', '2026-07-01', 'Conventional',   'A', TRUE),
    ('bbbb0008-0000-0000-0000-000000000001', 'aaaa0004-0000-0000-0000-000000000001', '44444444-0010-0000-0000-000000000003', 'Local Yellow',    '2026-02-01', '2026-07-20', 'Conventional',   'B', TRUE)
ON CONFLICT DO NOTHING;

-- ============================================================
-- I. AGGREGATORS & WAREHOUSES
-- ============================================================
INSERT INTO aggregator (aggregator_id, party_id, aggregator_code, business_name, gstin, kyc_status, is_verified) VALUES
    ('cccc0001-0000-0000-0000-000000000001', '66660008-0000-0000-0000-000000000001', 'AGG-001', 'AgriHub Logistics Pvt Ltd', '29AGRIH0001Z1Z',  'Approved', TRUE),
    ('cccc0002-0000-0000-0000-000000000001', '66660009-0000-0000-0000-000000000001', 'AGG-002', 'Krishi Seva Cold Chain',    '29KRISH0002Z2Z',  'Approved', TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO warehouse (warehouse_id, aggregator_id, warehouse_name, warehouse_type, location_id, total_capacity_kg, occupied_capacity_kg, cold_storage, temperature_min, temperature_max, is_active) VALUES
    ('dddd0001-0000-0000-0000-000000000001', 'cccc0001-0000-0000-0000-000000000001', 'AgriHub Central Cold Store', 'Cold Room',      '22222222-0004-0000-0000-000000000004', 150000.00, 45000.00, TRUE,  2.0,  8.0,  TRUE),
    ('dddd0002-0000-0000-0000-000000000001', 'cccc0001-0000-0000-0000-000000000001', 'AgriHub Dry Warehouse',      'Dry Warehouse',  '22222222-0004-0000-0000-000000000004', 200000.00, 80000.00, FALSE, NULL, NULL, TRUE),
    ('dddd0003-0000-0000-0000-000000000001', 'cccc0002-0000-0000-0000-000000000001', 'Krishi Seva Cold Chain Hub', 'Cold Room',      '22222222-0006-0000-0000-000000000006', 100000.00, 30000.00, TRUE,  1.0,  6.0,  TRUE)
ON CONFLICT DO NOTHING;

-- ============================================================
-- J. PROCUREMENT
-- ============================================================
INSERT INTO procurement (procurement_id, farmer_id, aggregator_id, farmer_crop_id, quantity_kg, unit_price, total_price, quality_status, payment_status) VALUES
    ('eeee0001-0000-0000-0000-000000000001', '99990001-0000-0000-0000-000000000001', 'cccc0001-0000-0000-0000-000000000001', 'bbbb0001-0000-0000-0000-000000000001', 1000.00, 35.00, 35000.00, 'Passed', 'Paid'),
    ('eeee0002-0000-0000-0000-000000000001', '99990001-0000-0000-0000-000000000001', 'cccc0001-0000-0000-0000-000000000001', 'bbbb0002-0000-0000-0000-000000000001', 2000.00, 25.00, 50000.00, 'Passed', 'Paid'),
    ('eeee0003-0000-0000-0000-000000000001', '99990002-0000-0000-0000-000000000001', 'cccc0002-0000-0000-0000-000000000001', 'bbbb0005-0000-0000-0000-000000000001', 500.00,  40.00, 20000.00, 'Passed', 'Paid'),
    ('eeee0004-0000-0000-0000-000000000001', '99990003-0000-0000-0000-000000000001', 'cccc0001-0000-0000-0000-000000000001', 'bbbb0007-0000-0000-0000-000000000001', 5000.00, 38.00, 190000.00, 'Passed', 'Pending')
ON CONFLICT DO NOTHING;

-- ============================================================
-- K. INVENTORY BATCHES
-- ============================================================
INSERT INTO aggregator_inventory (inventory_batch_id, warehouse_id, aggregator_id, farmer_id, farmer_crop_id, batch_no, quantity_kg, unit_cost_price, available_quantity_kg, reserved_quantity_kg, quality_status, expiry_date) VALUES
    ('ffff0001-0000-0000-0000-000000000001', 'dddd0001-0000-0000-0000-000000000001', 'cccc0001-0000-0000-0000-000000000001', '99990001-0000-0000-0000-000000000001', 'bbbb0001-0000-0000-0000-000000000001', 'BAT-2026-0001', 1000.00, 38.00,  900.00, 100.00, 'Passed', NOW() + INTERVAL '15 days'),
    ('ffff0002-0000-0000-0000-000000000001', 'dddd0002-0000-0000-0000-000000000001', 'cccc0001-0000-0000-0000-000000000001', '99990001-0000-0000-0000-000000000001', 'bbbb0002-0000-0000-0000-000000000001', 'BAT-2026-0002', 2000.00, 28.00, 1800.00, 200.00, 'Passed', NOW() + INTERVAL '60 days'),
    ('ffff0003-0000-0000-0000-000000000001', 'dddd0003-0000-0000-0000-000000000001', 'cccc0002-0000-0000-0000-000000000001', '99990002-0000-0000-0000-000000000001', 'bbbb0005-0000-0000-0000-000000000001', 'BAT-2026-0003', 500.00,  42.00,  480.00,  20.00, 'Passed', NOW() + INTERVAL '10 days'),
    ('ffff0004-0000-0000-0000-000000000001', 'dddd0002-0000-0000-0000-000000000001', 'cccc0001-0000-0000-0000-000000000001', '99990003-0000-0000-0000-000000000001', 'bbbb0007-0000-0000-0000-000000000001', 'BAT-2026-0004', 5000.00, 40.00, 5000.00,   0.00, 'Passed', NOW() + INTERVAL '180 days')
ON CONFLICT DO NOTHING;

-- QUALITY CHECKS
INSERT INTO quality_check (qc_id, inventory_batch_id, checked_by, quality_grade, qc_status, moisture_level_pct, remarks, inspected_at) VALUES
    (uuid_generate_v4(), 'ffff0001-0000-0000-0000-000000000001', '55550001-0000-0000-0000-000000000001', 'A', 'Passed', 11.5, 'Excellent quality. Color and firmness optimal.', NOW() - INTERVAL '2 days'),
    (uuid_generate_v4(), 'ffff0002-0000-0000-0000-000000000001', '55550001-0000-0000-0000-000000000001', 'A', 'Passed', 10.2, 'Dry, no sprouting. Good shelf life expected.',   NOW() - INTERVAL '2 days'),
    (uuid_generate_v4(), 'ffff0003-0000-0000-0000-000000000001', '55550001-0000-0000-0000-000000000001', 'A', 'Passed', 12.0, 'Carrots firm and bright. No pests detected.',    NOW() - INTERVAL '1 day'),
    (uuid_generate_v4(), 'ffff0004-0000-0000-0000-000000000001', '55550001-0000-0000-0000-000000000001', 'A', 'Passed',  9.8, 'Rice moisture within limit. No discoloration.',  NOW() - INTERVAL '1 day');

-- ============================================================
-- L. DELIVERY PARTNERS
-- ============================================================
INSERT INTO delivery_partner (delivery_partner_id, party_id, partner_code, rating, kyc_status, is_active) VALUES
    ('gggg0001-0000-0000-0000-000000000001', '66660010-0000-0000-0000-000000000001', 'DEL-001', 4.85, 'Approved', TRUE),
    ('gggg0002-0000-0000-0000-000000000001', '66660011-0000-0000-0000-000000000001', 'DEL-002', 4.70, 'Approved', TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO vehicle (vehicle_id, delivery_partner_id, vehicle_type, vehicle_no, capacity_kg, current_load_kg, registration_no, is_active) VALUES
    (uuid_generate_v4(), 'gggg0001-0000-0000-0000-000000000001', 'Motorcycle',   'KA-03-HA-4501', 80.00,  0.00, 'KA03HA4501', TRUE),
    (uuid_generate_v4(), 'gggg0002-0000-0000-0000-000000000001', 'Mini Truck',   'KA-03-HB-7823', 800.00, 0.00, 'KA03HB7823', TRUE)
ON CONFLICT DO NOTHING;

-- ============================================================
-- M. ORDERS
-- ============================================================
INSERT INTO orders (order_id, customer_id, order_status, total_amount, delivery_address_id, payment_status, special_instructions) VALUES
    ('hhhh0001-0000-0000-0000-000000000001', '77770001-0000-0000-0000-000000000001', 'Delivered', 960.00,  '88880001-0000-0000-0000-000000000001', 'Paid',    'Please deliver before 9 AM.'),
    ('hhhh0002-0000-0000-0000-000000000001', '77770002-0000-0000-0000-000000000001', 'Confirmed', 760.00,  '88880003-0000-0000-0000-000000000001', 'Paid',    'Leave at guard room if not home.'),
    ('hhhh0003-0000-0000-0000-000000000001', '77770001-0000-0000-0000-000000000001', 'Placed',    1340.00, '88880001-0000-0000-0000-000000000001', 'Pending', NULL),
    ('hhhh0004-0000-0000-0000-000000000001', '77770003-0000-0000-0000-000000000001', 'Cancelled', 480.00,  '88880004-0000-0000-0000-000000000001', 'Refunded','Changed my mind.')
ON CONFLICT DO NOTHING;

-- ORDER ITEMS
INSERT INTO order_item (order_item_id, order_id, crop_id, quantity, unit_price, selected_type, subtotal) VALUES
    ('iiii0001-0000-0000-0000-000000000001', 'hhhh0001-0000-0000-0000-000000000001', '44444444-0001-0000-0000-000000000001', 10.00, 48.00, 'Aggregator', 480.00),
    ('iiii0002-0000-0000-0000-000000000001', 'hhhh0001-0000-0000-0000-000000000001', '44444444-0002-0000-0000-000000000001', 20.00, 24.00, 'Aggregator', 480.00),
    ('iiii0003-0000-0000-0000-000000000001', 'hhhh0002-0000-0000-0000-000000000001', '44444444-0003-0000-0000-000000000001',  8.00, 55.00, 'Aggregator', 440.00),
    ('iiii0004-0000-0000-0000-000000000001', 'hhhh0002-0000-0000-0000-000000000001', '44444444-0005-0000-0000-000000000001', 16.00, 20.00, 'Aggregator', 320.00),
    ('iiii0005-0000-0000-0000-000000000001', 'hhhh0003-0000-0000-0000-000000000001', '44444444-0009-0000-0000-000000000003', 20.00, 52.00, 'Aggregator',1040.00),
    ('iiii0006-0000-0000-0000-000000000001', 'hhhh0003-0000-0000-0000-000000000001', '44444444-0010-0000-0000-000000000003', 15.00, 20.00, 'Farmer',     300.00),
    ('iiii0007-0000-0000-0000-000000000001', 'hhhh0004-0000-0000-0000-000000000001', '44444444-0006-0000-0000-000000000002',  4.00,120.00, 'Farmer',     480.00)
ON CONFLICT DO NOTHING;

-- ORDER TRACKING
INSERT INTO order_tracking (tracking_id, order_id, status, remarks) VALUES
    (uuid_generate_v4(), 'hhhh0001-0000-0000-0000-000000000001', 'Placed',         'Order received successfully.'),
    (uuid_generate_v4(), 'hhhh0001-0000-0000-0000-000000000001', 'Confirmed',      'Payment confirmed. Processing started.'),
    (uuid_generate_v4(), 'hhhh0001-0000-0000-0000-000000000001', 'OutForDelivery', 'Handed to delivery partner Suresh.'),
    (uuid_generate_v4(), 'hhhh0001-0000-0000-0000-000000000001', 'Delivered',      'Delivered successfully. OTP verified.'),
    (uuid_generate_v4(), 'hhhh0002-0000-0000-0000-000000000001', 'Placed',         'Order received.'),
    (uuid_generate_v4(), 'hhhh0002-0000-0000-0000-000000000001', 'Confirmed',      'Payment verified. Awaiting dispatch.'),
    (uuid_generate_v4(), 'hhhh0003-0000-0000-0000-000000000001', 'Placed',         'Order placed. Awaiting payment.'),
    (uuid_generate_v4(), 'hhhh0004-0000-0000-0000-000000000001', 'Placed',         'Order placed.'),
    (uuid_generate_v4(), 'hhhh0004-0000-0000-0000-000000000001', 'Cancelled',      'Cancelled by customer before processing.');

-- ============================================================
-- N. PAYMENTS
-- ============================================================
INSERT INTO payment (payment_id, order_id, amount, payment_method, gateway_name, transaction_id, razorpay_order_id, razorpay_payment_id, payment_status) VALUES
    ('jjjj0001-0000-0000-0000-000000000001', 'hhhh0001-0000-0000-0000-000000000001',  960.00, 'UPI',  'Razorpay', 'TXN20260001', 'order_RZP0001', 'pay_RZP0001', 'Success'),
    ('jjjj0002-0000-0000-0000-000000000001', 'hhhh0002-0000-0000-0000-000000000001',  760.00, 'Card', 'Razorpay', 'TXN20260002', 'order_RZP0002', 'pay_RZP0002', 'Success'),
    ('jjjj0004-0000-0000-0000-000000000001', 'hhhh0004-0000-0000-0000-000000000001',  480.00, 'UPI',  'Razorpay', 'TXN20260004', 'order_RZP0004', 'pay_RZP0004', 'Refunded')
ON CONFLICT DO NOTHING;

-- ============================================================
-- O. CART DATA
-- ============================================================
INSERT INTO cart (cart_id, customer_id) VALUES
    ('kkkk0001-0000-0000-0000-000000000001', '77770001-0000-0000-0000-000000000001'),
    ('kkkk0002-0000-0000-0000-000000000001', '77770002-0000-0000-0000-000000000001'),
    ('kkkk0003-0000-0000-0000-000000000001', '77770003-0000-0000-0000-000000000001')
ON CONFLICT DO NOTHING;

INSERT INTO cart_item (cart_item_id, cart_id, crop_id, quantity, unit_price) VALUES
    (uuid_generate_v4(), 'kkkk0001-0000-0000-0000-000000000001', '44444444-0011-0000-0000-000000000004', 3.0, 15.00),
    (uuid_generate_v4(), 'kkkk0001-0000-0000-0000-000000000001', '44444444-0013-0000-0000-000000000005', 2.0, 72.00),
    (uuid_generate_v4(), 'kkkk0002-0000-0000-0000-000000000001', '44444444-0001-0000-0000-000000000001', 5.0, 48.00),
    (uuid_generate_v4(), 'kkkk0003-0000-0000-0000-000000000001', '44444444-0008-0000-0000-000000000002', 3.0, 35.00)
ON CONFLICT DO NOTHING;

-- ============================================================
-- P. WISHLISTS
-- ============================================================
INSERT INTO wishlist (wishlist_id, customer_id, crop_id) VALUES
    (uuid_generate_v4(), '77770001-0000-0000-0000-000000000001', '44444444-0006-0000-0000-000000000002'),
    (uuid_generate_v4(), '77770001-0000-0000-0000-000000000001', '44444444-0014-0000-0000-000000000005'),
    (uuid_generate_v4(), '77770002-0000-0000-0000-000000000001', '44444444-0009-0000-0000-000000000003'),
    (uuid_generate_v4(), '77770003-0000-0000-0000-000000000001', '44444444-0012-0000-0000-000000000004')
ON CONFLICT DO NOTHING;

-- ============================================================
-- Q. REVIEWS
-- ============================================================
INSERT INTO review (review_id, crop_id, customer_id, farmer_id, rating, review_text) VALUES
    (uuid_generate_v4(), '44444444-0001-0000-0000-000000000001', '77770001-0000-0000-0000-000000000001', '99990001-0000-0000-0000-000000000001', 5, 'Super fresh tomatoes! They looked and tasted like farm-fresh.'),
    (uuid_generate_v4(), '44444444-0002-0000-0000-000000000001', '77770001-0000-0000-0000-000000000001', '99990001-0000-0000-0000-000000000001', 4, 'Good quality onions. Slightly small but taste is great.'),
    (uuid_generate_v4(), '44444444-0003-0000-0000-000000000001', '77770002-0000-0000-0000-000000000001', '99990002-0000-0000-0000-000000000001', 5, 'Best carrots I have had. Crisp and sweet!');

-- ============================================================
-- R. COUPONS
-- ============================================================
INSERT INTO coupon (coupon_id, coupon_code, discount_type, discount_value, min_order_amount, max_discount_amount, usage_limit, valid_from, valid_to, is_active) VALUES
    ('llll0001-0000-0000-0000-000000000001', 'WELCOME100', 'Fixed',   100.00, 300.00,  NULL,   1,    NOW(),                    NOW() + INTERVAL '1 year',  TRUE),
    ('llll0002-0000-0000-0000-000000000001', 'AGRIFRESH',  'Percent',  10.00, 500.00, 200.00, 100,  NOW(),                    NOW() + INTERVAL '90 days', TRUE),
    ('llll0003-0000-0000-0000-000000000001', 'MONSOON50',  'Fixed',    50.00, 200.00,  NULL,  200,  NOW() - INTERVAL '1 day', NOW() + INTERVAL '30 days', TRUE),
    ('llll0004-0000-0000-0000-000000000001', 'FIRSTBUY',   'Percent',  15.00, 400.00, 300.00,  50,  NOW(),                    NOW() + INTERVAL '6 months',TRUE)
ON CONFLICT DO NOTHING;

-- ============================================================
-- S. NOTIFICATIONS
-- ============================================================
INSERT INTO notification (notification_id, user_id, title, message, type, is_read, is_delivered) VALUES
    (uuid_generate_v4(), '55550005-0000-0000-0000-000000000001', 'Welcome to AgriLink! 🌱',         'Thank you for joining AgriLink. Explore 200+ fresh crops delivered from local farmers!', 'SYSTEM',   'Y', 'Y'),
    (uuid_generate_v4(), '55550005-0000-0000-0000-000000000001', 'Order Delivered! ✅',              'Your order #ORD2026001 has been delivered successfully. Rate your experience!',          'ORDER',    'N', 'Y'),
    (uuid_generate_v4(), '55550006-0000-0000-0000-000000000001', 'Order Confirmed! 📦',              'Your order #ORD2026002 is confirmed and being prepared for dispatch.',                  'ORDER',    'N', 'Y'),
    (uuid_generate_v4(), '55550002-0000-0000-0000-000000000001', 'New Procurement Request 🚜',      'AgriHub Logistics wants to procure 1000 kg of Organic Tomatoes from your farm.',         'SYSTEM',   'N', 'Y'),
    (uuid_generate_v4(), '55550008-0000-0000-0000-000000000001', 'Batch Expiring Soon ⚠️',          'Batch BAT-2026-0003 (Carrots) expires in 10 days. Please plan dispatch.',               'SYSTEM',   'N', 'Y');

-- ============================================================
-- T. PRICE HISTORY & ML PREDICTIONS
-- ============================================================
INSERT INTO price_history (price_history_id, crop_id, old_price, new_price, source, changed_by) VALUES
    (uuid_generate_v4(), '44444444-0001-0000-0000-000000000001', 40.00, 45.00, 'Demand',     '55550001-0000-0000-0000-000000000001'),
    (uuid_generate_v4(), '44444444-0001-0000-0000-000000000001', 45.00, 48.00, 'Prediction', '55550001-0000-0000-0000-000000000001'),
    (uuid_generate_v4(), '44444444-0002-0000-0000-000000000001', 22.00, 25.00, 'Market',     '55550001-0000-0000-0000-000000000001'),
    (uuid_generate_v4(), '44444444-0009-0000-0000-000000000003', 48.00, 52.00, 'Manual',     '55550001-0000-0000-0000-000000000001');

INSERT INTO ml_price_prediction (prediction_id, crop_id, predicted_price, predicted_demand_kg, factors, confidence_score, effective_from, effective_to) VALUES
    (uuid_generate_v4(), '44444444-0001-0000-0000-000000000001', 52.00, 5000.00, 'Season:Monsoon,Demand:High,Festival:Ganesha', 0.8820, NOW(), NOW() + INTERVAL '30 days'),
    (uuid_generate_v4(), '44444444-0002-0000-0000-000000000001', 28.00, 8000.00, 'Season:Monsoon,Demand:Medium',                0.7650, NOW(), NOW() + INTERVAL '30 days'),
    (uuid_generate_v4(), '44444444-0006-0000-0000-000000000002', 145.00, 2000.00,'Season:Summer,Demand:Very High,Festival:Onam',0.9100, NOW(), NOW() + INTERVAL '45 days'),
    (uuid_generate_v4(), '44444444-0009-0000-0000-000000000003', 55.00, 12000.00,'Season:PostHarvest,Demand:High',              0.8300, NOW(), NOW() + INTERVAL '60 days');

-- ============================================================
-- U. DELIVERY
-- ============================================================
INSERT INTO delivery (delivery_id, order_id, delivery_type, delivery_status, pickup_address_id, delivery_address_id, scheduled_delivery_date, actual_delivery_date, delivery_charge) VALUES
    ('mmmm0001-0000-0000-0000-000000000001', 'hhhh0001-0000-0000-0000-000000000001', 'Drop', 'Delivered', '22222222-0004-0000-0000-000000000004', '88880001-0000-0000-0000-000000000001', NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day', 40.00),
    ('mmmm0002-0000-0000-0000-000000000001', 'hhhh0002-0000-0000-0000-000000000001', 'Drop', 'Assigned',  '22222222-0004-0000-0000-000000000004', '88880003-0000-0000-0000-000000000001', NOW() + INTERVAL '1 day',  NULL,                      40.00)
ON CONFLICT DO NOTHING;

INSERT INTO delivery_assignment (assignment_id, delivery_id, delivery_partner_id, status, actual_delivery_time, earning_amount) VALUES
    (uuid_generate_v4(), 'mmmm0001-0000-0000-0000-000000000001', 'gggg0001-0000-0000-0000-000000000001', 'Delivered', NOW() - INTERVAL '1 day', 40.00),
    (uuid_generate_v4(), 'mmmm0002-0000-0000-0000-000000000001', 'gggg0002-0000-0000-0000-000000000001', 'Assigned',  NULL,                     40.00);

INSERT INTO delivery_proof (proof_id, delivery_id, proof_type, otp_verified, remarks) VALUES
    (uuid_generate_v4(), 'mmmm0001-0000-0000-0000-000000000001', 'OTP', 'Y', 'Delivered to resident Priya. OTP 4521 confirmed.');

-- ============================================================
-- V. INVENTORY MOVEMENTS
-- ============================================================
INSERT INTO inventory_movement (movement_id, inventory_batch_id, movement_type, quantity_kg, reference_type, reference_id, performed_by, notes) VALUES
    (uuid_generate_v4(), 'ffff0001-0000-0000-0000-000000000001', 'IN',       1000.00, 'Procurement', 'eeee0001-0000-0000-0000-000000000001', '55550008-0000-0000-0000-000000000001', 'Initial stock receipt from procurement.'),
    (uuid_generate_v4(), 'ffff0001-0000-0000-0000-000000000001', 'RESERVED',  100.00, 'Order',       'hhhh0001-0000-0000-0000-000000000001', '55550008-0000-0000-0000-000000000001', 'Reserved for order hhhh0001.'),
    (uuid_generate_v4(), 'ffff0001-0000-0000-0000-000000000001', 'OUT',       100.00, 'Order',       'hhhh0001-0000-0000-0000-000000000001', '55550008-0000-0000-0000-000000000001', 'Dispatched for order hhhh0001.'),
    (uuid_generate_v4(), 'ffff0002-0000-0000-0000-000000000001', 'IN',       2000.00, 'Procurement', 'eeee0002-0000-0000-0000-000000000001', '55550008-0000-0000-0000-000000000001', 'Initial stock receipt from procurement.'),
    (uuid_generate_v4(), 'ffff0004-0000-0000-0000-000000000001', 'IN',       5000.00, 'Procurement', 'eeee0004-0000-0000-0000-000000000001', '55550008-0000-0000-0000-000000000001', 'Initial stock receipt — pending farmer payment.');

-- BATCH EXPIRY ALERTS
INSERT INTO batch_expiry_alert (alert_id, inventory_batch_id, alert_type, notified_to, status) VALUES
    (uuid_generate_v4(), 'ffff0003-0000-0000-0000-000000000001', 'Expiring Soon', '55550009-0000-0000-0000-000000000001', 'Unread'),
    (uuid_generate_v4(), 'ffff0001-0000-0000-0000-000000000001', 'Expiring Soon', '55550008-0000-0000-0000-000000000001', 'Unread');

-- ============================================================
-- Final verification count
-- ============================================================
SELECT
    (SELECT COUNT(*) FROM role)                     AS roles,
    (SELECT COUNT(*) FROM location)                 AS locations,
    (SELECT COUNT(*) FROM crop_category)            AS crop_categories,
    (SELECT COUNT(*) FROM crop)                     AS crops,
    (SELECT COUNT(*) FROM users)                    AS users,
    (SELECT COUNT(*) FROM party)                    AS parties,
    (SELECT COUNT(*) FROM customer)                 AS customers,
    (SELECT COUNT(*) FROM customer_address)         AS addresses,
    (SELECT COUNT(*) FROM farmer)                   AS farmers,
    (SELECT COUNT(*) FROM farm)                     AS farms,
    (SELECT COUNT(*) FROM farmer_crop)              AS farmer_crops,
    (SELECT COUNT(*) FROM aggregator)               AS aggregators,
    (SELECT COUNT(*) FROM warehouse)                AS warehouses,
    (SELECT COUNT(*) FROM procurement)              AS procurements,
    (SELECT COUNT(*) FROM aggregator_inventory)     AS inventory_batches,
    (SELECT COUNT(*) FROM quality_check)            AS quality_checks,
    (SELECT COUNT(*) FROM orders)                   AS orders,
    (SELECT COUNT(*) FROM order_item)               AS order_items,
    (SELECT COUNT(*) FROM delivery_partner)         AS delivery_partners,
    (SELECT COUNT(*) FROM vehicle)                  AS vehicles,
    (SELECT COUNT(*) FROM delivery)                 AS deliveries,
    (SELECT COUNT(*) FROM delivery_assignment)      AS delivery_assignments,
    (SELECT COUNT(*) FROM payment)                  AS payments,
    (SELECT COUNT(*) FROM cart)                     AS carts,
    (SELECT COUNT(*) FROM cart_item)                AS cart_items,
    (SELECT COUNT(*) FROM wishlist)                 AS wishlists,
    (SELECT COUNT(*) FROM review)                   AS reviews,
    (SELECT COUNT(*) FROM coupon)                   AS coupons,
    (SELECT COUNT(*) FROM notification)             AS notifications,
    (SELECT COUNT(*) FROM price_history)            AS price_histories,
    (SELECT COUNT(*) FROM ml_price_prediction)      AS ml_predictions,
    (SELECT COUNT(*) FROM inventory_movement)       AS inventory_movements,
    (SELECT COUNT(*) FROM batch_expiry_alert)       AS expiry_alerts;
