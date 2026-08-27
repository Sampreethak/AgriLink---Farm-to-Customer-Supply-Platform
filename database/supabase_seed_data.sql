-- ==========================================================
-- AGRILINK SUPABASE SEED DATA
-- Insert realistic initial data for Farmers, Buyers, Categories,
-- Crop Listings, User Interactions (for ML training), Orders & Reviews.
-- ==========================================================

-- 1. Insert Categories
INSERT INTO public.categories (id, name, icon_name, description) VALUES
(1, 'Vegetables', 'eco', 'Fresh organic and farm-direct vegetables'),
(2, 'Fruits', 'apple', 'Fresh seasonal orchard fruits'),
(3, 'Grains & Pulses', 'grain', 'High quality wheat, rice, pulses and pulses'),
(4, 'Spices & Herbs', 'spa', 'Aromatic spices and fresh herbs'),
(5, 'Dairy & Honey', 'local_drink', 'Pure farm milk, ghee, and natural honey')
ON CONFLICT (id) DO NOTHING;

-- Reset identity sequence for categories
SELECT setval('public.categories_id_seq', (SELECT MAX(id) FROM public.categories));

-- 2. Insert Profiles (Farmers & Buyers)
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

-- 3. Insert Crop Listings
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

-- Reset identity sequence for listings
SELECT setval('public.listings_id_seq', (SELECT MAX(id) FROM public.listings));

-- 4. User Interaction Dataset (Implicit & Explicit feedback for LightFM Model)
INSERT INTO public.user_interactions (buyer_id, listing_id, interaction_type, interaction_weight, rating_value) VALUES
('55555555-5555-5555-5555-555555555555', 101, 'PURCHASE', 5.0, 5.0),
('55555555-5555-5555-5555-555555555555', 102, 'ADD_TO_CART', 3.0, NULL),
('55555555-5555-5555-5555-555555555555', 105, 'PURCHASE', 5.0, 4.5),
('55555555-5555-5555-5555-555555555555', 106, 'VIEW', 1.0, NULL),
('66666666-6666-6666-6666-666666666666', 101, 'PURCHASE', 5.0, 5.0),
('66666666-6666-6666-6666-666666666666', 103, 'PURCHASE', 5.0, 4.8),
('66666666-6666-6666-6666-666666666666', 107, 'PURCHASE', 5.0, 4.7),
('66666666-6666-6666-6666-666666666666', 104, 'VIEW', 1.0, NULL),
('77777777-7777-7777-7777-777777777777', 105, 'PURCHASE', 5.0, 5.0),
('77777777-7777-7777-7777-777777777777', 106, 'PURCHASE', 5.0, 5.0),
('77777777-7777-7777-7777-777777777777', 101, 'ADD_TO_CART', 3.0, NULL),
('88888888-8888-8888-8888-888888888888', 103, 'PURCHASE', 5.0, 5.0),
('88888888-8888-8888-8888-888888888888', 107, 'PURCHASE', 5.0, 4.9),
('88888888-8888-8888-8888-888888888888', 108, 'ADD_TO_CART', 3.0, NULL);

-- 5. Insert Sample Orders
INSERT INTO public.orders (id, buyer_id, total_amount, status, payment_method, payment_id, delivery_address) VALUES
('99999999-9999-9999-9999-999999999991', '55555555-5555-5555-5555-555555555555', 1400.00, 'DELIVERED', 'RAZORPAY', 'pay_Nzk1817263', 'Flat 402, Green Acres, Andheri West, Mumbai'),
('99999999-9999-9999-9999-999999999992', '66666666-6666-6666-6666-666666666666', 4200.00, 'PAID', 'RAZORPAY', 'pay_Nzk8819231', 'Grand Hotel Kitchen, FC Road, Pune');

-- 6. Insert Order Items
INSERT INTO public.order_items (order_id, listing_id, crop_name, quantity, unit_price, total_price) VALUES
('99999999-9999-9999-9999-999999999991', 101, 'Tomato', 50, 28.00, 1400.00),
('99999999-9999-9999-9999-999999999992', 103, 'Wheat', 100, 42.00, 4200.00);

-- 7. Insert Reviews
INSERT INTO public.reviews (listing_id, buyer_id, buyer_name, rating, comment) VALUES
(101, '55555555-5555-5555-5555-555555555555', 'Priya Verma', 5.0, 'Extremely fresh tomatoes! Arrived in perfect condition without any bruising.'),
(105, '77777777-7777-7777-7777-777777777777', 'Sneha Kapoor', 5.0, 'Best Shimla apples I have bought online. Super crisp and sweet!'),
(103, '88888888-8888-8888-8888-888888888888', 'Rajesh Joshi', 4.8, 'Grade A quality grain. Cleaned properly before packaging.');
