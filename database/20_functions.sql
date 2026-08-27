-- ============================================================
-- 20_functions.sql
-- Stored procedure & helper functions
-- ============================================================

-- Stored Function: Reserve inventory for an order item
CREATE OR REPLACE FUNCTION reserve_inventory_batch(
    p_inventory_batch_id UUID,
    p_order_item_id UUID,
    p_quantity_kg NUMERIC(10, 2),
    p_minutes INT DEFAULT 30
)
RETURNS UUID AS $$
DECLARE
    v_available NUMERIC(10, 2);
    v_reservation_id UUID;
BEGIN
    SELECT available_quantity_kg INTO v_available
    FROM aggregator_inventory
    WHERE inventory_batch_id = p_inventory_batch_id
    FOR UPDATE;

    IF v_available IS NULL THEN
        RAISE EXCEPTION 'Inventory batch not found: %', p_inventory_batch_id;
    END IF;

    IF v_available < p_quantity_kg THEN
        RAISE EXCEPTION 'Insufficient stock. Requested: %, Available: %', p_quantity_kg, v_available;
    END IF;

    -- Update inventory batch
    UPDATE aggregator_inventory
    SET available_quantity_kg = available_quantity_kg - p_quantity_kg,
        reserved_quantity_kg = reserved_quantity_kg + p_quantity_kg
    WHERE inventory_batch_id = p_inventory_batch_id;

    -- Create reservation record
    v_reservation_id := gen_random_uuid();
    INSERT INTO inventory_reservation (
        reservation_id, inventory_batch_id, order_item_id,
        reserved_quantity_kg, reserved_until, status
    ) VALUES (
        v_reservation_id, p_inventory_batch_id, p_order_item_id,
        p_quantity_kg, NOW() + (p_minutes || ' minutes')::INTERVAL, 'Active'
    );

    RETURN v_reservation_id;
END;
$$ LANGUAGE plpgsql;

-- Stored Function: Get customer active cart total
CREATE OR REPLACE FUNCTION get_cart_total(p_customer_id UUID)
RETURNS NUMERIC(12, 2) AS $$
DECLARE
    v_total NUMERIC(12, 2);
BEGIN
    SELECT COALESCE(SUM(ci.quantity * ci.unit_price), 0.00) INTO v_total
    FROM cart c
    JOIN cart_item ci ON c.cart_id = ci.cart_id
    WHERE c.customer_id = p_customer_id;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;
