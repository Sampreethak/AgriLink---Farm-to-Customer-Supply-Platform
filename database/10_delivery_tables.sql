-- ============================================================
-- 10_delivery_tables.sql
-- Delivery partners, vehicles, delivery tasks, routing, proofs
-- Tables: delivery_partner, vehicle, delivery, delivery_assignment, delivery_route, delivery_proof
-- ============================================================

CREATE TABLE IF NOT EXISTS delivery_partner (
    delivery_partner_id UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    party_id            UUID        NOT NULL UNIQUE REFERENCES party(party_id) ON DELETE CASCADE,
    partner_code        VARCHAR(50) NOT NULL UNIQUE,
    rating              NUMERIC(3, 2) DEFAULT 0.00 CHECK (rating >= 0 AND rating <= 5.0),
    kyc_status          VARCHAR(20) DEFAULT 'Pending' CHECK (kyc_status IN ('Pending', 'Approved', 'Rejected')),
    bank_account_id     VARCHAR(100),
    is_active           BOOLEAN     DEFAULT TRUE,
    created_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS vehicle (
    vehicle_id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_partner_id UUID        NOT NULL REFERENCES delivery_partner(delivery_partner_id) ON DELETE CASCADE,
    vehicle_type        VARCHAR(50) NOT NULL,
    vehicle_no          VARCHAR(20) NOT NULL UNIQUE,
    capacity_kg         NUMERIC(10, 2) CHECK (capacity_kg > 0),
    current_load_kg     NUMERIC(10, 2) DEFAULT 0 CHECK (current_load_kg >= 0),
    registration_no     VARCHAR(30) UNIQUE,
    is_active           BOOLEAN     DEFAULT TRUE,
    CONSTRAINT chk_vehicle_load CHECK (current_load_kg <= capacity_kg)
);

CREATE TABLE IF NOT EXISTS delivery (
    delivery_id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id                UUID        NOT NULL UNIQUE REFERENCES orders(order_id) ON DELETE CASCADE,
    delivery_type           VARCHAR(20) CHECK (delivery_type IN ('Pickup', 'Drop', 'OnTheWay')),
    delivery_status         VARCHAR(30) DEFAULT 'Pending',
    pickup_address_id       UUID        REFERENCES location(location_id) ON DELETE SET NULL,
    delivery_address_id     UUID        REFERENCES customer_address(address_id) ON DELETE SET NULL,
    scheduled_delivery_date TIMESTAMPTZ,
    actual_delivery_date    TIMESTAMPTZ,
    delivery_charge         NUMERIC(10, 2) DEFAULT 0 CHECK (delivery_charge >= 0),
    created_at              TIMESTAMPTZ DEFAULT NOW(),
    updated_at              TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS delivery_assignment (
    assignment_id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_id             UUID        NOT NULL REFERENCES delivery(delivery_id) ON DELETE CASCADE,
    delivery_partner_id     UUID        NOT NULL REFERENCES delivery_partner(delivery_partner_id) ON DELETE RESTRICT,
    assigned_at             TIMESTAMPTZ DEFAULT NOW(),
    status                  VARCHAR(20) DEFAULT 'Assigned' CHECK (status IN ('Assigned', 'Accepted', 'PickedUp', 'InTransit', 'Delivered')),
    actual_delivery_time    TIMESTAMPTZ,
    earning_amount          NUMERIC(10, 2) DEFAULT 0 CHECK (earning_amount >= 0)
);

CREATE TABLE IF NOT EXISTS delivery_route (
    route_id            UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_id         UUID    NOT NULL REFERENCES delivery(delivery_id) ON DELETE CASCADE,
    sequence_no         INT     NOT NULL CHECK (sequence_no > 0),
    stop_location_id    UUID    NOT NULL REFERENCES location(location_id) ON DELETE RESTRICT,
    stop_type           VARCHAR(20) CHECK (stop_type IN ('Pickup', 'Drop')),
    estimated_time      VARCHAR(50),
    actual_time         TIMESTAMPTZ,
    UNIQUE (delivery_id, sequence_no)
);

CREATE TABLE IF NOT EXISTS delivery_proof (
    proof_id        UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_id     UUID    NOT NULL REFERENCES delivery(delivery_id) ON DELETE CASCADE,
    proof_type      VARCHAR(20) CHECK (proof_type IN ('Signature', 'OTP', 'Image')),
    otp_verified    VARCHAR(1) DEFAULT 'N' CHECK (otp_verified IN ('Y', 'N')),
    image_url       TEXT,
    gps_latitude    NUMERIC(10, 8),
    gps_longitude   NUMERIC(11, 8),
    remarks         TEXT,
    captured_at     TIMESTAMPTZ DEFAULT NOW()
);
