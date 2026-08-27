-- ============================================================
-- 10_quality_control.sql
-- Quality inspection records for inventory batches
-- Table: quality_check
-- Depends on: 09_inventory.sql (aggregator_inventory),
--             04_user.sql (users — inspector reference)
-- ============================================================

-- QUALITY_CHECK
-- Records the outcome of a quality inspection performed on an
-- inventory batch. Conducted by a verified QC officer (user).
-- Grade and status determine whether batch enters active inventory.
-- Business rules:
--  - qc_status = 'Passed' → batch becomes available for orders
--  - qc_status = 'Failed' → batch is quarantined/rejected
--  - A batch can have multiple inspections (e.g., re-inspection after rejection)
CREATE TABLE IF NOT EXISTS quality_check (
    qc_id               UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
    inventory_batch_id  UUID    NOT NULL REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE CASCADE,
    checked_by          UUID    REFERENCES users(user_id) ON DELETE SET NULL,
    quality_grade       VARCHAR(10) CHECK (quality_grade IN ('A', 'B', 'C')),
    qc_status           VARCHAR(20) DEFAULT 'Passed'
                            CHECK (qc_status IN ('Passed', 'Failed')),
    moisture_level_pct  DECIMAL(5, 2),          -- optional moisture % reading
    temperature_at_check DECIMAL(5, 2),          -- ambient temp during inspection (Celsius)
    remarks             TEXT,
    inspected_at        TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- INDEXES for quality_check
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_qc_batch_id ON quality_check(inventory_batch_id);
CREATE INDEX IF NOT EXISTS idx_qc_checked_by ON quality_check(checked_by);
CREATE INDEX IF NOT EXISTS idx_qc_status ON quality_check(qc_status);
CREATE INDEX IF NOT EXISTS idx_qc_grade ON quality_check(quality_grade);
CREATE INDEX IF NOT EXISTS idx_qc_inspected_at ON quality_check(inspected_at DESC);
