-- ============================================================
-- 12_engagement_tables.sql
-- Customer carts, cart items, wishlists, reviews, and coupons
-- Tables: cart, cart_item, wishlist, review, coupon, coupon_usage
-- ============================================================

CREATE TABLE IF NOT EXISTS cart (
    cart_id         UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id     UUID    NOT NULL UNIQUE REFERENCES customer(customer_id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cart_item (
    cart_item_id    UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id         UUID    NOT NULL REFERENCES cart(cart_id) ON DELETE CASCADE,
    crop_id         UUID    NOT NULL REFERENCES crop(crop_id) ON DELETE CASCADE,
    quantity        NUMERIC(10, 2) NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(10, 2) NOT NULL CHECK (unit_price > 0),
    added_at        TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (cart_id, crop_id)
);

CREATE TABLE IF NOT EXISTS wishlist (
    wishlist_id     UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id     UUID    NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    crop_id         UUID    NOT NULL REFERENCES crop(crop_id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (customer_id, crop_id)
);

CREATE TABLE IF NOT EXISTS review (
    review_id       UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
    crop_id         UUID    NOT NULL REFERENCES crop(crop_id) ON DELETE CASCADE,
    customer_id     UUID    NOT NULL REFERENCES customer(customer_id) ON DELETE RESTRICT,
    farmer_id       UUID    REFERENCES farmer(farmer_id) ON DELETE CASCADE,
    aggregator_id   UUID    REFERENCES aggregator(aggregator_id) ON DELETE CASCADE,
    rating          INT     NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text     TEXT,
    review_date     TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS coupon (
    coupon_id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    coupon_code         VARCHAR(30) NOT NULL UNIQUE,
    discount_type       VARCHAR(20) CHECK (discount_type IN ('Fixed', 'Percent')),
    discount_value      NUMERIC(10, 2) NOT NULL CHECK (discount_value > 0),
    min_order_amount    NUMERIC(10, 2) DEFAULT 0 CHECK (min_order_amount >= 0),
    max_discount_amount NUMERIC(10, 2),
    usage_limit         INT,
    used_count          INT         DEFAULT 0,
    valid_from          TIMESTAMPTZ DEFAULT NOW(),
    valid_to            TIMESTAMPTZ,
    is_active           BOOLEAN     DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS coupon_usage (
    usage_id        UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    coupon_id       UUID        NOT NULL REFERENCES coupon(coupon_id) ON DELETE RESTRICT,
    order_id        UUID        NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    customer_id     UUID        REFERENCES customer(customer_id) ON DELETE SET NULL,
    used_at         TIMESTAMPTZ DEFAULT NOW(),
    discount_amount NUMERIC(10, 2) NOT NULL CHECK (discount_amount >= 0),
    UNIQUE (coupon_id, order_id)
);
