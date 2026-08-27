-- ============================================================
-- 24_seller_listing_table.sql
-- Seller Listing table linking Farmers & Aggregator Inventory Batches to Marketplace
-- ============================================================

CREATE TABLE IF NOT EXISTS seller_listing (
    listing_id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    crop_id                 UUID        NOT NULL REFERENCES crop(crop_id) ON DELETE RESTRICT,
    seller_party_id         UUID        NOT NULL REFERENCES party(party_id) ON DELETE CASCADE,
    seller_type             VARCHAR(20) NOT NULL CHECK (seller_type IN ('Farmer', 'Aggregator')),
    farmer_id               UUID        REFERENCES farmer(farmer_id) ON DELETE CASCADE,
    aggregator_id           UUID        REFERENCES aggregator(aggregator_id) ON DELETE CASCADE,
    farmer_crop_id          UUID        REFERENCES farmer_crop(farmer_crop_id) ON DELETE SET NULL,
    inventory_batch_id      UUID        REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE SET NULL,
    listing_title           VARCHAR(200) NOT NULL,
    price_per_unit          NUMERIC(10, 2) NOT NULL CHECK (price_per_unit > 0),
    unit                    VARCHAR(20) DEFAULT 'kg',
    available_quantity      NUMERIC(10, 2) NOT NULL CHECK (available_quantity >= 0),
    min_order_quantity      NUMERIC(10, 2) DEFAULT 1.0 CHECK (min_order_quantity > 0),
    quality_grade           VARCHAR(10) DEFAULT 'A' CHECK (quality_grade IN ('A', 'B', 'C')),
    freshness_score         NUMERIC(5, 2) DEFAULT 95.00 CHECK (freshness_score >= 0 AND freshness_score <= 100),
    harvest_date            TIMESTAMPTZ DEFAULT NOW() - INTERVAL '2 days',
    expiry_date             TIMESTAMPTZ DEFAULT NOW() + INTERVAL '10 days',
    is_organic              BOOLEAN     DEFAULT FALSE,
    is_active               BOOLEAN     DEFAULT TRUE,
    created_at              TIMESTAMPTZ DEFAULT NOW(),
    updated_at              TIMESTAMPTZ DEFAULT NOW()
);

-- Populate initial seller_listings from existing farmer_crops and aggregator_inventory
INSERT INTO seller_listing (
    crop_id, seller_party_id, seller_type, farmer_id, farmer_crop_id, 
    listing_title, price_per_unit, unit, available_quantity, quality_grade, freshness_score, is_organic, is_active
)
SELECT 
    fc.crop_id,
    f.party_id,
    'Farmer',
    f.farmer_id,
    fc.farmer_crop_id,
    c.crop_name || ' (Direct Farm Harvest)',
    32.00,
    c.unit,
    100.0,
    COALESCE(fc.grade, 'A'),
    92.50,
    COALESCE(fc.organic_level IS NOT NULL, FALSE),
    TRUE
FROM farmer_crop fc
JOIN farm fm ON fc.farm_id = fm.farm_id
JOIN farmer f ON fm.farmer_id = f.farmer_id
JOIN crop c ON fc.crop_id = c.crop_id
ON CONFLICT DO NOTHING;

INSERT INTO seller_listing (
    crop_id, seller_party_id, seller_type, aggregator_id, inventory_batch_id, farmer_crop_id,
    listing_title, price_per_unit, unit, available_quantity, quality_grade, freshness_score, expiry_date, is_active
)
SELECT 
    fc.crop_id,
    a.party_id,
    'Aggregator',
    a.aggregator_id,
    ai.inventory_batch_id,
    ai.farmer_crop_id,
    c.crop_name || ' (' || w.warehouse_name || ' Stock)',
    ai.unit_cost_price * 1.10,
    c.unit,
    ai.available_quantity_kg,
    COALESCE(qc.quality_grade, 'A'),
    88.00,
    ai.expiry_date,
    TRUE
FROM aggregator_inventory ai
JOIN warehouse w ON ai.warehouse_id = w.warehouse_id
JOIN aggregator a ON w.aggregator_id = a.aggregator_id
JOIN farmer_crop fc ON ai.farmer_crop_id = fc.farmer_crop_id
JOIN crop c ON fc.crop_id = c.crop_id
LEFT JOIN quality_check qc ON ai.inventory_batch_id = qc.inventory_batch_id
ON CONFLICT DO NOTHING;
