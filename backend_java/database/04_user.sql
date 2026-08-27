-- ============================================================
-- 04_user.sql
-- User credential and business profile tables
-- Tables: users, party
-- Depends on: 03_master_tables.sql (role)
-- ============================================================

-- 1. USERS
-- Core authentication table. All roles (farmer, customer, etc.)
-- have exactly one record here as their identity anchor.
CREATE TABLE IF NOT EXISTS users (
    user_id         UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_id         UUID        NOT NULL REFERENCES role(role_id) ON DELETE RESTRICT,
    email           VARCHAR(255) UNIQUE,
    phone           VARCHAR(20)  NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    status          VARCHAR(20)  DEFAULT 'Active'
                        CHECK (status IN ('Active', 'Inactive')),
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 2. PARTY
-- Extended business identity profile for each user.
-- Stores GSTIN, KYC status, and the role type classification.
-- One-to-one with users.
CREATE TABLE IF NOT EXISTS party (
    party_id    UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID        NOT NULL UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    party_type  VARCHAR(30) NOT NULL
                    CHECK (party_type IN ('Customer', 'Farmer', 'Aggregator', 'Delivery Partner', 'Admin')),
    gstin       VARCHAR(15) UNIQUE,
    kyc_status  VARCHAR(20) DEFAULT 'Pending'
                    CHECK (kyc_status IN ('Pending', 'Approved', 'Rejected')),
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- INDEXES for user tables
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);
CREATE INDEX IF NOT EXISTS idx_party_user_id ON party(user_id);
CREATE INDEX IF NOT EXISTS idx_party_type ON party(party_type);
CREATE INDEX IF NOT EXISTS idx_party_kyc_status ON party(kyc_status);
