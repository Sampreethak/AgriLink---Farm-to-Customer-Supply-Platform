-- AgriLink Enterprise Database Schema (47 Tables)
-- v2.0 - Generated based on the final ER Diagram

-- Enable UUID extension (PostgreSQL specific, SQLite handles UUIDs as text/strings)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- A. CORE / USER MANAGEMENT (Tables 1-6)
-- ==========================================

-- 1. ROLE
CREATE TABLE role (
    role_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_name VARCHAR(50) NOT NULL UNIQUE,
    role_description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. USER
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_id UUID NOT NULL REFERENCES role(role_id) ON DELETE RESTRICT,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    status VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. PARTY (Business Profile)
CREATE TABLE party (
    party_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    party_type VARCHAR(30) NOT NULL CHECK (party_type IN ('Customer', 'Farmer', 'Aggregator', 'Delivery Partner', 'Admin')),
    gstin VARCHAR(15) UNIQUE,
    kyc_status VARCHAR(20) DEFAULT 'Pending' CHECK (kyc_status IN ('Pending', 'Approved', 'Rejected')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. LOCATION (Created before CUSTOMER_ADDRESS due to FK dependency)
CREATE TABLE location (
    location_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    pincode VARCHAR(20) NOT NULL,
    country VARCHAR(100) DEFAULT 'India',
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. CUSTOMER_ADDRESS
CREATE TABLE customer_address (
    address_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL, -- references customer(customer_id) added via ALTER later to resolve circular reference
    location_id UUID NOT NULL REFERENCES location(location_id) ON DELETE RESTRICT,
    address_type VARCHAR(20) NOT NULL CHECK (address_type IN ('Home', 'Work', 'Other')),
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    landmark VARCHAR(150),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    pincode VARCHAR(20) NOT NULL,
    country VARCHAR(100) DEFAULT 'India',
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. CUSTOMER
CREATE TABLE customer (
    customer_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    party_id UUID NOT NULL UNIQUE REFERENCES party(party_id) ON DELETE CASCADE,
    loyalty_points INT DEFAULT 0,
    default_address_id UUID REFERENCES customer_address(address_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add the missing FK constraint to customer_address
ALTER TABLE customer_address ADD CONSTRAINT fk_customer_address_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE;


-- ==========================================
-- B. FARMER & FARM MANAGEMENT (Tables 7-11)
-- ==========================================

-- 7. FARMER
CREATE TABLE farmer (
    farmer_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    party_id UUID NOT NULL UNIQUE REFERENCES party(party_id) ON DELETE CASCADE,
    farmer_code VARCHAR(50) NOT NULL UNIQUE,
    bio TEXT,
    kyc_status VARCHAR(20) DEFAULT 'Pending',
    bank_account_id VARCHAR(100),
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. FARM
CREATE TABLE farm (
    farm_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farmer_id UUID NOT NULL REFERENCES farmer(farmer_id) ON DELETE CASCADE,
    farm_name VARCHAR(150) NOT NULL,
    total_area DECIMAL(10, 2) NOT NULL CHECK (total_area > 0),
    location_id UUID NOT NULL REFERENCES location(location_id) ON DELETE RESTRICT,
    description TEXT,
    organic_certified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. CROP_CATEGORY
CREATE TABLE crop_category (
    category_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE
);

-- 11. CROP
CREATE TABLE crop (
    crop_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID NOT NULL REFERENCES crop_category(category_id) ON DELETE RESTRICT,
    crop_name VARCHAR(150) NOT NULL,
    description TEXT,
    unit VARCHAR(20) NOT NULL, -- e.g., kg, bunch, bag
    is_perishable BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE
);

-- 9. FARMER_CROP (Harvest Batch)
CREATE TABLE farmer_crop (
    farmer_crop_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID NOT NULL REFERENCES farm(farm_id) ON DELETE CASCADE,
    crop_id UUID NOT NULL REFERENCES crop(crop_id) ON DELETE RESTRICT,
    variety VARCHAR(100),
    sowing_date DATE,
    expected_harvest_date DATE,
    organic_level VARCHAR(50),
    grade VARCHAR(10) CHECK (grade IN ('A', 'B', 'C')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);


-- ==========================================
-- C. AGGREGATOR & WAREHOUSE (Tables 12-17)
-- ==========================================

-- 12. AGGREGATOR
CREATE TABLE aggregator (
    aggregator_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    party_id UUID NOT NULL UNIQUE REFERENCES party(party_id) ON DELETE CASCADE,
    aggregator_code VARCHAR(50) NOT NULL UNIQUE,
    business_name VARCHAR(150) NOT NULL,
    gstin VARCHAR(15) UNIQUE,
    kyc_status VARCHAR(20) DEFAULT 'Pending',
    bank_account_id VARCHAR(100),
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 13. WAREHOUSE
CREATE TABLE warehouse (
    warehouse_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    aggregator_id UUID NOT NULL REFERENCES aggregator(aggregator_id) ON DELETE CASCADE,
    warehouse_name VARCHAR(150) NOT NULL,
    warehouse_type VARCHAR(50),
    location_id UUID NOT NULL REFERENCES location(location_id) ON DELETE RESTRICT,
    total_capacity_kg DECIMAL(12, 2) NOT NULL CHECK (total_capacity_kg > 0),
    occupied_capacity_kg DECIMAL(12, 2) DEFAULT 0 CHECK (occupied_capacity_kg >= 0),
    cold_storage BOOLEAN DEFAULT FALSE,
    temperature_min DECIMAL(5, 2),
    temperature_max DECIMAL(5, 2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 14. PROCUREMENT (Collection Receipt)
CREATE TABLE procurement (
    procurement_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farmer_id UUID NOT NULL REFERENCES farmer(farmer_id) ON DELETE RESTRICT,
    aggregator_id UUID NOT NULL REFERENCES aggregator(aggregator_id) ON DELETE RESTRICT,
    farmer_crop_id UUID NOT NULL REFERENCES farmer_crop(farmer_crop_id) ON DELETE RESTRICT,
    quantity_kg DECIMAL(10, 2) NOT NULL CHECK (quantity_kg > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price > 0),
    total_price DECIMAL(12, 2) NOT NULL,
    procurement_date TIMESTAMPTZ DEFAULT NOW(),
    quality_status VARCHAR(20) DEFAULT 'Pending' CHECK (quality_status IN ('Pending', 'Passed', 'Failed')),
    payment_status VARCHAR(20) DEFAULT 'Pending' CHECK (payment_status IN ('Pending', 'Paid', 'Failed')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 15. AGGREGATOR_INVENTORY (Batch)
CREATE TABLE aggregator_inventory (
    inventory_batch_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    warehouse_id UUID NOT NULL REFERENCES warehouse(warehouse_id) ON DELETE CASCADE,
    farmer_id UUID REFERENCES farmer(farmer_id) ON DELETE SET NULL, -- Original Owner
    farmer_crop_id UUID REFERENCES farmer_crop(farmer_crop_id) ON DELETE SET NULL,
    batch_no VARCHAR(50) NOT NULL UNIQUE,
    quantity_kg DECIMAL(10, 2) NOT NULL CHECK (quantity_kg >= 0),
    unit_cost_price DECIMAL(10, 2) NOT NULL CHECK (unit_cost_price > 0),
    available_quantity_kg DECIMAL(10, 2) NOT NULL CHECK (available_quantity_kg >= 0),
    reserved_quantity_kg DECIMAL(10, 2) DEFAULT 0 CHECK (reserved_quantity_kg >= 0),
    quality_status VARCHAR(20) DEFAULT 'Passed',
    expiry_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 16. INVENTORY_RESERVATION
CREATE TABLE inventory_reservation (
    reservation_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    inventory_batch_id UUID NOT NULL REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE CASCADE,
    reserved_quantity_kg DECIMAL(10, 2) NOT NULL CHECK (reserved_quantity_kg > 0),
    reserved_until TIMESTAMPTZ NOT NULL,
    status VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'Expired', 'Used')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 17. QUALITY_CHECK
CREATE TABLE quality_check (
    qc_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    inventory_batch_id UUID NOT NULL REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE CASCADE,
    checked_by UUID REFERENCES users(user_id) ON DELETE SET NULL,
    quality_grade VARCHAR(10) CHECK (quality_grade IN ('A', 'B', 'C')),
    qc_status VARCHAR(20) DEFAULT 'Passed' CHECK (qc_status IN ('Passed', 'Failed')),
    remarks TEXT
);


-- ==========================================
-- D. ORDER & FULFILLMENT (Tables 18-22)
-- ==========================================

-- 19. ORDER
CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES customer(customer_id) ON DELETE RESTRICT,
    order_date TIMESTAMPTZ DEFAULT NOW(),
    order_status VARCHAR(30) DEFAULT 'Placed' CHECK (order_status IN ('Placed', 'Confirmed', 'Processing', 'OutForDelivery', 'Delivered', 'Cancelled')),
    total_amount DECIMAL(12, 2) NOT NULL CHECK (total_amount >= 0),
    delivery_address_id UUID REFERENCES customer_address(address_id) ON DELETE RESTRICT,
    payment_status VARCHAR(20) DEFAULT 'Pending' CHECK (payment_status IN ('Pending', 'Paid', 'Failed', 'Refunded')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 20. ORDER_ITEM
CREATE TABLE order_item (
    order_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    crop_id UUID NOT NULL REFERENCES crop(crop_id) ON DELETE RESTRICT,
    quantity DECIMAL(10, 2) NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price > 0),
    selected_type VARCHAR(20) CHECK (selected_type IN ('Farmer', 'Aggregator')),
    subtotal DECIMAL(12, 2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 22. FULFILLMENT_SOURCE
CREATE TABLE fulfillment_source (
    fulfillment_source_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_type VARCHAR(20) NOT NULL CHECK (source_type IN ('Farmer', 'Aggregator')),
    source_name VARCHAR(150),
    farmer_id UUID REFERENCES farmer(farmer_id) ON DELETE SET NULL,
    inventory_batch_id UUID REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE SET NULL
);

-- 21. ORDER_ALLOCATION (Split Allocation)
CREATE TABLE order_allocation (
    allocation_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_item_id UUID NOT NULL REFERENCES order_item(order_item_id) ON DELETE CASCADE,
    fulfillment_source_id UUID NOT NULL REFERENCES fulfillment_source(fulfillment_source_id) ON DELETE RESTRICT,
    source_type VARCHAR(20) NOT NULL CHECK (source_type IN ('Direct', 'Warehouse')),
    source_id UUID NOT NULL, -- references farmer_crop_id or inventory_batch_id
    allocated_quantity_kg DECIMAL(10, 2) NOT NULL CHECK (allocated_quantity_kg > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price > 0),
    subtotal DECIMAL(12, 2) NOT NULL,
    allocation_sequence INT DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 18. ORDER_TRACKING
CREATE TABLE order_tracking (
    tracking_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    status VARCHAR(30) NOT NULL,
    status_updated_at TIMESTAMPTZ DEFAULT NOW(),
    location_id UUID REFERENCES location(location_id) ON DELETE RESTRICT,
    remarks TEXT
);


-- ==========================================
-- E. DELIVERY MANAGEMENT (Tables 23-28)
-- ==========================================

-- 23. DELIVERY
CREATE TABLE delivery (
    delivery_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    delivery_type VARCHAR(20) CHECK (delivery_type IN ('Pickup', 'Drop', 'OnTheWay')),
    delivery_status VARCHAR(30) DEFAULT 'Pending',
    pickup_address_id UUID REFERENCES location(location_id) ON DELETE RESTRICT,
    delivery_address_id UUID REFERENCES customer_address(address_id) ON DELETE RESTRICT,
    scheduled_delivery_date TIMESTAMPTZ,
    actual_delivery_date TIMESTAMPTZ,
    delivery_charge DECIMAL(10, 2) DEFAULT 0 CHECK (delivery_charge >= 0),
    status VARCHAR(20) DEFAULT 'Active',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 25. DELIVERY_PARTNER
CREATE TABLE delivery_partner (
    delivery_partner_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    party_id UUID NOT NULL UNIQUE REFERENCES party(party_id) ON DELETE CASCADE,
    partner_code VARCHAR(50) NOT NULL UNIQUE,
    rating DECIMAL(3, 2) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5.0),
    kyc_status VARCHAR(20) DEFAULT 'Pending',
    bank_account_id VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 24. DELIVERY_ASSIGNMENT
CREATE TABLE delivery_assignment (
    assignment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    delivery_id UUID NOT NULL REFERENCES delivery(delivery_id) ON DELETE CASCADE,
    delivery_partner_id UUID NOT NULL REFERENCES delivery_partner(delivery_partner_id) ON DELETE RESTRICT,
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'Assigned' CHECK (status IN ('Assigned', 'Accepted', 'PickedUp', 'InTransit', 'Delivered')),
    actual_delivery_time TIMESTAMPTZ,
    earning_amount DECIMAL(10, 2) DEFAULT 0 CHECK (earning_amount >= 0)
);

-- 26. VEHICLE
CREATE TABLE vehicle (
    vehicle_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    delivery_partner_id UUID NOT NULL REFERENCES delivery_partner(delivery_partner_id) ON DELETE CASCADE,
    vehicle_type VARCHAR(50) NOT NULL,
    vehicle_no VARCHAR(20) NOT NULL UNIQUE,
    capacity_kg DECIMAL(10, 2) CHECK (capacity_kg > 0),
    current_load_kg DECIMAL(10, 2) DEFAULT 0 CHECK (current_load_kg >= 0),
    is_active BOOLEAN DEFAULT TRUE
);

-- 27. DELIVERY_ROUTE
CREATE TABLE delivery_route (
    route_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    delivery_id UUID NOT NULL REFERENCES delivery(delivery_id) ON DELETE CASCADE,
    sequence_no INT NOT NULL,
    stop_location_id UUID NOT NULL REFERENCES location(location_id) ON DELETE RESTRICT,
    stop_type VARCHAR(20) CHECK (stop_type IN ('Pickup', 'Drop')),
    estimated_time INTERVAL,
    actual_time TIMESTAMPTZ
);

-- 28. DELIVERY_PROOF
CREATE TABLE delivery_proof (
    proof_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    delivery_id UUID NOT NULL REFERENCES delivery(delivery_id) ON DELETE CASCADE,
    proof_type VARCHAR(20) CHECK (proof_type IN ('Signature', 'OTP', 'Image')),
    otp_verified VARCHAR(1) DEFAULT 'N' CHECK (otp_verified IN ('Y', 'N')),
    gps_latitude DECIMAL(10, 8),
    gps_longitude DECIMAL(11, 8),
    remarks TEXT
);


-- ==========================================
-- F. PAYMENT & SETTLEMENT (Tables 29-31)
-- ==========================================

-- 29. PAYMENT
CREATE TABLE payment (
    payment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    amount DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR(30) CHECK (payment_method IN ('COD', 'UPI', 'Card', 'NetBanking')),
    gateway_name VARCHAR(50),
    transaction_id VARCHAR(100),
    payment_date TIMESTAMPTZ DEFAULT NOW(),
    payment_status VARCHAR(20) DEFAULT 'Pending' CHECK (payment_status IN ('Success', 'Failed', 'Pending'))
);

-- 30. SETTLEMENT
CREATE TABLE settlement (
    settlement_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    settlement_type VARCHAR(50),
    payment_id UUID NOT NULL REFERENCES payment(payment_id) ON DELETE RESTRICT,
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Processed', 'Failed')),
    settlement_date TIMESTAMPTZ
);

-- 31. SETTLEMENT_DETAIL
CREATE TABLE settlement_detail (
    detail_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    settlement_id UUID NOT NULL REFERENCES settlement(settlement_id) ON DELETE CASCADE,
    entity_type VARCHAR(30) CHECK (entity_type IN ('Farmer', 'Aggregator', 'Delivery', 'Platform', 'GST')),
    percentage DECIMAL(5, 2) CHECK (percentage >= 0 AND percentage <= 100.0),
    amount DECIMAL(12, 2) NOT NULL CHECK (amount >= 0),
    remarks TEXT
);


-- ==========================================
-- G. CUSTOMER ENGAGEMENT (Tables 32-37)
-- ==========================================

-- 32. CART
CREATE TABLE cart (
    cart_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 33. CART_ITEM
CREATE TABLE cart_item (
    cart_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cart_id UUID NOT NULL REFERENCES cart(cart_id) ON DELETE CASCADE,
    crop_id UUID NOT NULL REFERENCES crop(crop_id) ON DELETE CASCADE,
    quantity DECIMAL(10, 2) NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price > 0)
);

-- 34. WISHLIST
CREATE TABLE wishlist (
    wishlist_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    crop_id UUID NOT NULL REFERENCES crop(crop_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 35. REVIEW
CREATE TABLE review (
    review_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    crop_id UUID NOT NULL REFERENCES crop(crop_id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customer(customer_id) ON DELETE RESTRICT,
    farmer_id UUID REFERENCES farmer(farmer_id) ON DELETE CASCADE,
    aggregator_id UUID REFERENCES aggregator(aggregator_id) ON DELETE CASCADE,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_date TIMESTAMPTZ DEFAULT NOW()
);

-- 36. COUPON
CREATE TABLE coupon (
    coupon_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coupon_code VARCHAR(30) NOT NULL UNIQUE,
    discount_type VARCHAR(20) CHECK (discount_type IN ('Fixed', 'Percent')),
    discount_value DECIMAL(10, 2) NOT NULL CHECK (discount_value > 0),
    min_order_amount DECIMAL(10, 2) DEFAULT 0 CHECK (min_order_amount >= 0),
    valid_from TIMESTAMPTZ DEFAULT NOW(),
    valid_to TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE
);

-- 37. COUPON_USAGE
CREATE TABLE coupon_usage (
    usage_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coupon_id UUID NOT NULL REFERENCES coupon(coupon_id) ON DELETE RESTRICT,
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    used_at TIMESTAMPTZ DEFAULT NOW(),
    discount_amount DECIMAL(10, 2) NOT NULL CHECK (discount_amount >= 0)
);


-- ==========================================
-- H. SYSTEM SUPPORT & COMMUNICATION (Tables 38-39)
-- ==========================================

-- 38. NOTIFICATION
CREATE TABLE notification (
    notification_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    is_read VARCHAR(1) DEFAULT 'N' CHECK (is_read IN ('Y', 'N')),
    is_delivered VARCHAR(1) DEFAULT 'N' CHECK (is_delivered IN ('Y', 'N')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 39. NOTIFICATION_STATUS
CREATE TABLE notification_status (
    status_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    notification_id UUID NOT NULL REFERENCES notification(notification_id) ON DELETE CASCADE,
    device_id VARCHAR(255),
    read_at TIMESTAMPTZ,
    status VARCHAR(20) CHECK (status IN ('Sent', 'Delivered', 'Read', 'Failed'))
);


-- ==========================================
-- I. PRICE & ANALYTICS (Tables 40-41)
-- ==========================================

-- 40. PRICE_HISTORY
CREATE TABLE price_history (
    price_history_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    crop_id UUID NOT NULL REFERENCES crop(crop_id) ON DELETE CASCADE,
    old_price DECIMAL(10, 2) CHECK (old_price >= 0),
    new_price DECIMAL(10, 2) NOT NULL CHECK (new_price >= 0),
    source VARCHAR(30) CHECK (source IN ('Manual', 'Market', 'Demand', 'Prediction')),
    effective_from TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 41. ML_PRICE_PREDICTION
CREATE TABLE ml_price_prediction (
    prediction_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    crop_id UUID NOT NULL REFERENCES crop(crop_id) ON DELETE CASCADE,
    predicted_price DECIMAL(10, 2) NOT NULL CHECK (predicted_price >= 0),
    factors TEXT, -- Season/Market/Demand/Weather/Festival
    effective_from TIMESTAMPTZ NOT NULL,
    effective_to TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);


-- ==========================================
-- J. RETURNS & REFUNDS (Tables 42-44)
-- ==========================================

-- 42. RETURNS
CREATE TABLE returns (
    return_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE RESTRICT,
    return_date TIMESTAMPTZ DEFAULT NOW(),
    reason TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'Requested' CHECK (status IN ('Requested', 'Approved', 'Rejected', 'Completed'))
);

-- 43. RETURN_ITEM
CREATE TABLE return_item (
    return_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    return_id UUID NOT NULL REFERENCES returns(return_id) ON DELETE CASCADE,
    order_item_id UUID NOT NULL REFERENCES order_item(order_item_id) ON DELETE RESTRICT,
    quantity DECIMAL(10, 2) NOT NULL CHECK (quantity > 0),
    refund_amount DECIMAL(12, 2) NOT NULL CHECK (refund_amount >= 0)
);

-- 44. REFUND
CREATE TABLE refund (
    refund_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    return_id UUID NOT NULL REFERENCES returns(return_id) ON DELETE CASCADE,
    amount DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    refund_method VARCHAR(30),
    status VARCHAR(20) DEFAULT 'Pending',
    refund_date TIMESTAMPTZ,
    transaction_id VARCHAR(100)
);


-- ==========================================
-- K. INVENTORY MOVEMENT & ADJUSTMENT (Tables 45-47)
-- ==========================================

-- 45. INVENTORY_MOVEMENT (Ledger)
CREATE TABLE inventory_movement (
    movement_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    inventory_batch_id UUID NOT NULL REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE RESTRICT,
    movement_type VARCHAR(20) NOT NULL CHECK (movement_type IN ('IN', 'OUT', 'RESERVED', 'RELEASED', 'HOLD', 'RETURNED', 'ADJUSTMENT', 'DAMAGED', 'EXPIRED')),
    quantity_kg DECIMAL(10, 2) NOT NULL,
    reference_type VARCHAR(50), -- Order, Procurement, Adjustment
    reference_id UUID,
    performed_by UUID REFERENCES users(user_id) ON DELETE SET NULL,
    movement_date TIMESTAMPTZ DEFAULT NOW()
);

-- 46. INVENTORY_ADJUSTMENT
CREATE TABLE inventory_adjustment (
    adjustment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    inventory_batch_id UUID NOT NULL REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE RESTRICT,
    adjustment_type VARCHAR(30) NOT NULL CHECK (adjustment_type IN ('Damage', 'Spoilage', 'Expiry', 'Manual Correction', 'Theft', 'Other')),
    quantity_kg DECIMAL(10, 2) NOT NULL CHECK (quantity_kg > 0),
    reason TEXT,
    performed_by UUID REFERENCES users(user_id) ON DELETE SET NULL,
    approved_by UUID REFERENCES users(user_id) ON DELETE SET NULL,
    remarks TEXT
);

-- 47. BATCH_EXPIRY_ALERT
CREATE TABLE batch_expiry_alert (
    alert_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    inventory_batch_id UUID NOT NULL REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE CASCADE,
    alert_type VARCHAR(30) CHECK (alert_type IN ('Expiring Soon', 'Expired')),
    alert_time TIMESTAMPTZ DEFAULT NOW(),
    notified_to UUID REFERENCES users(user_id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'Unread' CHECK (status IN ('Unread', 'Read'))
);


-- ==========================================
-- INDEXES FOR PERFORMANCE
-- ==========================================
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_party_user ON party(user_id);
CREATE INDEX idx_customer_party ON customer(party_id);
CREATE INDEX idx_farmer_party ON farmer(party_id);
CREATE INDEX idx_farm_farmer ON farm(farmer_id);
CREATE INDEX idx_farmer_crop_farm ON farmer_crop(farm_id);
CREATE INDEX idx_crop_category ON crop(category_id);
CREATE INDEX idx_aggregator_party ON aggregator(party_id);
CREATE INDEX idx_warehouse_aggregator ON warehouse(aggregator_id);
CREATE INDEX idx_procurement_farmer ON procurement(farmer_id);
CREATE INDEX idx_procurement_aggregator ON procurement(aggregator_id);
CREATE INDEX idx_aggregator_inventory_warehouse ON aggregator_inventory(warehouse_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_order_item_order ON order_item(order_id);
CREATE INDEX idx_delivery_order ON delivery(order_id);
CREATE INDEX idx_delivery_assignment_delivery ON delivery_assignment(delivery_id);
CREATE INDEX idx_vehicle_partner ON vehicle(delivery_partner_id);
CREATE INDEX idx_payment_order ON payment(order_id);
CREATE INDEX idx_settlement_payment ON settlement(payment_id);
CREATE INDEX idx_settlement_detail_settlement ON settlement_detail(settlement_id);
CREATE INDEX idx_cart_customer ON cart(customer_id);
CREATE INDEX idx_cart_item_cart ON cart_item(cart_id);
CREATE INDEX idx_review_crop ON review(crop_id);
CREATE INDEX idx_price_history_crop ON price_history(crop_id);
CREATE INDEX idx_ml_prediction_crop ON ml_price_prediction(crop_id);
CREATE INDEX idx_returns_order ON returns(order_id);
CREATE INDEX idx_inventory_movement_batch ON inventory_movement(inventory_batch_id);
