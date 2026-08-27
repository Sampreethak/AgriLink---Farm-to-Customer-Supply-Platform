-- ============================================================
-- 13_delivery.sql
-- Delivery partner registry, vehicles, assignments, routing, and proof
-- Tables: delivery_partner, vehicle, delivery, delivery_assignment,
--         delivery_route, delivery_proof
-- Depends on: 04_user.sql (party, users),
--             11_order.sql (orders),
--             05_customer.sql (customer_address),
--             03_master_tables.sql (location)
-- ============================================================

-- 1. DELIVERY_PARTNER
-- Registered delivery agent. Owns vehicles, assigned to deliveries.
-- Has own KYC, bank details, and rating system.
CREATE TABLE IF NOT EXISTS delivery_partner (
    delivery_partner_id UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    party_id            UUID        NOT NULL UNIQUE REFERENCES party(party_id) ON DELETE CASCADE,
    partner_code        VARCHAR(50) NOT NULL UNIQUE,
    rating              DECIMAL(3, 2) DEFAULT 0.00
                            CHECK (rating >= 0 AND rating <= 5.0),
    kyc_status          VARCHAR(20) DEFAULT 'Pending'
                            CHECK (kyc_status IN ('Pending', 'Approved', 'Rejected')),
    bank_account_id     VARCHAR(100),
    is_active           BOOLEAN     DEFAULT TRUE,
    created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- 2. VEHICLE
-- Delivery vehicle owned/operated by a delivery partner.
-- Tracks type, registration number, capacity, and current load.
CREATE TABLE IF NOT EXISTS vehicle (
    vehicle_id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    delivery_partner_id UUID        NOT NULL REFERENCES delivery_partner(delivery_partner_id) ON DELETE CASCADE,
    vehicle_type        VARCHAR(50) NOT NULL,   -- 'Motorcycle', 'Mini Truck', 'Tempo', 'Refrigerator Van'
    vehicle_no          VARCHAR(20) NOT NULL UNIQUE,
    capacity_kg         DECIMAL(10, 2) CHECK (capacity_kg > 0),
    current_load_kg     DECIMAL(10, 2) DEFAULT 0 CHECK (current_load_kg >= 0),
    registration_no     VARCHAR(30) UNIQUE,
    is_active           BOOLEAN     DEFAULT TRUE,
    CONSTRAINT chk_vehicle_load CHECK (current_load_kg <= capacity_kg)
);

-- 3. DELIVERY
-- The physical delivery task for an order.
-- Links an order to its logistics record. Tracks type, schedule, charges.
CREATE TABLE IF NOT EXISTS delivery (
    delivery_id             UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id                UUID        NOT NULL UNIQUE REFERENCES orders(order_id) ON DELETE CASCADE,
    delivery_type           VARCHAR(20) CHECK (delivery_type IN ('Pickup', 'Drop', 'OnTheWay')),
    delivery_status         VARCHAR(30) DEFAULT 'Pending',
    pickup_address_id       UUID        REFERENCES location(location_id) ON DELETE SET NULL,
    delivery_address_id     UUID        REFERENCES customer_address(address_id) ON DELETE SET NULL,
    scheduled_delivery_date TIMESTAMPTZ,
    actual_delivery_date    TIMESTAMPTZ,
    delivery_charge         DECIMAL(10, 2) DEFAULT 0 CHECK (delivery_charge >= 0),
    created_at              TIMESTAMPTZ DEFAULT NOW(),
    updated_at              TIMESTAMPTZ DEFAULT NOW()
);

-- 4. DELIVERY_ASSIGNMENT
-- Assigns a delivery partner to a specific delivery task.
-- Tracks acceptance status, actual delivery time, and earnings.
CREATE TABLE IF NOT EXISTS delivery_assignment (
    assignment_id           UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    delivery_id             UUID        NOT NULL REFERENCES delivery(delivery_id) ON DELETE CASCADE,
    delivery_partner_id     UUID        NOT NULL REFERENCES delivery_partner(delivery_partner_id) ON DELETE RESTRICT,
    assigned_at             TIMESTAMPTZ DEFAULT NOW(),
    status                  VARCHAR(20) DEFAULT 'Assigned'
                                CHECK (status IN ('Assigned', 'Accepted', 'PickedUp', 'InTransit', 'Delivered')),
    actual_delivery_time    TIMESTAMPTZ,
    earning_amount          DECIMAL(10, 2) DEFAULT 0 CHECK (earning_amount >= 0)
);

-- 5. DELIVERY_ROUTE
-- Ordered stop sequence for a delivery.
-- Each delivery has multiple stops (pickup → drops).
-- Business rules:
--  - sequence_no must be unique within a delivery
--  - stop_type = 'Pickup' then 'Drop'
CREATE TABLE IF NOT EXISTS delivery_route (
    route_id            UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
    delivery_id         UUID    NOT NULL REFERENCES delivery(delivery_id) ON DELETE CASCADE,
    sequence_no         INT     NOT NULL CHECK (sequence_no > 0),
    stop_location_id    UUID    NOT NULL REFERENCES location(location_id) ON DELETE RESTRICT,
    stop_type           VARCHAR(20) CHECK (stop_type IN ('Pickup', 'Drop')),
    estimated_time      VARCHAR(50),    -- e.g., '20 mins', '45 mins'
    actual_time         TIMESTAMPTZ,
    UNIQUE (delivery_id, sequence_no)
);

-- 6. DELIVERY_PROOF
-- Evidence record confirming a delivery was completed.
-- Supports OTP, photo, or signature as proof types.
CREATE TABLE IF NOT EXISTS delivery_proof (
    proof_id        UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
    delivery_id     UUID    NOT NULL REFERENCES delivery(delivery_id) ON DELETE CASCADE,
    proof_type      VARCHAR(20) CHECK (proof_type IN ('Signature', 'OTP', 'Image')),
    otp_verified    VARCHAR(1) DEFAULT 'N' CHECK (otp_verified IN ('Y', 'N')),
    image_url       TEXT,           -- Cloudinary URL for delivery photo
    gps_latitude    DECIMAL(10, 8),
    gps_longitude   DECIMAL(11, 8),
    remarks         TEXT,
    captured_at     TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- INDEXES for delivery tables
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_delivery_partner_party_id ON delivery_partner(party_id);
CREATE INDEX IF NOT EXISTS idx_delivery_partner_active ON delivery_partner(is_active);
CREATE INDEX IF NOT EXISTS idx_vehicle_partner_id ON vehicle(delivery_partner_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_no ON vehicle(vehicle_no);
CREATE INDEX IF NOT EXISTS idx_delivery_order_id ON delivery(order_id);
CREATE INDEX IF NOT EXISTS idx_delivery_status ON delivery(delivery_status);
CREATE INDEX IF NOT EXISTS idx_delivery_schedule ON delivery(scheduled_delivery_date);
CREATE INDEX IF NOT EXISTS idx_assignment_delivery_id ON delivery_assignment(delivery_id);
CREATE INDEX IF NOT EXISTS idx_assignment_partner_id ON delivery_assignment(delivery_partner_id);
CREATE INDEX IF NOT EXISTS idx_assignment_status ON delivery_assignment(status);
CREATE INDEX IF NOT EXISTS idx_route_delivery_id ON delivery_route(delivery_id);
CREATE INDEX IF NOT EXISTS idx_proof_delivery_id ON delivery_proof(delivery_id);
