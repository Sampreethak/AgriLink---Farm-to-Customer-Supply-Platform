-- ============================================================
-- 21_seed_data.sql
-- Complete realistic seed data for AgriLink PostgreSQL database
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
-- D. CROPS
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
    ('55550001-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001', 'admin@agrilink.in',        '+919900000001', '$2a$10$hashedpassword_admin',   'Active'),
    ('55550002-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000003', 'ramu.farmer@gmail.com',   '+919900000002', '$2a$10$hashedpassword_farmer1', 'Active'),
    ('55550003-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000003', 'lakshmi.farm@gmail.com',  '+919900000003', '$2a$10$hashedpassword_farmer2', 'Active'),
    ('55550004-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000003', 'krishna.organic@gmail.com','+919900000004','$2a$10$hashedpassword_farmer3', 'Active'),
    ('55550005-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000002', 'priya.customer@gmail.com', '+919900000005', '$2a$10$hashedpassword_cust1',   'Active'),
    ('55550006-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000002', 'arjun.buyer@gmail.com',    '+919900000006', '$2a$10$hashedpassword_cust2',   'Active'),
    ('55550007-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000002', 'sunitha.family@gmail.com', '+919900000007', '$2a$10$hashedpassword_cust3',   'Active'),
    ('55550008-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000004', 'agrihub1@aggregator.in',   '+919900000008', '$2a$10$hashedpassword_agg1',    'Active'),
    ('55550009-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000004', 'krishiseva@aggregator.in', '+919900000009', '$2a$10$hashedpassword_agg2',    'Active'),
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
-- G. CUSTOMERS & ADDRESSES
-- ============================================================
INSERT INTO customer (customer_id, party_id, loyalty_points) VALUES
    ('77770001-0000-0000-0000-000000000001', '66660005-0000-0000-0000-000000000001', 250),
    ('77770002-0000-0000-0000-000000000001', '66660006-0000-0000-0000-000000000001', 100),
    ('77770003-0000-0000-0000-000000000001', '66660007-0000-0000-0000-000000000001', 0)
ON CONFLICT DO NOTHING;

INSERT INTO customer_address (address_id, customer_id, location_id, address_type, address_line1, city, state, pincode, is_default) VALUES
    ('88880001-0000-0000-0000-000000000001', '77770001-0000-0000-0000-000000000001', '22222222-0001-0000-0000-000000000001', 'Home', 'Flat 301, Green Valley Apts', 'Bengaluru', 'Karnataka', '560001', TRUE),
    ('88880002-0000-0000-0000-000000000001', '77770001-0000-0000-0000-000000000001', '22222222-0005-0000-0000-000000000005', 'Work', 'Tech Park, JP Nagar',          'Bengaluru', 'Karnataka', '560078', FALSE),
    ('88880003-0000-0000-0000-000000000001', '77770002-0000-0000-0000-000000000001', '22222222-0007-0000-0000-000000000007', 'Home', 'No. 45, 3rd Cross, Indiranagar','Bengaluru', 'Karnataka', '560038', TRUE),
    ('88880004-0000-0000-0000-000000000001', '77770003-0000-0000-0000-000000000001', '22222222-0008-0000-0000-000000000008', 'Home', 'Villa 12, Palm Residency',    'Bengaluru', 'Karnataka', '560034', TRUE)
ON CONFLICT DO NOTHING;

UPDATE customer SET default_address_id = '88880001-0000-0000-0000-000000000001' WHERE customer_id = '77770001-0000-0000-0000-000000000001';
UPDATE customer SET default_address_id = '88880003-0000-0000-0000-000000000001' WHERE customer_id = '77770002-0000-0000-0000-000000000001';
UPDATE customer SET default_address_id = '88880004-0000-0000-0000-000000000001' WHERE customer_id = '77770003-0000-0000-0000-000000000001';

-- ============================================================
-- H. FARMERS, FARMS, CROP BATCHES
-- ============================================================
INSERT INTO farmer (farmer_id, party_id, farmer_code, bio, kyc_status, is_verified) VALUES
    ('99990001-0000-0000-0000-000000000001', '66660002-0000-0000-0000-000000000001', 'FRMER-001', 'Organic farmer from Chikkaballapur with 15 years experience.', 'Approved', TRUE),
    ('99990002-0000-0000-0000-000000000001', '66660003-0000-0000-0000-000000000001', 'FRMER-002', 'Vegetable specialist from Kolar with focus on pesticide-free crops.', 'Approved', TRUE),
    ('99990003-0000-0000-0000-000000000001', '66660004-0000-0000-0000-000000000001', 'FRMER-003', 'New farmer from Tumkur growing heritage grains and millets.', 'Pending', FALSE)
ON CONFLICT DO NOTHING;

INSERT INTO farm (farm_id, farmer_id, farm_name, total_area, location_id, description, organic_certified, is_active) VALUES
    ('aaaa0001-0000-0000-0000-000000000001', '99990001-0000-0000-0000-000000000001', 'Ramu Organic Farm',       3.50, '22222222-0003-0000-0000-000000000003', 'Mixed vegetable and fruit farm with organic certification.', TRUE,  TRUE),
    ('aaaa0002-0000-0000-0000-000000000001', '99990001-0000-0000-0000-000000000001', 'Ramu Fruit Orchard',      2.00, '22222222-0002-0000-0000-000000000002', 'Dedicated mango and banana orchard.',                        TRUE,  TRUE),
    ('aaaa0003-0000-0000-0000-000000000001', '99990002-0000-0000-0000-000000000001', 'Lakshmi Vegetable Farm',  5.00, '22222222-0009-0000-0000-000000000009', 'Large vegetable farm near Kolar.',                           FALSE, TRUE),
    ('aaaa0004-0000-0000-0000-000000000001', '99990003-0000-0000-0000-000000000001', 'Krishna Grain Farm',      8.00, '22222222-0006-0000-0000-000000000006', 'Traditional grain farm, growing rice, dal and millets.',     FALSE, TRUE)
ON CONFLICT DO NOTHING;

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
-- J. PROCUREMENT & INVENTORY
-- ============================================================
INSERT INTO procurement (procurement_id, farmer_id, aggregator_id, farmer_crop_id, quantity_kg, unit_price, total_price, quality_status, payment_status) VALUES
    ('eeee0001-0000-0000-0000-000000000001', '99990001-0000-0000-0000-000000000001', 'cccc0001-0000-0000-0000-000000000001', 'bbbb0001-0000-0000-0000-000000000001', 1000.00, 35.00, 35000.00, 'Passed', 'Paid'),
    ('eeee0002-0000-0000-0000-000000000001', '99990001-0000-0000-0000-000000000001', 'cccc0001-0000-0000-0000-000000000001', 'bbbb0002-0000-0000-0000-000000000001', 2000.00, 25.00, 50000.00, 'Passed', 'Paid'),
    ('eeee0003-0000-0000-0000-000000000001', '99990002-0000-0000-0000-000000000001', 'cccc0002-0000-0000-0000-000000000001', 'bbbb0005-0000-0000-0000-000000000001', 500.00,  40.00, 20000.00, 'Passed', 'Paid'),
    ('eeee0004-0000-0000-0000-000000000001', '99990003-0000-0000-0000-000000000001', 'cccc0001-0000-0000-0000-000000000001', 'bbbb0007-0000-0000-0000-000000000001', 5000.00, 38.00, 190000.00, 'Passed', 'Pending')
ON CONFLICT DO NOTHING;

INSERT INTO aggregator_inventory (inventory_batch_id, warehouse_id, aggregator_id, farmer_id, farmer_crop_id, batch_no, quantity_kg, unit_cost_price, available_quantity_kg, reserved_quantity_kg, quality_status, expiry_date) VALUES
    ('ffff0001-0000-0000-0000-000000000001', 'dddd0001-0000-0000-0000-000000000001', 'cccc0001-0000-0000-0000-000000000001', '99990001-0000-0000-0000-000000000001', 'bbbb0001-0000-0000-0000-000000000001', 'BAT-2026-0001', 1000.00, 38.00,  900.00, 100.00, 'Passed', NOW() + INTERVAL '15 days'),
    ('ffff0002-0000-0000-0000-000000000001', 'dddd0002-0000-0000-0000-000000000001', 'cccc0001-0000-0000-0000-000000000001', '99990001-0000-0000-0000-000000000001', 'bbbb0002-0000-0000-0000-000000000001', 'BAT-2026-0002', 2000.00, 28.00, 1800.00, 200.00, 'Passed', NOW() + INTERVAL '60 days'),
    ('ffff0003-0000-0000-0000-000000000001', 'dddd0003-0000-0000-0000-000000000001', 'cccc0002-0000-0000-0000-000000000001', '99990002-0000-0000-0000-000000000001', 'bbbb0005-0000-0000-0000-000000000001', 'BAT-2026-0003', 500.00,  42.00,  480.00,  20.00, 'Passed', NOW() + INTERVAL '10 days'),
    ('ffff0004-0000-0000-0000-000000000001', 'dddd0002-0000-0000-0000-000000000001', 'cccc0001-0000-0000-0000-000000000001', '99990003-0000-0000-0000-000000000001', 'bbbb0007-0000-0000-0000-000000000001', 'BAT-2026-0004', 5000.00, 40.00, 5000.00,   0.00, 'Passed', NOW() + INTERVAL '180 days')
ON CONFLICT DO NOTHING;

INSERT INTO quality_check (qc_id, inventory_batch_id, checked_by, quality_grade, qc_status, moisture_level_pct, remarks, inspected_at) VALUES
    (gen_random_uuid(), 'ffff0001-0000-0000-0000-000000000001', '55550001-0000-0000-0000-000000000001', 'A', 'Passed', 11.5, 'Excellent quality. Color and firmness optimal.', NOW() - INTERVAL '2 days'),
    (gen_random_uuid(), 'ffff0002-0000-0000-0000-000000000001', '55550001-0000-0000-0000-000000000001', 'A', 'Passed', 10.2, 'Dry, no sprouting. Good shelf life expected.',   NOW() - INTERVAL '2 days'),
    (gen_random_uuid(), 'ffff0003-0000-0000-0000-000000000001', '55550001-0000-0000-0000-000000000001', 'A', 'Passed', 12.0, 'Carrots firm and bright. No pests detected.',    NOW() - INTERVAL '1 day'),
    (gen_random_uuid(), 'ffff0004-0000-0000-0000-000000000001', '55550001-0000-0000-0000-000000000001', 'A', 'Passed',  9.8, 'Rice moisture within limit. No discoloration.',  NOW() - INTERVAL '1 day');

-- ============================================================
-- K. LOGISTICS & DELIVERY PARTNERS
-- ============================================================
INSERT INTO delivery_partner (delivery_partner_id, party_id, partner_code, rating, kyc_status, is_active) VALUES
    ('17170001-0000-0000-0000-000000000001', '66660010-0000-0000-0000-000000000001', 'DEL-001', 4.85, 'Approved', TRUE),
    ('17170002-0000-0000-0000-000000000001', '66660011-0000-0000-0000-000000000001', 'DEL-002', 4.70, 'Approved', TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO vehicle (vehicle_id, delivery_partner_id, vehicle_type, vehicle_no, capacity_kg, current_load_kg, registration_no, is_active) VALUES
    (gen_random_uuid(), '17170001-0000-0000-0000-000000000001', 'Motorcycle',   'KA-03-HA-4501', 80.00,  0.00, 'KA03HA4501', TRUE),
    (gen_random_uuid(), '17170002-0000-0000-0000-000000000001', 'Mini Truck',   'KA-03-HB-7823', 800.00, 0.00, 'KA03HB7823', TRUE)
ON CONFLICT DO NOTHING;

-- ============================================================
-- L. ORDERS & ORDER ITEMS
-- ============================================================
INSERT INTO orders (order_id, customer_id, order_status, total_amount, delivery_address_id, payment_status, special_instructions) VALUES
    ('18180001-0000-0000-0000-000000000001', '77770001-0000-0000-0000-000000000001', 'Delivered', 960.00,  '88880001-0000-0000-0000-000000000001', 'Paid',    'Please deliver before 9 AM.'),
    ('18180002-0000-0000-0000-000000000001', '77770002-0000-0000-0000-000000000001', 'Confirmed', 760.00,  '88880003-0000-0000-0000-000000000001', 'Paid',    'Leave at guard room if not home.'),
    ('18180003-0000-0000-0000-000000000001', '77770001-0000-0000-0000-000000000001', 'Placed',    1340.00, '88880001-0000-0000-0000-000000000001', 'Pending', NULL),
    ('18180004-0000-0000-0000-000000000001', '77770003-0000-0000-0000-000000000001', 'Cancelled', 480.00,  '88880004-0000-0000-0000-000000000001', 'Refunded','Changed my mind.')
ON CONFLICT DO NOTHING;

INSERT INTO order_item (order_item_id, order_id, crop_id, quantity, unit_price, selected_type, subtotal) VALUES
    ('19190001-0000-0000-0000-000000000001', '18180001-0000-0000-0000-000000000001', '44444444-0001-0000-0000-000000000001', 10.00, 48.00, 'Aggregator', 480.00),
    ('19190002-0000-0000-0000-000000000001', '18180001-0000-0000-0000-000000000001', '44444444-0002-0000-0000-000000000001', 20.00, 24.00, 'Aggregator', 480.00),
    ('19190003-0000-0000-0000-000000000001', '18180002-0000-0000-0000-000000000001', '44444444-0003-0000-0000-000000000001',  8.00, 55.00, 'Aggregator', 440.00),
    ('19190004-0000-0000-0000-000000000001', '18180002-0000-0000-0000-000000000001', '44444444-0005-0000-0000-000000000001', 16.00, 20.00, 'Aggregator', 320.00),
    ('19190005-0000-0000-0000-000000000001', '18180003-0000-0000-0000-000000000001', '44444444-0009-0000-0000-000000000003', 20.00, 52.00, 'Aggregator',1040.00),
    ('19190006-0000-0000-0000-000000000001', '18180003-0000-0000-0000-000000000001', '44444444-0010-0000-0000-000000000003', 15.00, 20.00, 'Farmer',     300.00),
    ('19190007-0000-0000-0000-000000000001', '18180004-0000-0000-0000-000000000001', '44444444-0006-0000-0000-000000000002',  4.00,120.00, 'Farmer',     480.00)
ON CONFLICT DO NOTHING;

-- Order Tracking History
INSERT INTO order_tracking (tracking_id, order_id, status, remarks) VALUES
    (gen_random_uuid(), '18180001-0000-0000-0000-000000000001', 'Placed',         'Order received successfully.'),
    (gen_random_uuid(), '18180001-0000-0000-0000-000000000001', 'Confirmed',      'Payment confirmed. Processing started.'),
    (gen_random_uuid(), '18180001-0000-0000-0000-000000000001', 'OutForDelivery', 'Handed to delivery partner Suresh.'),
    (gen_random_uuid(), '18180001-0000-0000-0000-000000000001', 'Delivered',      'Delivered successfully. OTP verified.'),
    (gen_random_uuid(), '18180002-0000-0000-0000-000000000001', 'Placed',         'Order received.'),
    (gen_random_uuid(), '18180002-0000-0000-0000-000000000001', 'Confirmed',      'Payment verified. Awaiting dispatch.'),
    (gen_random_uuid(), '18180003-0000-0000-0000-000000000001', 'Placed',         'Order placed. Awaiting payment.'),
    (gen_random_uuid(), '18180004-0000-0000-0000-000000000001', 'Placed',         'Order placed.'),
    (gen_random_uuid(), '18180004-0000-0000-0000-000000000001', 'Cancelled',      'Cancelled by customer before processing.');

-- ============================================================
-- M. PAYMENTS
-- ============================================================
INSERT INTO payment (payment_id, order_id, amount, payment_method, gateway_name, transaction_id, razorpay_order_id, razorpay_payment_id, payment_status) VALUES
    ('20200001-0000-0000-0000-000000000001', '18180001-0000-0000-0000-000000000001',  960.00, 'UPI',  'Razorpay', 'TXN20260001', 'order_RZP0001', 'pay_RZP0001', 'Success'),
    ('20200002-0000-0000-0000-000000000001', '18180002-0000-0000-0000-000000000001',  760.00, 'Card', 'Razorpay', 'TXN20260002', 'order_RZP0002', 'pay_RZP0002', 'Success'),
    ('20200004-0000-0000-0000-000000000001', '18180004-0000-0000-0000-000000000001',  480.00, 'UPI',  'Razorpay', 'TXN20260004', 'order_RZP0004', 'pay_RZP0004', 'Refunded')
ON CONFLICT DO NOTHING;

-- ============================================================
-- N. CARTS & ENGAGEMENT
-- ============================================================
INSERT INTO cart (cart_id, customer_id) VALUES
    ('21210001-0000-0000-0000-000000000001', '77770001-0000-0000-0000-000000000001'),
    ('21210002-0000-0000-0000-000000000001', '77770002-0000-0000-0000-000000000001'),
    ('21210003-0000-0000-0000-000000000001', '77770003-0000-0000-0000-000000000001')
ON CONFLICT DO NOTHING;

INSERT INTO cart_item (cart_item_id, cart_id, crop_id, quantity, unit_price) VALUES
    (gen_random_uuid(), '21210001-0000-0000-0000-000000000001', '44444444-0011-0000-0000-000000000004', 3.0, 15.00),
    (gen_random_uuid(), '21210001-0000-0000-0000-000000000001', '44444444-0013-0000-0000-000000000005', 2.0, 72.00),
    (gen_random_uuid(), '21210002-0000-0000-0000-000000000001', '44444444-0001-0000-0000-000000000001', 5.0, 48.00),
    (gen_random_uuid(), '21210003-0000-0000-0000-000000000001', '44444444-0008-0000-0000-000000000002', 3.0, 35.00)
ON CONFLICT DO NOTHING;

INSERT INTO wishlist (wishlist_id, customer_id, crop_id) VALUES
    (gen_random_uuid(), '77770001-0000-0000-0000-000000000001', '44444444-0006-0000-0000-000000000002'),
    (gen_random_uuid(), '77770001-0000-0000-0000-000000000001', '44444444-0014-0000-0000-000000000005'),
    (gen_random_uuid(), '77770002-0000-0000-0000-000000000001', '44444444-0009-0000-0000-000000000003')
ON CONFLICT DO NOTHING;

INSERT INTO review (review_id, crop_id, customer_id, farmer_id, rating, review_text) VALUES
    (gen_random_uuid(), '44444444-0001-0000-0000-000000000001', '77770001-0000-0000-0000-000000000001', '99990001-0000-0000-0000-000000000001', 5, 'Super fresh tomatoes! Farm-fresh quality.'),
    (gen_random_uuid(), '44444444-0002-0000-0000-000000000001', '77770001-0000-0000-0000-000000000001', '99990001-0000-0000-0000-000000000001', 4, 'Good quality red onions. Great taste.')
ON CONFLICT DO NOTHING;

INSERT INTO coupon (coupon_id, coupon_code, discount_type, discount_value, min_order_amount, max_discount_amount, usage_limit, valid_from, valid_to, is_active) VALUES
    ('22220001-0000-0000-0000-000000000001', 'WELCOME100', 'Fixed',   100.00, 300.00,  NULL,   1,    NOW(),                    NOW() + INTERVAL '1 year',  TRUE),
    ('22220002-0000-0000-0000-000000000001', 'AGRIFRESH',  'Percent',  10.00, 500.00, 200.00, 100,  NOW(),                    NOW() + INTERVAL '90 days', TRUE)
ON CONFLICT DO NOTHING;

-- ============================================================
-- O. NOTIFICATIONS & DELIVERIES
-- ============================================================
INSERT INTO notification (notification_id, user_id, title, message, type, is_read, is_delivered) VALUES
    (gen_random_uuid(), '55550005-0000-0000-0000-000000000001', 'Welcome to AgriLink! 🌱',         'Thank you for joining AgriLink.', 'SYSTEM',   'Y', 'Y'),
    (gen_random_uuid(), '55550005-0000-0000-0000-000000000001', 'Order Delivered! ✅',              'Your order #18180001 has been delivered.', 'ORDER', 'N', 'Y')
ON CONFLICT DO NOTHING;

INSERT INTO delivery (delivery_id, order_id, delivery_type, delivery_status, pickup_address_id, delivery_address_id, scheduled_delivery_date, actual_delivery_date, delivery_charge) VALUES
    ('23230001-0000-0000-0000-000000000001', '18180001-0000-0000-0000-000000000001', 'Drop', 'Delivered', '22222222-0004-0000-0000-000000000004', '88880001-0000-0000-0000-000000000001', NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day', 40.00)
ON CONFLICT DO NOTHING;

INSERT INTO delivery_assignment (assignment_id, delivery_id, delivery_partner_id, status, actual_delivery_time, earning_amount) VALUES
    (gen_random_uuid(), '23230001-0000-0000-0000-000000000001', '17170001-0000-0000-0000-000000000001', 'Delivered', NOW() - INTERVAL '1 day', 40.00);

INSERT INTO delivery_proof (proof_id, delivery_id, proof_type, otp_verified, remarks) VALUES
    (gen_random_uuid(), '23230001-0000-0000-0000-000000000001', 'OTP', 'Y', 'Delivered to resident. OTP verified.');

-- ============================================================
-- P. INVENTORY LEDGER & ALERTS
-- ============================================================
INSERT INTO inventory_movement (movement_id, inventory_batch_id, movement_type, quantity_kg, reference_type, reference_id, performed_by, notes) VALUES
    (gen_random_uuid(), 'ffff0001-0000-0000-0000-000000000001', 'IN', 1000.00, 'Procurement', 'eeee0001-0000-0000-0000-000000000001', '55550008-0000-0000-0000-000000000001', 'Initial stock receipt from procurement.');

INSERT INTO batch_expiry_alert (alert_id, inventory_batch_id, alert_type, notified_to, status) VALUES
    (gen_random_uuid(), 'ffff0003-0000-0000-0000-000000000001', 'Expiring Soon', '55550009-0000-0000-0000-000000000001', 'Unread');
