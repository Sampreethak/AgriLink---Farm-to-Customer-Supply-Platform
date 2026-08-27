-- ============================================================
-- AGRILINK MASTER SEED DATA (STRICT VALID HEXADECIMAL UUIDs)
-- ============================================================

-- 1. APP USER & ROLE SEED
INSERT INTO role (role_id, role_name, role_description) VALUES
('11111111-1111-1111-1111-111111111111', 'FARMER', 'Verified Farm Producer'),
('22222222-2222-2222-2222-222222222222', 'BUYER', 'Individual / Retail Crop Buyer'),
('33333333-3333-3333-3333-333333333333', 'AGGREGATOR', 'Regional Supply Hub Manager')
ON CONFLICT (role_id) DO NOTHING;

INSERT INTO location (location_id, address_line1, city, state, pincode, country, latitude, longitude) VALUES
('44444444-4444-4444-4444-444444444444', 'Farm Plot 42, Dindori Road', 'Nashik', 'Maharashtra', '422004', 'India', 20.0059, 73.7898),
('55555555-5555-5555-5555-555555555555', 'Orchard Valley, Thanedhar', 'Shimla', 'Himachal Pradesh', '171213', 'India', 31.1048, 77.1734),
('66666666-6666-6666-6666-666666666666', 'Sunshine Heights, Bandra West', 'Mumbai', 'Maharashtra', '400050', 'India', 19.0760, 72.8777)
ON CONFLICT (location_id) DO NOTHING;

INSERT INTO app_user (user_id, role_id, location_id, email, phone, full_name) VALUES
('77777777-7777-7777-7777-777777777777', '11111111-1111-1111-1111-111111111111', '44444444-4444-4444-4444-444444444444', 'ramesh.farmer@agrilink.com', '+919876543210', 'Ramesh Kumar'),
('88888888-8888-8888-8888-888888888888', '11111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555555', 'anita.farmer@agrilink.com', '+919876543212', 'Anita Sharma'),
('99999999-9999-9999-9999-999999999999', '22222222-2222-2222-2222-222222222222', '66666666-6666-6666-6666-666666666666', 'priya.buyer@agrilink.com', '+919811122233', 'Priya Verma')
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO farmer_profile (farmer_id, user_id, farm_size_acres, primary_crops, kyc_verified) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '77777777-7777-7777-7777-777777777777', 12.5, 'Tomato, Onion, Capsicum', true),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '88888888-8888-8888-8888-888888888888', 8.0, 'Apple, Honey, Cherries', true)
ON CONFLICT (farmer_id) DO NOTHING;

INSERT INTO customer_profile (customer_id, user_id, customer_type) VALUES
('cccccccc-cccc-cccc-cccc-cccccccccccc', '99999999-9999-9999-9999-999999999999', 'INDIVIDUAL')
ON CONFLICT (customer_id) DO NOTHING;

-- 2. CROP CATEGORIES & CROPS
INSERT INTO crop_category (category_id, category_name, description) VALUES
('11111111-2222-3333-4444-555555555555', 'Vegetables', 'Fresh organic and farm-direct vegetables'),
('22222222-3333-4444-5555-666666666666', 'Fruits', 'Fresh seasonal orchard fruits'),
('33333333-4444-5555-6666-777777777777', 'Grains & Pulses', 'High quality wheat, rice, pulses')
ON CONFLICT (category_id) DO NOTHING;

INSERT INTO crop (crop_id, category_id, crop_name, description, unit, is_perishable) VALUES
('dddddddd-dddd-dddd-dddd-dddddddddddd', '11111111-2222-3333-4444-555555555555', 'Tomato', 'Juicy red tomatoes', 'kg', true),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '22222222-3333-4444-5555-666666666666', 'Apple', 'Shimla Royal Delicious Apples', 'kg', true),
('ffffffff-ffff-ffff-ffff-ffffffffffff', '11111111-2222-3333-4444-555555555555', 'Onion', 'Dried red organic onions', 'kg', true)
ON CONFLICT (crop_id) DO NOTHING;

-- 3. INVENTORY & LISTINGS
INSERT INTO inventory_item (inventory_id, farmer_id, crop_id, quantity, price_per_unit, grade, status) VALUES
('10000000-0000-0000-0000-000000000001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 1500.0, 28.00, 'A+', 'AVAILABLE'),
('20000000-0000-0000-0000-000000000002', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 1200.0, 120.00, 'A+', 'AVAILABLE')
ON CONFLICT (inventory_id) DO NOTHING;

INSERT INTO seller_listing (listing_id, inventory_id, title, is_organic, rating_avg, rating_count) VALUES
('30000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', 'Fresh Red Tomatoes (Nashik Special)', true, 4.8, 42),
('40000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000002', 'Shimla Royal Delicious Apples', true, 4.95, 65)
ON CONFLICT (listing_id) DO NOTHING;

-- 4. ORDERS & DELIVERIES
INSERT INTO customer_order (order_id, customer_id, total_amount, order_status, payment_method) VALUES
('50000000-0000-0000-0000-000000000005', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 1400.00, 'PAID', 'RAZORPAY')
ON CONFLICT (order_id) DO NOTHING;

INSERT INTO order_item (order_item_id, order_id, listing_id, quantity, unit_price) VALUES
('60000000-0000-0000-0000-000000000006', '50000000-0000-0000-0000-000000000005', '30000000-0000-0000-0000-000000000003', 50.0, 28.00)
ON CONFLICT (order_item_id) DO NOTHING;

INSERT INTO delivery (delivery_id, order_id, delivery_agent_name, delivery_status, tracking_code) VALUES
('70000000-0000-0000-0000-000000000007', '50000000-0000-0000-0000-000000000005', 'Express Cold Logistics', 'DELIVERED', 'TRK-98721-IN')
ON CONFLICT (delivery_id) DO NOTHING;

INSERT INTO payment (payment_id, order_id, transaction_ref, payment_amount, payment_status) VALUES
('80000000-0000-0000-0000-000000000008', '50000000-0000-0000-0000-000000000005', 'pay_RzrP8871923', 1400.00, 'SUCCESS')
ON CONFLICT (payment_id) DO NOTHING;

-- 5. ML ENGINE INTERACTIONS & REVIEWS
INSERT INTO user_interaction (interaction_id, customer_id, listing_id, interaction_type, interaction_weight) VALUES
('90000000-0000-0000-0000-000000000009', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '30000000-0000-0000-0000-000000000003', 'PURCHASE', 5.0),
('a0000000-0000-0000-0000-00000000000a', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '40000000-0000-0000-0000-000000000004', 'PURCHASE', 5.0)
ON CONFLICT (interaction_id) DO NOTHING;

INSERT INTO customer_review (review_id, listing_id, customer_id, rating, comment) VALUES
('b0000000-0000-0000-0000-00000000000b', '30000000-0000-0000-0000-000000000003', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 5.0, 'Farm fresh grade A produce delivered directly!')
ON CONFLICT (review_id) DO NOTHING;

INSERT INTO notification (notification_id, user_id, title, message, is_read) VALUES
('c0000000-0000-0000-0000-00000000000c', '99999999-9999-9999-9999-999999999999', 'Order Delivered', 'Your order ORD-98721 has been delivered successfully.', true)
ON CONFLICT (notification_id) DO NOTHING;

-- 6. RUNTIME APPLICATION TABLES SEED
INSERT INTO public.categories (id, name, icon_name, description) VALUES
(1, 'Vegetables', 'eco', 'Fresh organic and farm-direct vegetables'),
(2, 'Fruits', 'apple', 'Fresh seasonal orchard fruits'),
(3, 'Grains & Pulses', 'grain', 'High quality wheat, rice, pulses'),
(4, 'Spices & Herbs', 'spa', 'Aromatic spices and fresh herbs'),
(5, 'Dairy & Honey', 'local_drink', 'Pure farm milk, ghee, and natural honey')
ON CONFLICT (id) DO NOTHING;

SELECT setval('public.categories_id_seq', (SELECT MAX(id) FROM public.categories));

INSERT INTO public.profiles (id, full_name, email, phone, user_role, location, latitude, longitude) VALUES
('11111111-1111-1111-1111-111111111111', 'Ramesh Kumar (Farmer)', 'ramesh.farmer@agrilink.com', '+919876543210', 'FARMER', 'Nashik, Maharashtra', 20.0059, 73.7898),
('22222222-2222-2222-2222-222222222222', 'Suresh Patel (Farmer)', 'suresh.farmer@agrilink.com', '+919876543211', 'FARMER', 'Anand, Gujarat', 22.5645, 72.9289),
('33333333-3333-3333-3333-333333333333', 'Anita Sharma (Organic Farm)', 'anita.farmer@agrilink.com', '+919876543212', 'FARMER', 'Shimla, Himachal Pradesh', 31.1048, 77.1734),
('44444444-4444-4444-4444-444444444444', 'Vikram Singh (Farmer)', 'vikram.farmer@agrilink.com', '+919876543213', 'FARMER', 'Ludhiana, Punjab', 30.9010, 75.8573),
('55555555-5555-5555-5555-555555555555', 'Priya Verma (Buyer)', 'priya.buyer@agrilink.com', '+919811122233', 'BUYER', 'Mumbai, Maharashtra', 19.0760, 72.8777)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.listings (id, farmer_id, farmer_name, title, crop_name, category_id, description, price_per_unit, unit, available_quantity, is_organic, grade, location, latitude, longitude, image_url, rating_avg, rating_count, status) VALUES
(101, '11111111-1111-1111-1111-111111111111', 'Ramesh Kumar', 'Fresh Red Tomatoes (Nashik Special)', 'Tomato', 1, 'Farm fresh grade A red juicy tomatoes harvested yesterday directly from Nashik farm fields.', 28.00, 'kg', 1500, true, 'A+', 'Nashik, Maharashtra', 20.0059, 73.7898, 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500', 4.8, 42, 'ACTIVE'),
(102, '11111111-1111-1111-1111-111111111111', 'Ramesh Kumar', 'Organic Red Onions', 'Onion', 1, 'High quality dried red onions stored in ventilated sheds.', 22.50, 'kg', 3000, true, 'A', 'Nashik, Maharashtra', 20.0059, 73.7898, 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cf?w=500', 4.6, 28, 'ACTIVE'),
(103, '22222222-2222-2222-2222-222222222222', 'Suresh Patel', 'Premium Sharbati Wheat', 'Wheat', 3, 'Golden grain Sharbati wheat cleaned and bagged in 50kg sacks.', 42.00, 'kg', 5000, false, 'A+', 'Anand, Gujarat', 22.5645, 72.9289, 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=500', 4.9, 56, 'ACTIVE'),
(105, '33333333-3333-3333-3333-333333333333', 'Anita Sharma', 'Shimla Royal Delicious Apples', 'Apple', 2, 'Juicy sweet crisp apples grown at high altitudes.', 120.00, 'kg', 1200, true, 'A+', 'Shimla, Himachal Pradesh', 31.1048, 77.1734, 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500', 4.95, 65, 'ACTIVE'),
(106, '33333333-3333-3333-3333-333333333333', 'Anita Sharma', 'Organic Himachal Honey', 'Honey', 5, 'Pure raw unfiltered wild forest honey packed in glass jars.', 380.00, 'kg', 250, true, 'A+', 'Shimla, Himachal Pradesh', 31.1048, 77.1734, 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=500', 5.0, 31, 'ACTIVE')
ON CONFLICT (id) DO NOTHING;

SELECT setval('public.listings_id_seq', (SELECT MAX(id) FROM public.listings));

INSERT INTO public.user_interactions (buyer_id, listing_id, interaction_type, interaction_weight, rating_value) VALUES
('55555555-5555-5555-5555-555555555555', 101, 'PURCHASE', 5.0, 5.0),
('55555555-5555-5555-5555-555555555555', 105, 'PURCHASE', 5.0, 4.5)
ON CONFLICT (id) DO NOTHING;
