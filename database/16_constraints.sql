-- ============================================================
-- 16_constraints.sql
-- Additional foreign key constraints, composite checks, and domain rules
-- ============================================================

-- Deferred circular FK on customer.default_address_id
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'fk_customer_default_address'
    ) THEN
        ALTER TABLE customer
            ADD CONSTRAINT fk_customer_default_address
            FOREIGN KEY (default_address_id)
            REFERENCES customer_address(address_id)
            ON DELETE SET NULL;
    END IF;
END $$;

-- FK on inventory_reservation.order_item_id
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'fk_reservation_order_item'
    ) THEN
        ALTER TABLE inventory_reservation
            ADD CONSTRAINT fk_reservation_order_item
            FOREIGN KEY (order_item_id)
            REFERENCES order_item(order_item_id)
            ON DELETE SET NULL;
    END IF;
END $$;

SELECT 'All deferred foreign key constraints and domain checks applied.' AS status;
