-- ============================================================
-- 23_scenario_tomatoes_test.sql
-- PART 3: End-to-End AgriLink Core Scenario Test
-- Customer Orders 100 kg Tomatoes with Multi-Supplier Allocation Split
-- ============================================================

BEGIN;

DO $$
DECLARE
    v_role_farmer UUID;
    v_role_customer UUID;
    v_role_aggregator UUID;
    v_role_dp UUID;
    v_cat_veg UUID;
    v_crop_tomato UUID;
    
    -- Users & Parties
    v_u_fa UUID; v_p_fa UUID; v_farmer_a UUID; v_farm_a UUID; v_fc_a UUID; v_fs_a UUID;
    v_u_fb UUID; v_p_fb UUID; v_farmer_b UUID; v_farm_b UUID; v_fc_b UUID; v_fs_b UUID;
    v_u_fc UUID; v_p_fc UUID; v_farmer_c UUID; v_farm_c UUID; v_fc_c UUID;
    v_u_ag UUID; v_p_ag UUID; v_agg_a UUID;    v_wh_a UUID;   v_inv_ag UUID; v_fs_ag UUID;
    v_u_dp UUID; v_p_dp UUID; v_dp_a UUID;     v_veh_a UUID;
    v_u_cust UUID; v_p_cust UUID; v_cust_a UUID; v_addr_cust UUID;
    
    -- Order & Transactions
    v_order_id UUID;
    v_order_item_id UUID;
    v_deliv_id UUID;
    v_payment_id UUID;
    v_settle_id UUID;
    v_loc_id UUID;
BEGIN

    -- Get Role IDs
    SELECT role_id INTO v_role_farmer FROM role WHERE role_name = 'Farmer' LIMIT 1;
    SELECT role_id INTO v_role_customer FROM role WHERE role_name = 'Customer' LIMIT 1;
    SELECT role_id INTO v_role_aggregator FROM role WHERE role_name = 'Aggregator' LIMIT 1;
    SELECT role_id INTO v_role_dp FROM role WHERE role_name = 'Delivery Partner' LIMIT 1;

    -- Get Category & Crop
    SELECT category_id INTO v_cat_veg FROM crop_category WHERE category_name = 'Vegetables' LIMIT 1;
    
    INSERT INTO crop (crop_name, category_id, unit, is_perishable, is_active)
    VALUES ('Scenario Tomato', v_cat_veg, 'kg', true, true)
    RETURNING crop_id INTO v_crop_tomato;

    -- Location for farms & warehouse
    INSERT INTO location (address_line1, city, state, pincode, latitude, longitude)
    VALUES ('Kolar Highway Road', 'Kolar', 'Karnataka', '563101', 13.1367, 78.1292)
    RETURNING location_id INTO v_loc_id;

    --------------------------------------------------------------------
    -- SUPPLIER 1: Farmer A (40 kg @ ₹30/kg)
    --------------------------------------------------------------------
    INSERT INTO users (role_id, email, phone, password_hash, status)
    VALUES (v_role_farmer, 'farmer_a_scen@agrilink.com', '9000000010', 'hash10', 'Active') RETURNING user_id INTO v_u_fa;
    INSERT INTO party (user_id, party_type, kyc_status) VALUES (v_u_fa, 'Farmer', 'Approved') RETURNING party_id INTO v_p_fa;
    INSERT INTO farmer (party_id, farmer_code, is_verified) VALUES (v_p_fa, 'FARMER-A-SCEN', true) RETURNING farmer_id INTO v_farmer_a;
    INSERT INTO farm (farmer_id, location_id, farm_name, total_area) VALUES (v_farmer_a, v_loc_id, 'Farmer A Green Farm', 5.0) RETURNING farm_id INTO v_farm_a;
    INSERT INTO farmer_crop (farm_id, crop_id, variety, grade)
    VALUES (v_farm_a, v_crop_tomato, 'Roma', 'A') RETURNING farmer_crop_id INTO v_fc_a;

    --------------------------------------------------------------------
    -- SUPPLIER 2: Farmer B (30 kg @ ₹32/kg)
    --------------------------------------------------------------------
    INSERT INTO users (role_id, email, phone, password_hash, status)
    VALUES (v_role_farmer, 'farmer_b_scen@agrilink.com', '9000000011', 'hash11', 'Active') RETURNING user_id INTO v_u_fb;
    INSERT INTO party (user_id, party_type, kyc_status) VALUES (v_u_fb, 'Farmer', 'Approved') RETURNING party_id INTO v_p_fb;
    INSERT INTO farmer (party_id, farmer_code, is_verified) VALUES (v_p_fb, 'FARMER-B-SCEN', true) RETURNING farmer_id INTO v_farmer_b;
    INSERT INTO farm (farmer_id, location_id, farm_name, total_area) VALUES (v_farmer_b, v_loc_id, 'Farmer B Organic Farm', 4.0) RETURNING farm_id INTO v_farm_b;
    INSERT INTO farmer_crop (farm_id, crop_id, variety, grade)
    VALUES (v_farm_b, v_crop_tomato, 'Cherry', 'A') RETURNING farmer_crop_id INTO v_fc_b;

    --------------------------------------------------------------------
    -- SUPPLIER 3: Farmer C (Grew 100 kg @ ₹35/kg, procured by Aggregator A)
    --------------------------------------------------------------------
    INSERT INTO users (role_id, email, phone, password_hash, status)
    VALUES (v_role_farmer, 'farmer_c_scen@agrilink.com', '9000000012', 'hash12', 'Active') RETURNING user_id INTO v_u_fc;
    INSERT INTO party (user_id, party_type, kyc_status) VALUES (v_u_fc, 'Farmer', 'Approved') RETURNING party_id INTO v_p_fc;
    INSERT INTO farmer (party_id, farmer_code, is_verified) VALUES (v_p_fc, 'FARMER-C-SCEN', true) RETURNING farmer_id INTO v_farmer_c;
    INSERT INTO farm (farmer_id, location_id, farm_name, total_area) VALUES (v_farmer_c, v_loc_id, 'Farmer C Valley Farm', 10.0) RETURNING farm_id INTO v_farm_c;
    INSERT INTO farmer_crop (farm_id, crop_id, variety, grade)
    VALUES (v_farm_c, v_crop_tomato, 'Hybrid', 'A') RETURNING farmer_crop_id INTO v_fc_c;

    --------------------------------------------------------------------
    -- SUPPLIER 4: Aggregator A (Warehouse Inventory: 80 kg @ ₹34/kg)
    --------------------------------------------------------------------
    INSERT INTO users (role_id, email, phone, password_hash, status)
    VALUES (v_role_aggregator, 'aggr_a_scen@agrilink.com', '9000000013', 'hash13', 'Active') RETURNING user_id INTO v_u_ag;
    INSERT INTO party (user_id, party_type, gstin, kyc_status) VALUES (v_u_ag, 'Aggregator', '29ABCDE1234F1Z5', 'Approved') RETURNING party_id INTO v_p_ag;
    INSERT INTO aggregator (party_id, aggregator_code, business_name) VALUES (v_p_ag, 'AGG-A-SCEN', 'Kolar Fresh Aggregators') RETURNING aggregator_id INTO v_agg_a;
    INSERT INTO warehouse (aggregator_id, location_id, warehouse_name, total_capacity_kg, cold_storage) VALUES (v_agg_a, v_loc_id, 'Central Kolar Cold Storage', 5000.0, true) RETURNING warehouse_id INTO v_wh_a;
    
    -- Aggregator Batch
    INSERT INTO aggregator_inventory (warehouse_id, aggregator_id, farmer_id, farmer_crop_id, batch_no, quantity_kg, unit_cost_price, available_quantity_kg)
    VALUES (v_wh_a, v_agg_a, v_farmer_c, v_fc_c, 'BATCH-TOMATO-80KG', 80.0, 34.00, 80.0) RETURNING inventory_batch_id INTO v_inv_ag;

    --------------------------------------------------------------------
    -- DELIVERY PARTNER
    --------------------------------------------------------------------
    INSERT INTO users (role_id, email, phone, password_hash, status)
    VALUES (v_role_dp, 'dp_scen@agrilink.com', '9000000014', 'hash14', 'Active') RETURNING user_id INTO v_u_dp;
    INSERT INTO party (user_id, party_type, kyc_status) VALUES (v_u_dp, 'Delivery Partner', 'Approved') RETURNING party_id INTO v_p_dp;
    INSERT INTO delivery_partner (party_id, partner_code, is_active) VALUES (v_p_dp, 'DP-SCEN-999', true) RETURNING delivery_partner_id INTO v_dp_a;
    INSERT INTO vehicle (delivery_partner_id, vehicle_type, vehicle_no, capacity_kg) VALUES (v_dp_a, 'Pickup Truck', 'KA-07-SC-1234', 1000.0) RETURNING vehicle_id INTO v_veh_a;

    --------------------------------------------------------------------
    -- CUSTOMER & ORDER CREATION (100 kg Tomatoes @ ₹34/kg = ₹3,400)
    --------------------------------------------------------------------
    INSERT INTO users (role_id, email, phone, password_hash, status)
    VALUES (v_role_customer, 'cust_scen@agrilink.com', '9000000015', 'hash15', 'Active') RETURNING user_id INTO v_u_cust;
    INSERT INTO party (user_id, party_type, kyc_status) VALUES (v_u_cust, 'Customer', 'Approved') RETURNING party_id INTO v_p_cust;
    INSERT INTO customer (party_id) VALUES (v_p_cust) RETURNING customer_id INTO v_cust_a;
    INSERT INTO customer_address (customer_id, location_id, address_type, address_line1, city, state, pincode, is_default)
    VALUES (v_cust_a, v_loc_id, 'Home', '45/B MG Road', 'Bengaluru', 'Karnataka', '560001', true) RETURNING address_id INTO v_addr_cust;

    -- Order
    INSERT INTO orders (customer_id, order_status, total_amount, delivery_address_id, payment_status)
    VALUES (v_cust_a, 'Delivered', 3500.00, v_addr_cust, 'Paid') RETURNING order_id INTO v_order_id;

    -- Order Item: 100 kg Tomatoes @ ₹34/kg = ₹3,400
    INSERT INTO order_item (order_id, crop_id, quantity, unit_price, selected_type, subtotal)
    VALUES (v_order_id, v_crop_tomato, 100.0, 34.00, 'Farmer', 3400.00) RETURNING order_item_id INTO v_order_item_id;

    --------------------------------------------------------------------
    -- FULFILLMENT SOURCES & ALLOCATIONS (SPLIT: 40kg + 30kg + 30kg)
    --------------------------------------------------------------------
    -- Source 1: Farmer A (40 kg @ ₹30/kg)
    INSERT INTO fulfillment_source (source_type, source_name, farmer_id)
    VALUES ('Farmer', 'Farmer A Green Farm (Direct)', v_farmer_a) RETURNING fulfillment_source_id INTO v_fs_a;
    
    INSERT INTO order_allocation (order_item_id, fulfillment_source_id, source_type, source_id, allocated_quantity_kg, unit_price, subtotal, allocation_sequence)
    VALUES (v_order_item_id, v_fs_a, 'Direct', v_farmer_a, 40.0, 30.00, 1200.00, 1);

    -- Source 2: Farmer B (30 kg @ ₹32/kg)
    INSERT INTO fulfillment_source (source_type, source_name, farmer_id)
    VALUES ('Farmer', 'Farmer B Organic Farm (Direct)', v_farmer_b) RETURNING fulfillment_source_id INTO v_fs_b;
    
    INSERT INTO order_allocation (order_item_id, fulfillment_source_id, source_type, source_id, allocated_quantity_kg, unit_price, subtotal, allocation_sequence)
    VALUES (v_order_item_id, v_fs_b, 'Direct', v_farmer_b, 30.0, 32.00, 960.00, 2);

    -- Source 3: Aggregator A (30 kg from Warehouse inventory originally grown by Farmer C)
    INSERT INTO fulfillment_source (source_type, source_name, inventory_batch_id)
    VALUES ('Aggregator', 'Kolar Cold Storage (Aggregator Batch)', v_inv_ag) RETURNING fulfillment_source_id INTO v_fs_ag;
    
    INSERT INTO order_allocation (order_item_id, fulfillment_source_id, source_type, source_id, allocated_quantity_kg, unit_price, subtotal, allocation_sequence)
    VALUES (v_order_item_id, v_fs_ag, 'Warehouse', v_inv_ag, 30.0, 34.00, 1020.00, 3);

    --------------------------------------------------------------------
    -- DELIVERY, PAYMENT & SETTLEMENT SPLITS
    --------------------------------------------------------------------
    INSERT INTO delivery (order_id, delivery_type, delivery_status, delivery_charge)
    VALUES (v_order_id, 'Drop', 'Delivered', 100.00) RETURNING delivery_id INTO v_deliv_id;

    INSERT INTO delivery_assignment (delivery_id, delivery_partner_id, status, earning_amount)
    VALUES (v_deliv_id, v_dp_a, 'Delivered', 180.00);

    INSERT INTO payment (order_id, amount, payment_method, gateway_name, transaction_id, payment_status)
    VALUES (v_order_id, 3500.00, 'UPI', 'Razorpay', 'TXN-SCEN-100KG', 'Success') RETURNING payment_id INTO v_payment_id;

    INSERT INTO settlement (settlement_type, payment_id, status)
    VALUES ('Order Payout Split', v_payment_id, 'Processed') RETURNING settlement_id INTO v_settle_id;

    -- Payout Detail Splits
    INSERT INTO settlement_detail (settlement_id, entity_type, entity_id, percentage, amount, remarks)
    VALUES 
        (v_settle_id, 'Farmer', v_farmer_a, 34.29, 1200.00, 'Farmer A payout for 40 kg @ ₹30/kg'),
        (v_settle_id, 'Farmer', v_farmer_b, 27.43, 960.00, 'Farmer B payout for 30 kg @ ₹32/kg'),
        (v_settle_id, 'Aggregator', v_agg_a, 29.14, 1020.00, 'Aggregator A payout for 30 kg @ ₹34/kg'),
        (v_settle_id, 'Delivery', v_dp_a, 5.14, 180.00, 'Delivery partner earnings'),
        (v_settle_id, 'Platform', NULL, 4.00, 140.00, 'AgriLink platform commission (4%)');

END $$;

COMMIT;
