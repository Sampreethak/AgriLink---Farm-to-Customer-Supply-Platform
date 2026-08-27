-- AgriLink Seed Data: 100+ Records Across Key Database Tables

-- 1. SEED USERS & PARTIES (100 Users: Customers, Farmers, Aggregators)
DO $$
DECLARE
    i INT;
    u_id UUID;
    p_id UUID;
    c_id UUID;
    f_id UUID;
    a_id UUID;
    crop_ids UUID[];
    farm_ids UUID[];
    seller_listing_ids UUID[];
    party_types TEXT[] := ARRAY['customer', 'farmer', 'aggregator'];
    cust_types TEXT[] := ARRAY['individual', 'hostel_pg', 'hospital', 'restaurant', 'corporate'];
    districts TEXT[] := ARRAY['Kolar', 'Chickballapur', 'Bangalore Rural', 'Bangalore Urban', 'Ramanagara'];
    crop_names TEXT[] := ARRAY['Organic Red Tomato', 'Fresh Kolar Onion', 'Cold Storage Potato', 'Green Capsicum', 'Bangalore Fresh Carrot', 'Sweet Corn', 'Green Peas', 'Alphonso Mango', 'Shimla Red Apple', 'Desi Banana'];
BEGIN
    RAISE NOTICE 'Starting insertion of 100+ dummy records...';

    -- Insert 100 Users & Parties
    FOR i IN 1..105 LOOP
        u_id := gen_random_uuid();
        p_id := gen_random_uuid();

        INSERT INTO "users" (user_id, phone_number, password_hash, full_name, role, is_active, created_at)
        VALUES (
            u_id,
            '+9198' || LPAD(i::text, 8, '0'),
            '$2a$10$abcdefghijklmnopqrstuv', -- mock hash
            CASE 
                WHEN i <= 70 THEN 'Customer User ' || i
                WHEN i <= 95 THEN 'Farmer ' || (i - 70)
                ELSE 'Aggregator Hub ' || (i - 95)
            END,
            CASE 
                WHEN i <= 70 THEN 'CUSTOMER'
                WHEN i <= 95 THEN 'FARMER'
                ELSE 'AGGREGATOR'
            END,
            true,
            NOW() - (i || ' days')::INTERVAL
        );

        INSERT INTO "party" (party_id, user_id, party_type, address_line, district, state, pincode, created_at)
        VALUES (
            p_id,
            u_id,
            CASE 
                WHEN i <= 70 THEN 'CUSTOMER'
                WHEN i <= 95 THEN 'FARMER'
                ELSE 'AGGREGATOR'
            END,
            'House/Block #' || i || ', Main Agricultural Hub',
            districts[(i % 5) + 1],
            'Karnataka',
            '56310' || (i % 10)::text,
            NOW() - (i || ' days')::INTERVAL
        );

        -- Insert Role Specific Entities
        IF i <= 70 THEN
            INSERT INTO "customer" (customer_id, party_id, loyalty_points, created_at)
            VALUES (gen_random_uuid(), p_id, (i * 15), NOW() - (i || ' days')::INTERVAL);
        ELSIF i <= 95 THEN
            f_id := gen_random_uuid();
            INSERT INTO "farmer" (farmer_id, party_id, farmer_code, bio, kyc_status, is_verified, created_at)
            VALUES (f_id, p_id, 'FARM-' || (1000 + i), 'Experienced farmer specializing in fresh produce', 'Approved', true, NOW() - (i || ' days')::INTERVAL);
        ELSE
            a_id := gen_random_uuid();
            INSERT INTO "aggregator" (aggregator_id, party_id, aggregator_code, business_name, gstin, kyc_status, is_verified, created_at)
            VALUES (a_id, p_id, 'AGG-' || (1000 + i), 'Kolar Produce Aggregator #' || i, '29ABCDE' || (1000 + i) || '1Z5', 'Approved', true, NOW() - (i || ' days')::INTERVAL);
        END IF;
    END LOOP;

    RAISE NOTICE '100+ Users, Parties, Customers, Farmers, and Aggregators successfully inserted!';
END $$;

-- 2. SEED 100+ SELLER LISTINGS (Farmer & Aggregator Active Listings)
DO $$
DECLARE
    j INT;
    f_rec RECORD;
    c_rec RECORD;
    listing_id UUID;
    crop_names TEXT[] := ARRAY['Organic Red Tomato', 'Fresh Kolar Onion', 'Cold Storage Potato', 'Green Capsicum', 'Bangalore Fresh Carrot', 'Sweet Corn', 'Green Peas', 'Alphonso Mango', 'Shimla Red Apple', 'Desi Banana'];
    units TEXT[] := ARRAY['kg', 'kg', 'kg', 'kg', 'kg', 'kg', 'kg', 'dozen', 'kg', 'dozen'];
    prices NUMERIC[] := ARRAY[32.00, 28.00, 24.00, 45.00, 38.00, 20.00, 60.00, 150.00, 120.00, 40.00];
BEGIN
    j := 1;
    -- Loop through farmers and create listings
    FOR f_rec IN SELECT farmer_id FROM farmer LOOP
        FOR k IN 1..4 LOOP
            listing_id := gen_random_uuid();
            INSERT INTO "seller_listing" (
                listing_id, farmer_id, listing_title, crop_name, category, price_per_unit, unit, 
                stock_quantity, freshness_score, quality_grade, location_name, distance_km, 
                is_organic, is_active, created_at
            ) VALUES (
                listing_id,
                f_rec.farmer_id,
                'Fresh ' || crop_names[(j % 10) + 1] || ' Batch #' || j,
                crop_names[(j % 10) + 1],
                CASE WHEN (j % 10) in (7,8,9) THEN 'Fruits' ELSE 'Vegetables' END,
                prices[(j % 10) + 1] + (j % 5),
                units[(j % 10) + 1],
                500.00 + (j * 20),
                85.00 + (j % 14),
                CASE WHEN (j % 3) = 0 THEN 'Grade A+' WHEN (j % 3) = 1 THEN 'Grade A' ELSE 'Grade B' END,
                'Kolar Market Yard Hub',
                3.5 + (j % 12),
                (j % 2 = 0),
                true,
                NOW() - (j || ' hours')::INTERVAL
            );
            j := j + 1;
        END LOOP;
    END LOOP;

    RAISE NOTICE '100+ Seller Listings inserted successfully!';
END $$;
