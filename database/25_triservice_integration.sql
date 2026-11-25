-- ============================================================
-- 25_triservice_integration.sql
-- ADDITIVE ONLY — no existing columns/tables are modified.
-- Adds tri-service correlation columns and audit table so
-- AgriLink (M1) can record links to Citizen Wallet (M2) and
-- RTO Fleet (M3) without breaking any existing FK or schema.
--
-- Safe to run multiple times (all statements are IF NOT EXISTS).
-- Usage: psql -d agrilink_db -f 25_triservice_integration.sql
-- ============================================================

\echo '>> [25] Tri-Service Integration Columns & Audit Tables...'

-- ── 1. orders: optional foreign-service correlation IDs ──────────────────────
-- These columns link an AgriLink order to a Citizen Wallet hold (M2)
-- and an RTO vehicle booking (M3).  Nullable → backward compatible.

ALTER TABLE orders ADD COLUMN IF NOT EXISTS
    citizen_id              VARCHAR(100)  NULL;

ALTER TABLE orders ADD COLUMN IF NOT EXISTS
    citizen_wallet_id       VARCHAR(100)  NULL;

ALTER TABLE orders ADD COLUMN IF NOT EXISTS
    citizen_wallet_hold_id  VARCHAR(100)  NULL;

ALTER TABLE orders ADD COLUMN IF NOT EXISTS
    rto_booking_ref         VARCHAR(100)  NULL;

ALTER TABLE orders ADD COLUMN IF NOT EXISTS
    rto_vehicle_id          VARCHAR(100)  NULL;

ALTER TABLE orders ADD COLUMN IF NOT EXISTS
    fair_share_settled      BOOLEAN       DEFAULT FALSE;

-- ── 2. delivery: vehicle class & assigned vehicle from RTO (M3) ──────────────
ALTER TABLE delivery ADD COLUMN IF NOT EXISTS
    rto_booking_ref         VARCHAR(100)  NULL;

ALTER TABLE delivery ADD COLUMN IF NOT EXISTS
    assigned_vehicle_reg    VARCHAR(30)   NULL;

ALTER TABLE delivery ADD COLUMN IF NOT EXISTS
    vehicle_class           VARCHAR(50)   NULL;

-- ── 3. settlement_detail: source_service tracking ────────────────────────────
ALTER TABLE settlement_detail ADD COLUMN IF NOT EXISTS
    source_service          VARCHAR(50)   NULL;   -- 'AGRILINK_M1' | 'CITIZEN_M2' | 'RTO_M3'

ALTER TABLE settlement_detail ADD COLUMN IF NOT EXISTS
    idempotency_key         VARCHAR(100)  NULL;

-- ── 4. inter_service_audit: central log of all cross-service REST calls ───────
CREATE TABLE IF NOT EXISTS inter_service_audit (
    audit_id            UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    source_service      VARCHAR(30)     NOT NULL,   -- 'AGRILINK_M1'
    target_service      VARCHAR(30)     NOT NULL,   -- 'CITIZEN_M2' | 'RTO_M3'
    operation           VARCHAR(80)     NOT NULL,   -- 'wallet_hold' | 'token_introspect' | 'vehicle_request' ...
    reference_id        VARCHAR(100),               -- order_id or job_ref
    citizen_id          VARCHAR(100),
    request_payload     JSONB,
    response_payload    JSONB,
    http_status         SMALLINT,
    connected           BOOLEAN         DEFAULT TRUE,
    fallback_used       BOOLEAN         DEFAULT FALSE,
    created_at          TIMESTAMPTZ     DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_isa_source_target ON inter_service_audit (source_service, target_service);
CREATE INDEX IF NOT EXISTS idx_isa_reference    ON inter_service_audit (reference_id);
CREATE INDEX IF NOT EXISTS idx_isa_created_at   ON inter_service_audit (created_at DESC);

-- ── 5. ecosystem_event_log: domain event log mirroring RTO outbox ─────────────
CREATE TABLE IF NOT EXISTS ecosystem_event_log (
    event_id            UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type          VARCHAR(80)     NOT NULL,  -- 'VehicleAssigned' | 'FundsHeld' | 'OrderPlaced' ...
    aggregate_type      VARCHAR(50),
    aggregate_id        VARCHAR(100),
    source_service      VARCHAR(30)     NOT NULL,
    payload             JSONB,
    published_at        TIMESTAMPTZ,
    consumed_at         TIMESTAMPTZ,
    created_at          TIMESTAMPTZ     DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_eel_event_type ON ecosystem_event_log (event_type);
CREATE INDEX IF NOT EXISTS idx_eel_source     ON ecosystem_event_log (source_service);

\echo '>> [25] Done. Tri-service correlation columns & audit tables created.'
