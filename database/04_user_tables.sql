-- ============================================================
-- 04_user_tables.sql
-- User credentials and party profile tables
-- Tables: users, party
-- ============================================================

CREATE TABLE IF NOT EXISTS users (
    user_id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id         UUID        NOT NULL REFERENCES role(role_id) ON DELETE RESTRICT,
    email           VARCHAR(255) UNIQUE,
    phone           VARCHAR(20)  NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    status          VARCHAR(20)  DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive')),
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS party (
    party_id        UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID        NOT NULL UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    party_type      VARCHAR(30) NOT NULL CHECK (party_type IN ('Customer', 'Farmer', 'Aggregator', 'Delivery Partner', 'Admin')),
    gstin           VARCHAR(15) UNIQUE,
    kyc_status      VARCHAR(20) DEFAULT 'Pending' CHECK (kyc_status IN ('Pending', 'Approved', 'Rejected')),
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);
