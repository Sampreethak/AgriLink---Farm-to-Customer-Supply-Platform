-- ============================================================
-- 17_indexes.sql
-- B-Tree, GIN full text search, and composite indexes across all tables
-- ============================================================

-- Search & lookup indexes
CREATE INDEX IF NOT EXISTS idx_crop_category_id ON crop(category_id);
CREATE INDEX IF NOT EXISTS idx_crop_name_search ON crop USING GIN (crop_name gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);
CREATE INDEX IF NOT EXISTS idx_party_user_id ON party(user_id);
CREATE INDEX IF NOT EXISTS idx_party_type ON party(party_type);

-- Farmer & Farm indexes
CREATE INDEX IF NOT EXISTS idx_farmer_party_id ON farmer(party_id);
CREATE INDEX IF NOT EXISTS idx_farm_farmer_id ON farm(farmer_id);
CREATE INDEX IF NOT EXISTS idx_farmer_crop_farm_id ON farmer_crop(farm_id);
CREATE INDEX IF NOT EXISTS idx_farmer_crop_crop_id ON farmer_crop(crop_id);

-- Aggregator & Inventory indexes
CREATE INDEX IF NOT EXISTS idx_warehouse_aggregator_id ON warehouse(aggregator_id);
CREATE INDEX IF NOT EXISTS idx_inventory_warehouse_id ON aggregator_inventory(warehouse_id);
CREATE INDEX IF NOT EXISTS idx_inventory_batch_no ON aggregator_inventory(batch_no);
CREATE INDEX IF NOT EXISTS idx_inventory_available ON aggregator_inventory(available_quantity_kg);

-- Order & Fulfillment indexes
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(order_status);
CREATE INDEX IF NOT EXISTS idx_orders_date ON orders(order_date DESC);
CREATE INDEX IF NOT EXISTS idx_order_item_order_id ON order_item(order_id);
CREATE INDEX IF NOT EXISTS idx_allocation_order_item_id ON order_allocation(order_item_id);
CREATE INDEX IF NOT EXISTS idx_tracking_order_id ON order_tracking(order_id);

-- Delivery & Logistics indexes
CREATE INDEX IF NOT EXISTS idx_delivery_order_id ON delivery(order_id);
CREATE INDEX IF NOT EXISTS idx_assignment_delivery_id ON delivery_assignment(delivery_id);
CREATE INDEX IF NOT EXISTS idx_assignment_partner_id ON delivery_assignment(delivery_partner_id);

-- Payment & Settlement indexes
CREATE INDEX IF NOT EXISTS idx_payment_order_id ON payment(order_id);
CREATE INDEX IF NOT EXISTS idx_payment_razorpay_order ON payment(razorpay_order_id);
CREATE INDEX IF NOT EXISTS idx_settlement_payment_id ON settlement(payment_id);
CREATE INDEX IF NOT EXISTS idx_settlement_detail_settlement_id ON settlement_detail(settlement_id);

-- Engagement & Notification indexes
CREATE INDEX IF NOT EXISTS idx_cart_customer_id ON cart(customer_id);
CREATE INDEX IF NOT EXISTS idx_wishlist_customer_id ON wishlist(customer_id);
CREATE INDEX IF NOT EXISTS idx_review_crop_id ON review(crop_id);
CREATE INDEX IF NOT EXISTS idx_notification_user_id ON notification(user_id);
CREATE INDEX IF NOT EXISTS idx_notification_unread ON notification(user_id, created_at DESC) WHERE is_read = 'N';

-- Pricing & ML predictions
CREATE INDEX IF NOT EXISTS idx_price_history_crop_id ON price_history(crop_id);
CREATE INDEX IF NOT EXISTS idx_ml_prediction_crop_id ON ml_price_prediction(crop_id);
