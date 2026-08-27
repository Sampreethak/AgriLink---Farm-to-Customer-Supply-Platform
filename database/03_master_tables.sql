-- ============================================================
-- 03_master_tables.sql
-- Core lookup/reference tables
-- Tables: role, location, crop_category, crop
-- ============================================================

CREATE TABLE IF NOT EXISTS role (
    role_id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    role_name       VARCHAR(50) NOT NULL UNIQUE,
    role_description TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS location (
    location_id     UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    address_line1   VARCHAR(255) NOT NULL,
    address_line2   VARCHAR(255),
    city            VARCHAR(100) NOT NULL,
    state           VARCHAR(100) NOT NULL,
    pincode         VARCHAR(20)  NOT NULL,
    country         VARCHAR(100) DEFAULT 'India',
    latitude        NUMERIC(10, 8),
    longitude       NUMERIC(11, 8),
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS crop_category (
    category_id     UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    category_name   VARCHAR(100) NOT NULL UNIQUE,
    description     TEXT,
    is_active       BOOLEAN     DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS crop (
    crop_id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id     UUID        NOT NULL REFERENCES crop_category(category_id) ON DELETE RESTRICT,
    crop_name       VARCHAR(150) NOT NULL,
    description     TEXT,
    unit            VARCHAR(20)  NOT NULL,
    is_perishable   BOOLEAN     DEFAULT TRUE,
    is_active       BOOLEAN     DEFAULT TRUE
);
