-- ============================================================
-- 19_triggers.sql
-- Automated database triggers & trigger functions
-- ============================================================

-- Function: Auto update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply timestamp triggers to users, party, customer, order, delivery
DROP TRIGGER IF EXISTS trg_users_updated_at ON users;
CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS trg_party_updated_at ON party;
CREATE TRIGGER trg_party_updated_at
BEFORE UPDATE ON party
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS trg_orders_updated_at ON orders;
CREATE TRIGGER trg_orders_updated_at
BEFORE UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function: Auto record order tracking history on order status update
CREATE OR REPLACE FUNCTION log_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF (OLD.order_status IS DISTINCT FROM NEW.order_status) THEN
        INSERT INTO order_tracking (tracking_id, order_id, status, status_updated_at, remarks)
        VALUES (gen_random_uuid(), NEW.order_id, NEW.order_status, NOW(), 'Automated status log entry');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_order_status_tracking ON orders;
CREATE TRIGGER trg_order_status_tracking
AFTER UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION log_order_status_change();
