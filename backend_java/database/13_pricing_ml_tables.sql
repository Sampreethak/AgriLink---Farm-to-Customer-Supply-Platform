-- ============================================================
-- 13_pricing_ml_tables.sql
-- Price history and ML crop price predictions
-- Tables: price_history, ml_price_prediction
-- ============================================================

CREATE TABLE IF NOT EXISTS price_history (
    price_history_id    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    crop_id             UUID        NOT NULL REFERENCES crop(crop_id) ON DELETE CASCADE,
    old_price           NUMERIC(10, 2) CHECK (old_price >= 0),
    new_price           NUMERIC(10, 2) NOT NULL CHECK (new_price >= 0),
    source              VARCHAR(30) CHECK (source IN ('Manual', 'Market', 'Demand', 'Prediction')),
    changed_by          UUID        REFERENCES users(user_id) ON DELETE SET NULL,
    effective_from      TIMESTAMPTZ DEFAULT NOW(),
    created_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ml_price_prediction (
    prediction_id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    crop_id                 UUID        NOT NULL REFERENCES crop(crop_id) ON DELETE CASCADE,
    predicted_price         NUMERIC(10, 2) NOT NULL CHECK (predicted_price >= 0),
    predicted_demand_kg     NUMERIC(12, 2),
    factors                 TEXT,
    confidence_score        NUMERIC(5, 4),
    model_version           VARCHAR(20),
    effective_from          TIMESTAMPTZ NOT NULL,
    effective_to            TIMESTAMPTZ NOT NULL,
    created_at              TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT chk_prediction_dates CHECK (effective_to > effective_from)
);
