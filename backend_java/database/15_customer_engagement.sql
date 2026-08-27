-- ============================================================
-- 15_customer_engagement.sql
-- Customer engagement: carts, wishlists, reviews, and coupons
-- Tables: cart, cart_item, wishlist, review, coupon, coupon_usage
-- Depends on: 05_customer.sql (customer),
--             03_master_tables.sql (crop),
--             11_order.sql (orders),
--             06_farmer.sql (farmer),
--             07_aggregator.sql (aggregator)
-- ============================================================

-- 1. CART
-- A persistent shopping basket for each customer.
-- One active cart per customer at a time.
CREATE TABLE IF NOT EXISTS cart (
    cart_id         UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id     UUID    NOT NULL UNIQUE REFERENCES customer(customer_id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 2. CART_ITEM
-- Individual item in a cart with crop and quantity/price snapshot.
-- Price is captured at time of adding to avoid stale prices.
CREATE TABLE IF NOT EXISTS cart_item (
    cart_item_id    UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
    cart_id         UUID    NOT NULL REFERENCES cart(cart_id) ON DELETE CASCADE,
    crop_id         UUID    NOT NULL REFERENCES crop(crop_id) ON DELETE CASCADE,
    quantity        DECIMAL(10, 2) NOT NULL CHECK (quantity > 0),
    unit_price      DECIMAL(10, 2) NOT NULL CHECK (unit_price > 0),
    added_at        TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (cart_id, crop_id)   -- Only one entry per crop per cart
);

-- 3. WISHLIST
-- Customer's saved/bookmarked crops for future purchasing.
CREATE TABLE IF NOT EXISTS wishlist (
    wishlist_id     UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id     UUID    NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    crop_id         UUID    NOT NULL REFERENCES crop(crop_id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (customer_id, crop_id)
);

-- 4. REVIEW
-- Customer feedback on a crop after purchase.
-- Optionally tagged to the supplying farmer or aggregator.
-- Business rules:
--  - rating must be 1–5
--  - A review is valid only if customer purchased the crop
CREATE TABLE IF NOT EXISTS review (
    review_id       UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
    crop_id         UUID    NOT NULL REFERENCES crop(crop_id) ON DELETE CASCADE,
    customer_id     UUID    NOT NULL REFERENCES customer(customer_id) ON DELETE RESTRICT,
    farmer_id       UUID    REFERENCES farmer(farmer_id) ON DELETE CASCADE,
    aggregator_id   UUID    REFERENCES aggregator(aggregator_id) ON DELETE CASCADE,
    rating          INT     NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text     TEXT,
    review_date     TIMESTAMPTZ DEFAULT NOW()
);

-- 5. COUPON
-- Promotional discount coupons.
-- Business rules:
--  - discount_type: 'Fixed' = rupee off, 'Percent' = percentage off
--  - min_order_amount: minimum cart value to apply coupon
--  - valid_to NULL = no expiry
CREATE TABLE IF NOT EXISTS coupon (
    coupon_id       UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    coupon_code     VARCHAR(30) NOT NULL UNIQUE,
    discount_type   VARCHAR(20) CHECK (discount_type IN ('Fixed', 'Percent')),
    discount_value  DECIMAL(10, 2) NOT NULL CHECK (discount_value > 0),
    min_order_amount DECIMAL(10, 2) DEFAULT 0 CHECK (min_order_amount >= 0),
    max_discount_amount DECIMAL(10, 2),     -- Cap for percentage-type coupons
    usage_limit     INT,                    -- NULL = unlimited
    used_count      INT         DEFAULT 0,
    valid_from      TIMESTAMPTZ DEFAULT NOW(),
    valid_to        TIMESTAMPTZ,
    is_active       BOOLEAN     DEFAULT TRUE
);

-- 6. COUPON_USAGE
-- Audit log of each coupon redemption per order.
CREATE TABLE IF NOT EXISTS coupon_usage (
    usage_id        UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    coupon_id       UUID        NOT NULL REFERENCES coupon(coupon_id) ON DELETE RESTRICT,
    order_id        UUID        NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    customer_id     UUID        REFERENCES customer(customer_id) ON DELETE SET NULL,
    used_at         TIMESTAMPTZ DEFAULT NOW(),
    discount_amount DECIMAL(10, 2) NOT NULL CHECK (discount_amount >= 0),
    UNIQUE (coupon_id, order_id)    -- A coupon can be used only once per order
);

-- ============================================================
-- INDEXES for customer engagement tables
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_cart_customer_id ON cart(customer_id);
CREATE INDEX IF NOT EXISTS idx_cart_item_cart_id ON cart_item(cart_id);
CREATE INDEX IF NOT EXISTS idx_cart_item_crop_id ON cart_item(crop_id);
CREATE INDEX IF NOT EXISTS idx_wishlist_customer_id ON wishlist(customer_id);
CREATE INDEX IF NOT EXISTS idx_wishlist_crop_id ON wishlist(crop_id);
CREATE INDEX IF NOT EXISTS idx_review_crop_id ON review(crop_id);
CREATE INDEX IF NOT EXISTS idx_review_customer_id ON review(customer_id);
CREATE INDEX IF NOT EXISTS idx_review_farmer_id ON review(farmer_id);
CREATE INDEX IF NOT EXISTS idx_review_rating ON review(rating);
CREATE INDEX IF NOT EXISTS idx_coupon_code ON coupon(coupon_code);
CREATE INDEX IF NOT EXISTS idx_coupon_active ON coupon(is_active);
CREATE INDEX IF NOT EXISTS idx_coupon_usage_coupon_id ON coupon_usage(coupon_id);
CREATE INDEX IF NOT EXISTS idx_coupon_usage_order_id ON coupon_usage(order_id);
