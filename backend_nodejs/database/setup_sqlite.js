// Backend/database/setup_sqlite.js
const fs = require('fs');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();
const { v4: uuidv4 } = require('uuid');

const dbPath = path.join(__dirname, 'agrilink_v2.db');

// Delete existing database file if any
if (fs.existsSync(dbPath)) {
  fs.unlinkSync(dbPath);
  console.log('🗑️ Existing SQLite database deleted.');
}

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('❌ Failed to open database:', err.message);
    process.exit(1);
  }
  console.log('📦 Connected to SQLite database at:', dbPath);
});

// Run in serialized mode
db.serialize(() => {
  // Enable foreign keys
  db.run('PRAGMA foreign_keys = ON;');

  console.log('🏗️ Creating 47 tables...');

  // ==========================================
  // A. CORE / USER MANAGEMENT (Tables 1-6)
  // ==========================================

  // 1. ROLE
  db.run(`
    CREATE TABLE role (
      role_id TEXT PRIMARY KEY,
      role_name TEXT NOT NULL UNIQUE,
      role_description TEXT,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now'))
    );
  `);

  // 2. USER
  db.run(`
    CREATE TABLE users (
      user_id TEXT PRIMARY KEY,
      role_id TEXT NOT NULL,
      email TEXT UNIQUE,
      phone TEXT NOT NULL UNIQUE,
      password_hash TEXT NOT NULL,
      status TEXT DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive')),
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (role_id) REFERENCES role(role_id)
    );
  `);

  // 3. PARTY
  db.run(`
    CREATE TABLE party (
      party_id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL UNIQUE,
      party_type TEXT NOT NULL CHECK (party_type IN ('Customer', 'Farmer', 'Aggregator', 'Delivery Partner', 'Admin')),
      gstin TEXT UNIQUE,
      kyc_status TEXT DEFAULT 'Pending' CHECK (kyc_status IN ('Pending', 'Approved', 'Rejected')),
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
    );
  `);

  // 6. LOCATION
  db.run(`
    CREATE TABLE location (
      location_id TEXT PRIMARY KEY,
      address_line1 TEXT NOT NULL,
      address_line2 TEXT,
      city TEXT NOT NULL,
      state TEXT NOT NULL,
      pincode TEXT NOT NULL,
      country TEXT DEFAULT 'India',
      latitude REAL,
      longitude REAL,
      created_at TEXT DEFAULT (datetime('now'))
    );
  `);

  // 4. CUSTOMER
  db.run(`
    CREATE TABLE customer (
      customer_id TEXT PRIMARY KEY,
      party_id TEXT NOT NULL UNIQUE,
      loyalty_points INTEGER DEFAULT 0,
      default_address_id TEXT,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (party_id) REFERENCES party(party_id) ON DELETE CASCADE
    );
  `);

  // 5. CUSTOMER_ADDRESS
  db.run(`
    CREATE TABLE customer_address (
      address_id TEXT PRIMARY KEY,
      customer_id TEXT NOT NULL,
      location_id TEXT NOT NULL,
      address_type TEXT NOT NULL CHECK (address_type IN ('Home', 'Work', 'Other')),
      address_line1 TEXT NOT NULL,
      address_line2 TEXT,
      landmark TEXT,
      city TEXT NOT NULL,
      state TEXT NOT NULL,
      pincode TEXT NOT NULL,
      country TEXT DEFAULT 'India',
      latitude REAL,
      longitude REAL,
      is_default INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
      FOREIGN KEY (location_id) REFERENCES location(location_id)
    );
  `);

  // ==========================================
  // B. FARMER & FARM MANAGEMENT (Tables 7-11)
  // ==========================================

  // 7. FARMER
  db.run(`
    CREATE TABLE farmer (
      farmer_id TEXT PRIMARY KEY,
      party_id TEXT NOT NULL UNIQUE,
      farmer_code TEXT NOT NULL UNIQUE,
      bio TEXT,
      kyc_status TEXT DEFAULT 'Pending',
      bank_account_id TEXT,
      is_verified INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (party_id) REFERENCES party(party_id) ON DELETE CASCADE
    );
  `);

  // 8. FARM
  db.run(`
    CREATE TABLE farm (
      farm_id TEXT PRIMARY KEY,
      farmer_id TEXT NOT NULL,
      farm_name TEXT NOT NULL,
      total_area REAL NOT NULL CHECK (total_area > 0),
      location_id TEXT NOT NULL,
      description TEXT,
      organic_certified INTEGER DEFAULT 0,
      is_active INTEGER DEFAULT 1,
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (farmer_id) REFERENCES farmer(farmer_id) ON DELETE CASCADE,
      FOREIGN KEY (location_id) REFERENCES location(location_id)
    );
  `);

  // 10. CROP_CATEGORY
  db.run(`
    CREATE TABLE crop_category (
      category_id TEXT PRIMARY KEY,
      category_name TEXT NOT NULL UNIQUE,
      description TEXT,
      is_active INTEGER DEFAULT 1
    );
  `);

  // 11. CROP
  db.run(`
    CREATE TABLE crop (
      crop_id TEXT PRIMARY KEY,
      category_id TEXT NOT NULL,
      crop_name TEXT NOT NULL,
      description TEXT,
      unit TEXT NOT NULL,
      is_perishable INTEGER DEFAULT 1,
      is_active INTEGER DEFAULT 1,
      FOREIGN KEY (category_id) REFERENCES crop_category(category_id)
    );
  `);

  // 9. FARMER_CROP (Harvest Batch)
  db.run(`
    CREATE TABLE farmer_crop (
      farmer_crop_id TEXT PRIMARY KEY,
      farm_id TEXT NOT NULL,
      crop_id TEXT NOT NULL,
      variety TEXT,
      sowing_date TEXT,
      expected_harvest_date TEXT,
      organic_level TEXT,
      grade TEXT CHECK (grade IN ('A', 'B', 'C')),
      is_active INTEGER DEFAULT 1,
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (farm_id) REFERENCES farm(farm_id) ON DELETE CASCADE,
      FOREIGN KEY (crop_id) REFERENCES crop(crop_id)
    );
  `);

  // ==========================================
  // C. AGGREGATOR & WAREHOUSE (Tables 12-17)
  // ==========================================

  // 12. AGGREGATOR
  db.run(`
    CREATE TABLE aggregator (
      aggregator_id TEXT PRIMARY KEY,
      party_id TEXT NOT NULL UNIQUE,
      aggregator_code TEXT NOT NULL UNIQUE,
      business_name TEXT NOT NULL,
      gstin TEXT UNIQUE,
      kyc_status TEXT DEFAULT 'Pending',
      bank_account_id TEXT,
      is_verified INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (party_id) REFERENCES party(party_id) ON DELETE CASCADE
    );
  `);

  // 13. WAREHOUSE
  db.run(`
    CREATE TABLE warehouse (
      warehouse_id TEXT PRIMARY KEY,
      aggregator_id TEXT NOT NULL,
      warehouse_name TEXT NOT NULL,
      warehouse_type TEXT,
      location_id TEXT NOT NULL,
      total_capacity_kg REAL NOT NULL CHECK (total_capacity_kg > 0),
      occupied_capacity_kg REAL DEFAULT 0 CHECK (occupied_capacity_kg >= 0),
      cold_storage INTEGER DEFAULT 0,
      temperature_min REAL,
      temperature_max REAL,
      is_active INTEGER DEFAULT 1,
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (aggregator_id) REFERENCES aggregator(aggregator_id) ON DELETE CASCADE,
      FOREIGN KEY (location_id) REFERENCES location(location_id)
    );
  `);

  // 14. PROCUREMENT (Collection Receipt)
  db.run(`
    CREATE TABLE procurement (
      procurement_id TEXT PRIMARY KEY,
      farmer_id TEXT NOT NULL,
      aggregator_id TEXT NOT NULL,
      farmer_crop_id TEXT NOT NULL,
      quantity_kg REAL NOT NULL CHECK (quantity_kg > 0),
      unit_price REAL NOT NULL CHECK (unit_price > 0),
      total_price REAL NOT NULL,
      procurement_date TEXT DEFAULT (datetime('now')),
      quality_status TEXT DEFAULT 'Pending' CHECK (quality_status IN ('Pending', 'Passed', 'Failed')),
      payment_status TEXT DEFAULT 'Pending' CHECK (payment_status IN ('Pending', 'Paid', 'Failed')),
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (farmer_id) REFERENCES farmer(farmer_id),
      FOREIGN KEY (aggregator_id) REFERENCES aggregator(aggregator_id),
      FOREIGN KEY (farmer_crop_id) REFERENCES farmer_crop(farmer_crop_id)
    );
  `);

  // 15. AGGREGATOR_INVENTORY (Batch)
  db.run(`
    CREATE TABLE aggregator_inventory (
      inventory_batch_id TEXT PRIMARY KEY,
      warehouse_id TEXT NOT NULL,
      farmer_id TEXT,
      farmer_crop_id TEXT,
      batch_no TEXT NOT NULL UNIQUE,
      quantity_kg REAL NOT NULL CHECK (quantity_kg >= 0),
      unit_cost_price REAL NOT NULL CHECK (unit_cost_price > 0),
      available_quantity_kg REAL NOT NULL CHECK (available_quantity_kg >= 0),
      reserved_quantity_kg REAL DEFAULT 0 CHECK (reserved_quantity_kg >= 0),
      quality_status TEXT DEFAULT 'Passed',
      expiry_date TEXT,
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id) ON DELETE CASCADE,
      FOREIGN KEY (farmer_id) REFERENCES farmer(farmer_id) ON DELETE SET NULL,
      FOREIGN KEY (farmer_crop_id) REFERENCES farmer_crop(farmer_crop_id) ON DELETE SET NULL
    );
  `);

  // 16. INVENTORY_RESERVATION
  db.run(`
    CREATE TABLE inventory_reservation (
      reservation_id TEXT PRIMARY KEY,
      inventory_batch_id TEXT NOT NULL,
      reserved_quantity_kg REAL NOT NULL CHECK (reserved_quantity_kg > 0),
      reserved_until TEXT NOT NULL,
      status TEXT DEFAULT 'Active' CHECK (status IN ('Active', 'Expired', 'Used')),
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (inventory_batch_id) REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE CASCADE
    );
  `);

  // 17. QUALITY_CHECK
  db.run(`
    CREATE TABLE quality_check (
      qc_id TEXT PRIMARY KEY,
      inventory_batch_id TEXT NOT NULL,
      checked_by TEXT,
      quality_grade TEXT CHECK (quality_grade IN ('A', 'B', 'C')),
      qc_status TEXT DEFAULT 'Passed' CHECK (qc_status IN ('Passed', 'Failed')),
      remarks TEXT,
      FOREIGN KEY (inventory_batch_id) REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE CASCADE,
      FOREIGN KEY (checked_by) REFERENCES users(user_id) ON DELETE SET NULL
    );
  `);

  // ==========================================
  // D. ORDER & FULFILLMENT (Tables 18-22)
  // ==========================================

  // 19. ORDERS (Rename from order to orders to avoid SQLite keyword issue)
  db.run(`
    CREATE TABLE orders (
      order_id TEXT PRIMARY KEY,
      customer_id TEXT NOT NULL,
      order_date TEXT DEFAULT (datetime('now')),
      order_status TEXT DEFAULT 'Placed' CHECK (order_status IN ('Placed', 'Confirmed', 'Processing', 'OutForDelivery', 'Delivered', 'Cancelled')),
      total_amount REAL NOT NULL CHECK (total_amount >= 0),
      delivery_address_id TEXT,
      payment_status TEXT DEFAULT 'Pending' CHECK (payment_status IN ('Pending', 'Paid', 'Failed', 'Refunded')),
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
      FOREIGN KEY (delivery_address_id) REFERENCES customer_address(address_id)
    );
  `);

  // 20. ORDER_ITEM
  db.run(`
    CREATE TABLE order_item (
      order_item_id TEXT PRIMARY KEY,
      order_id TEXT NOT NULL,
      crop_id TEXT NOT NULL,
      quantity REAL NOT NULL CHECK (quantity > 0),
      unit_price REAL NOT NULL CHECK (unit_price > 0),
      selected_type TEXT CHECK (selected_type IN ('Farmer', 'Aggregator')),
      subtotal REAL NOT NULL,
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
      FOREIGN KEY (crop_id) REFERENCES crop(crop_id)
    );
  `);

  // 22. FULFILLMENT_SOURCE
  db.run(`
    CREATE TABLE fulfillment_source (
      fulfillment_source_id TEXT PRIMARY KEY,
      source_type TEXT NOT NULL CHECK (source_type IN ('Farmer', 'Aggregator')),
      source_name TEXT,
      farmer_id TEXT,
      inventory_batch_id TEXT,
      FOREIGN KEY (farmer_id) REFERENCES farmer(farmer_id) ON DELETE SET NULL,
      FOREIGN KEY (inventory_batch_id) REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE SET NULL
    );
  `);

  // 21. ORDER_ALLOCATION (Split Allocation)
  db.run(`
    CREATE TABLE order_allocation (
      allocation_id TEXT PRIMARY KEY,
      order_item_id TEXT NOT NULL,
      fulfillment_source_id TEXT NOT NULL,
      source_type TEXT NOT NULL CHECK (source_type IN ('Direct', 'Warehouse')),
      source_id TEXT NOT NULL,
      allocated_quantity_kg REAL NOT NULL CHECK (allocated_quantity_kg > 0),
      unit_price REAL NOT NULL CHECK (unit_price > 0),
      subtotal REAL NOT NULL,
      allocation_sequence INTEGER DEFAULT 1,
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (order_item_id) REFERENCES order_item(order_item_id) ON DELETE CASCADE,
      FOREIGN KEY (fulfillment_source_id) REFERENCES fulfillment_source(fulfillment_source_id)
    );
  `);

  // 18. ORDER_TRACKING
  db.run(`
    CREATE TABLE order_tracking (
      tracking_id TEXT PRIMARY KEY,
      order_id TEXT NOT NULL,
      status TEXT NOT NULL,
      status_updated_at TEXT DEFAULT (datetime('now')),
      location_id TEXT,
      remarks TEXT,
      FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
      FOREIGN KEY (location_id) REFERENCES location(location_id)
    );
  `);

  // ==========================================
  // E. DELIVERY MANAGEMENT (Tables 23-28)
  // ==========================================

  // 23. DELIVERY
  db.run(`
    CREATE TABLE delivery (
      delivery_id TEXT PRIMARY KEY,
      order_id TEXT NOT NULL,
      delivery_type TEXT CHECK (delivery_type IN ('Pickup', 'Drop', 'OnTheWay')),
      delivery_status TEXT DEFAULT 'Pending',
      pickup_address_id TEXT,
      delivery_address_id TEXT,
      scheduled_delivery_date TEXT,
      actual_delivery_date TEXT,
      delivery_charge REAL DEFAULT 0 CHECK (delivery_charge >= 0),
      status TEXT DEFAULT 'Active',
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
      FOREIGN KEY (pickup_address_id) REFERENCES location(location_id),
      FOREIGN KEY (delivery_address_id) REFERENCES customer_address(address_id)
    );
  `);

  // 25. DELIVERY_PARTNER
  db.run(`
    CREATE TABLE delivery_partner (
      delivery_partner_id TEXT PRIMARY KEY,
      party_id TEXT NOT NULL UNIQUE,
      partner_code TEXT NOT NULL UNIQUE,
      rating REAL DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5.0),
      kyc_status TEXT DEFAULT 'Pending',
      bank_account_id TEXT,
      is_active INTEGER DEFAULT 1,
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (party_id) REFERENCES party(party_id) ON DELETE CASCADE
    );
  `);

  // 24. DELIVERY_ASSIGNMENT
  db.run(`
    CREATE TABLE delivery_assignment (
      assignment_id TEXT PRIMARY KEY,
      delivery_id TEXT NOT NULL,
      delivery_partner_id TEXT NOT NULL,
      assigned_at TEXT DEFAULT (datetime('now')),
      status TEXT DEFAULT 'Assigned' CHECK (status IN ('Assigned', 'Accepted', 'PickedUp', 'InTransit', 'Delivered')),
      actual_delivery_time TEXT,
      earning_amount REAL DEFAULT 0 CHECK (earning_amount >= 0),
      FOREIGN KEY (delivery_id) REFERENCES delivery(delivery_id) ON DELETE CASCADE,
      FOREIGN KEY (delivery_partner_id) REFERENCES delivery_partner(delivery_partner_id)
    );
  `);

  // 26. VEHICLE
  db.run(`
    CREATE TABLE vehicle (
      vehicle_id TEXT PRIMARY KEY,
      delivery_partner_id TEXT NOT NULL,
      vehicle_type TEXT NOT NULL,
      vehicle_no TEXT NOT NULL UNIQUE,
      capacity_kg REAL CHECK (capacity_kg > 0),
      current_load_kg REAL DEFAULT 0 CHECK (current_load_kg >= 0),
      is_active INTEGER DEFAULT 1,
      FOREIGN KEY (delivery_partner_id) REFERENCES delivery_partner(delivery_partner_id) ON DELETE CASCADE
    );
  `);

  // 27. DELIVERY_ROUTE
  db.run(`
    CREATE TABLE delivery_route (
      route_id TEXT PRIMARY KEY,
      delivery_id TEXT NOT NULL,
      sequence_no INTEGER NOT NULL,
      stop_location_id TEXT NOT NULL,
      stop_type TEXT CHECK (stop_type IN ('Pickup', 'Drop')),
      estimated_time TEXT,
      actual_time TEXT,
      FOREIGN KEY (delivery_id) REFERENCES delivery(delivery_id) ON DELETE CASCADE,
      FOREIGN KEY (stop_location_id) REFERENCES location(location_id)
    );
  `);

  // 28. DELIVERY_PROOF
  db.run(`
    CREATE TABLE delivery_proof (
      proof_id TEXT PRIMARY KEY,
      delivery_id TEXT NOT NULL,
      proof_type TEXT CHECK (proof_type IN ('Signature', 'OTP', 'Image')),
      otp_verified TEXT DEFAULT 'N' CHECK (otp_verified IN ('Y', 'N')),
      gps_latitude REAL,
      gps_longitude REAL,
      remarks TEXT,
      FOREIGN KEY (delivery_id) REFERENCES delivery(delivery_id) ON DELETE CASCADE
    );
  `);

  // ==========================================
  // F. PAYMENT & SETTLEMENT (Tables 29-31)
  // ==========================================

  // 29. PAYMENT
  db.run(`
    CREATE TABLE payment (
      payment_id TEXT PRIMARY KEY,
      order_id TEXT NOT NULL,
      amount REAL NOT NULL CHECK (amount > 0),
      payment_method TEXT CHECK (payment_method IN ('COD', 'UPI', 'Card', 'NetBanking')),
      gateway_name TEXT,
      transaction_id TEXT,
      payment_date TEXT DEFAULT (datetime('now')),
      payment_status TEXT DEFAULT 'Pending' CHECK (payment_status IN ('Success', 'Failed', 'Pending')),
      FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
    );
  `);

  // 30. SETTLEMENT
  db.run(`
    CREATE TABLE settlement (
      settlement_id TEXT PRIMARY KEY,
      settlement_type TEXT,
      payment_id TEXT NOT NULL,
      status TEXT DEFAULT 'Pending' CHECK (status IN ('Pending', 'Processed', 'Failed')),
      settlement_date TEXT,
      FOREIGN KEY (payment_id) REFERENCES payment(payment_id)
    );
  `);

  // 31. SETTLEMENT_DETAIL
  db.run(`
    CREATE TABLE settlement_detail (
      detail_id TEXT PRIMARY KEY,
      settlement_id TEXT NOT NULL,
      entity_type TEXT CHECK (entity_type IN ('Farmer', 'Aggregator', 'Delivery', 'Platform', 'GST')),
      percentage REAL CHECK (percentage >= 0 AND percentage <= 100.0),
      amount REAL NOT NULL CHECK (amount >= 0),
      remarks TEXT,
      FOREIGN KEY (settlement_id) REFERENCES settlement(settlement_id) ON DELETE CASCADE
    );
  `);

  // ==========================================
  // G. CUSTOMER ENGAGEMENT (Tables 32-37)
  // ==========================================

  // 32. CART
  db.run(`
    CREATE TABLE cart (
      cart_id TEXT PRIMARY KEY,
      customer_id TEXT NOT NULL,
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE
    );
  `);

  // 33. CART_ITEM
  db.run(`
    CREATE TABLE cart_item (
      cart_item_id TEXT PRIMARY KEY,
      cart_id TEXT NOT NULL,
      crop_id TEXT NOT NULL,
      quantity REAL NOT NULL CHECK (quantity > 0),
      unit_price REAL NOT NULL CHECK (unit_price > 0),
      FOREIGN KEY (cart_id) REFERENCES cart(cart_id) ON DELETE CASCADE,
      FOREIGN KEY (crop_id) REFERENCES crop(crop_id) ON DELETE CASCADE
    );
  `);

  // 34. WISHLIST
  db.run(`
    CREATE TABLE wishlist (
      wishlist_id TEXT PRIMARY KEY,
      customer_id TEXT NOT NULL,
      crop_id TEXT NOT NULL,
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
      FOREIGN KEY (crop_id) REFERENCES crop(crop_id) ON DELETE CASCADE
    );
  `);

  // 35. REVIEW
  db.run(`
    CREATE TABLE review (
      review_id TEXT PRIMARY KEY,
      crop_id TEXT NOT NULL,
      customer_id TEXT NOT NULL,
      farmer_id TEXT,
      aggregator_id TEXT,
      rating INTEGER CHECK (rating >= 1 AND rating <= 5),
      review_text TEXT,
      review_date TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (crop_id) REFERENCES crop(crop_id) ON DELETE CASCADE,
      FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
      FOREIGN KEY (farmer_id) REFERENCES farmer(farmer_id) ON DELETE CASCADE,
      FOREIGN KEY (aggregator_id) REFERENCES aggregator(aggregator_id) ON DELETE CASCADE
    );
  `);

  // 36. COUPON
  db.run(`
    CREATE TABLE coupon (
      coupon_id TEXT PRIMARY KEY,
      coupon_code TEXT NOT NULL UNIQUE,
      discount_type TEXT CHECK (discount_type IN ('Fixed', 'Percent')),
      discount_value REAL NOT NULL CHECK (discount_value > 0),
      min_order_amount REAL DEFAULT 0 CHECK (min_order_amount >= 0),
      valid_from TEXT DEFAULT (datetime('now')),
      valid_to TEXT,
      is_active INTEGER DEFAULT 1
    );
  `);

  // 37. COUPON_USAGE
  db.run(`
    CREATE TABLE coupon_usage (
      usage_id TEXT PRIMARY KEY,
      coupon_id TEXT NOT NULL,
      order_id TEXT NOT NULL,
      used_at TEXT DEFAULT (datetime('now')),
      discount_amount REAL NOT NULL CHECK (discount_amount >= 0),
      FOREIGN KEY (coupon_id) REFERENCES coupon(coupon_id),
      FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
    );
  `);

  // ==========================================
  // H. SYSTEM SUPPORT & COMMUNICATION (Tables 38-39)
  // ==========================================

  // 38. NOTIFICATION
  db.run(`
    CREATE TABLE notification (
      notification_id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      title TEXT NOT NULL,
      message TEXT NOT NULL,
      is_read TEXT DEFAULT 'N' CHECK (is_read IN ('Y', 'N')),
      is_delivered TEXT DEFAULT 'N' CHECK (is_delivered IN ('Y', 'N')),
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
    );
  `);

  // 39. NOTIFICATION_STATUS
  db.run(`
    CREATE TABLE notification_status (
      status_id TEXT PRIMARY KEY,
      notification_id TEXT NOT NULL,
      device_id TEXT,
      read_at TEXT,
      status TEXT CHECK (status IN ('Sent', 'Delivered', 'Read', 'Failed')),
      FOREIGN KEY (notification_id) REFERENCES notification(notification_id) ON DELETE CASCADE
    );
  `);

  // ==========================================
  // I. PRICE & ANALYTICS (Tables 40-41)
  // ==========================================

  // 40. PRICE_HISTORY
  db.run(`
    CREATE TABLE price_history (
      price_history_id TEXT PRIMARY KEY,
      crop_id TEXT NOT NULL,
      old_price REAL CHECK (old_price >= 0),
      new_price REAL NOT NULL CHECK (new_price >= 0),
      source TEXT CHECK (source IN ('Manual', 'Market', 'Demand', 'Prediction')),
      effective_from TEXT DEFAULT (datetime('now')),
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (crop_id) REFERENCES crop(crop_id) ON DELETE CASCADE
    );
  `);

  // 41. ML_PRICE_PREDICTION
  db.run(`
    CREATE TABLE ml_price_prediction (
      prediction_id TEXT PRIMARY KEY,
      crop_id TEXT NOT NULL,
      predicted_price REAL NOT NULL CHECK (predicted_price >= 0),
      factors TEXT,
      effective_from TEXT NOT NULL,
      effective_to TEXT NOT NULL,
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (crop_id) REFERENCES crop(crop_id) ON DELETE CASCADE
    );
  `);

  // ==========================================
  // J. RETURNS & REFUNDS (Tables 42-44)
  // ==========================================

  // 42. RETURNS
  db.run(`
    CREATE TABLE returns (
      return_id TEXT PRIMARY KEY,
      order_id TEXT NOT NULL,
      return_date TEXT DEFAULT (datetime('now')),
      reason TEXT NOT NULL,
      status TEXT DEFAULT 'Requested' CHECK (status IN ('Requested', 'Approved', 'Rejected', 'Completed')),
      FOREIGN KEY (order_id) REFERENCES orders(order_id)
    );
  `);

  // 43. RETURN_ITEM
  db.run(`
    CREATE TABLE return_item (
      return_item_id TEXT PRIMARY KEY,
      return_id TEXT NOT NULL,
      order_item_id TEXT NOT NULL,
      quantity REAL NOT NULL CHECK (quantity > 0),
      refund_amount REAL NOT NULL CHECK (refund_amount >= 0),
      FOREIGN KEY (return_id) REFERENCES returns(return_id) ON DELETE CASCADE,
      FOREIGN KEY (order_item_id) REFERENCES order_item(order_item_id)
    );
  `);

  // 44. REFUND
  db.run(`
    CREATE TABLE refund (
      refund_id TEXT PRIMARY KEY,
      return_id TEXT NOT NULL,
      amount REAL NOT NULL CHECK (amount > 0),
      refund_method TEXT,
      status TEXT DEFAULT 'Pending',
      refund_date TEXT,
      transaction_id TEXT,
      FOREIGN KEY (return_id) REFERENCES returns(return_id) ON DELETE CASCADE
    );
  `);

  // ==========================================
  // K. INVENTORY MOVEMENT & ADJUSTMENT (Tables 45-47)
  // ==========================================

  // 45. INVENTORY_MOVEMENT (Ledger)
  db.run(`
    CREATE TABLE inventory_movement (
      movement_id TEXT PRIMARY KEY,
      inventory_batch_id TEXT NOT NULL,
      movement_type TEXT NOT NULL CHECK (movement_type IN ('IN', 'OUT', 'RESERVED', 'RELEASED', 'HOLD', 'RETURNED', 'ADJUSTMENT', 'DAMAGED', 'EXPIRED')),
      quantity_kg REAL NOT NULL,
      reference_type TEXT,
      reference_id TEXT,
      performed_by TEXT,
      movement_date TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (inventory_batch_id) REFERENCES aggregator_inventory(inventory_batch_id),
      FOREIGN KEY (performed_by) REFERENCES users(user_id) ON DELETE SET NULL
    );
  `);

  // 46. INVENTORY_ADJUSTMENT
  db.run(`
    CREATE TABLE inventory_adjustment (
      adjustment_id TEXT PRIMARY KEY,
      inventory_batch_id TEXT NOT NULL,
      adjustment_type TEXT NOT NULL CHECK (adjustment_type IN ('Damage', 'Spoilage', 'Expiry', 'Manual Correction', 'Theft', 'Other')),
      quantity_kg REAL NOT NULL CHECK (quantity_kg > 0),
      reason TEXT,
      performed_by TEXT,
      approved_by TEXT,
      remarks TEXT,
      FOREIGN KEY (inventory_batch_id) REFERENCES aggregator_inventory(inventory_batch_id),
      FOREIGN KEY (performed_by) REFERENCES users(user_id) ON DELETE SET NULL,
      FOREIGN KEY (approved_by) REFERENCES users(user_id) ON DELETE SET NULL
    );
  `);

  // 47. BATCH_EXPIRY_ALERT
  db.run(`
    CREATE TABLE batch_expiry_alert (
      alert_id TEXT PRIMARY KEY,
      inventory_batch_id TEXT NOT NULL,
      alert_type TEXT CHECK (alert_type IN ('Expiring Soon', 'Expired')),
      alert_time TEXT DEFAULT (datetime('now')),
      notified_to TEXT,
      status TEXT DEFAULT 'Unread' CHECK (status IN ('Unread', 'Read')),
      FOREIGN KEY (inventory_batch_id) REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE CASCADE,
      FOREIGN KEY (notified_to) REFERENCES users(user_id) ON DELETE CASCADE
    );
  `);

  console.log('🌱 Seed data generation starting...');

  // Roles Seed
  const roles = [
    { id: uuidv4(), name: 'Admin', desc: 'System Administrator' },
    { id: uuidv4(), name: 'Farmer', desc: 'Crop Producer/Seller' },
    { id: uuidv4(), name: 'Customer', desc: 'Consumer of produce (Individual, Hostel, Hospital)' },
    { id: uuidv4(), name: 'Aggregator', desc: 'Warehouse manager & bulk buyer' },
    { id: uuidv4(), name: 'Delivery Partner', desc: 'Delivery and route agent' },
  ];

  roles.forEach((r) => {
    db.run(
      'INSERT INTO role (role_id, role_name, role_description) VALUES (?, ?, ?)',
      [r.id, r.name, r.desc]
    );
  });

  // Users Seed
  const usersList = [
    { id: uuidv4(), email: 'admin@agrilink.com', phone: '+919999999999', role: 'Admin' },
    { id: uuidv4(), email: 'farmer1@farm.com', phone: '+919876543210', role: 'Farmer' },
    { id: uuidv4(), email: 'farmer2@farm.com', phone: '+919876543211', role: 'Farmer' },
    { id: uuidv4(), email: 'cust_indiv@gmail.com', phone: '+919123456780', role: 'Customer' },
    { id: uuidv4(), email: 'cust_hostel@pg.com', phone: '+919123456781', role: 'Customer' },
    { id: uuidv4(), email: 'cust_hosp@hospital.com', phone: '+919123456782', role: 'Customer' },
    { id: uuidv4(), email: 'aggregator1@warehouse.com', phone: '+919555555550', role: 'Aggregator' },
    { id: uuidv4(), email: 'aggregator2@warehouse.com', phone: '+919555555551', role: 'Aggregator' },
    { id: uuidv4(), email: 'delivery1@logistics.com', phone: '+919444444440', role: 'Delivery Partner' },
    { id: uuidv4(), email: 'delivery2@logistics.com', phone: '+919444444441', role: 'Delivery Partner' },
  ];

  // Helper to map Role Name to UUID
  db.all('SELECT * FROM role', (err, rows) => {
    if (err) return console.error(err);

    const roleMap = {};
    rows.forEach((r) => { roleMap[r.role_name] = r.role_id; });

    usersList.forEach((u) => {
      u.roleId = roleMap[u.role];
      db.run(
        'INSERT INTO users (user_id, role_id, email, phone, password_hash, status) VALUES (?, ?, ?, ?, ?, ?)',
        [u.id, u.roleId, u.email, u.phone, '$2a$10$X86.qG/0y8vV6h27.K/Xeu3/J92/HqY91Q8nEqj4P.p3Z9B24WWeK', 'Active']
      );
    });

    // Party Profiles Seed
    usersList.forEach((u) => {
      u.partyId = uuidv4();
      const gstin = u.role === 'Aggregator' || u.role === 'Admin' ? '29AAAAA1111A1Z1' : null;
      db.run(
        'INSERT INTO party (party_id, user_id, party_type, gstin, kyc_status) VALUES (?, ?, ?, ?, ?)',
        [u.partyId, u.id, u.role, gstin, 'Approved']
      );
    });

    // Locations Seed
    const locations = [
      { id: uuidv4(), line1: 'Farm Sector 5', line2: 'Near Highway', city: 'Mysore', state: 'Karnataka', pin: '570001', lat: 12.2958, lng: 76.6394 },
      { id: uuidv4(), line1: 'Rosewood PG Garden', line2: 'Vidya Nagar', city: 'Bangalore', state: 'Karnataka', pin: '560001', lat: 12.9716, lng: 77.5946 },
      { id: uuidv4(), line1: 'City General Hospital', line2: 'Hospital Road', city: 'Bangalore', state: 'Karnataka', pin: '560002', lat: 12.9616, lng: 77.5846 },
      { id: uuidv4(), line1: 'Central Warehouse B3', line2: 'Industrial Area', city: 'Mysore', state: 'Karnataka', pin: '570018', lat: 12.3158, lng: 76.6194 },
      { id: uuidv4(), line1: 'Sunrise Farm A', line2: 'Rural Village', city: 'Hassan', state: 'Karnataka', pin: '573201', lat: 13.0072, lng: 76.1026 }
    ];

    locations.forEach((loc) => {
      db.run(
        'INSERT INTO location (location_id, address_line1, address_line2, city, state, pincode, country, latitude, longitude) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [loc.id, loc.line1, loc.line2, loc.city, loc.state, loc.pin, 'India', loc.lat, loc.lng]
      );
    });

    // Extract User IDs for Customer, Farmer, Aggregator, Delivery
    const farmerUsers = usersList.filter(u => u.role === 'Farmer');
    const customerUsers = usersList.filter(u => u.role === 'Customer');
    const aggregatorUsers = usersList.filter(u => u.role === 'Aggregator');
    const deliveryUsers = usersList.filter(u => u.role === 'Delivery Partner');

    // Customer setup
    const customerList = [];
    customerUsers.forEach((cu, index) => {
      const custId = uuidv4();
      customerList.push({ id: custId, partyId: cu.partyId, type: index === 0 ? 'Individual' : (index === 1 ? 'PG' : 'Hospital') });
      db.run(
        'INSERT INTO customer (customer_id, party_id, loyalty_points) VALUES (?, ?, ?)',
        [custId, cu.partyId, 150]
      );
    });

    // Customer Addresses
    customerList.forEach((c, idx) => {
      const addrId = uuidv4();
      const locId = locations[idx + 1].id; // Rosewood PG, Hospital, etc.
      db.run(
        'INSERT INTO customer_address (address_id, customer_id, location_id, address_type, address_line1, city, state, pincode, is_default) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [addrId, c.id, locId, 'Work', locations[idx + 1].line1, locations[idx + 1].city, locations[idx + 1].state, locations[idx + 1].pincode, 1],
        (err) => {
          if (!err) {
            // Update customer default_address_id
            db.run('UPDATE customer SET default_address_id = ? WHERE customer_id = ?', [addrId, c.id]);
          }
        }
      );
    });

    // Farmers Seed
    const farmerList = [];
    farmerUsers.forEach((fu, idx) => {
      const farmerId = uuidv4();
      farmerList.push({ id: farmerId, partyId: fu.partyId });
      db.run(
        'INSERT INTO farmer (farmer_id, party_id, farmer_code, bio, kyc_status, bank_account_id, is_verified) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [farmerId, fu.partyId, `FRM00${idx + 1}`, 'Dedicated organic farm producer.', 'Approved', 'ACC1234567890', 1]
      );
    });

    // Farms Seed
    const farmList = [];
    farmerList.forEach((f, idx) => {
      const farmId = uuidv4();
      farmList.push({ id: farmId, farmerId: f.id });
      db.run(
        'INSERT INTO farm (farm_id, farmer_id, farm_name, total_area, location_id, description, organic_certified, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [farmId, f.id, `Greenfield Acres ${idx + 1}`, 15.5 + idx, idx === 0 ? locations[0].id : locations[4].id, 'Cultivating quality crops.', 1, 1]
      );
    });

    // Crop Categories Seed
    const ccFruitId = uuidv4();
    const ccVegId = uuidv4();
    const ccGrainId = uuidv4();

    db.run('INSERT INTO crop_category (category_id, category_name, description) VALUES (?, ?, ?)', [ccFruitId, 'Fruits', 'Fresh juicy organic fruits']);
    db.run('INSERT INTO crop_category (category_id, category_name, description) VALUES (?, ?, ?)', [ccVegId, 'Vegetables', 'Farm fresh vegetables']);
    db.run('INSERT INTO crop_category (category_id, category_name, description) VALUES (?, ?, ?)', [ccGrainId, 'Grains', 'Grains, cereals and pulses']);

    // Crops Seed
    const crops = [
      { id: uuidv4(), catId: ccFruitId, name: 'Alphanso Mango', desc: 'Premium sweet mangoes', unit: 'kg', perishable: 1 },
      { id: uuidv4(), catId: ccFruitId, name: 'Robusta Banana', desc: 'Energy-rich bananas', unit: 'dozen', perishable: 1 },
      { id: uuidv4(), catId: ccVegId, name: 'Organic Tomato', desc: 'Red ripe field tomatoes', unit: 'kg', perishable: 1 },
      { id: uuidv4(), catId: ccVegId, name: 'Fresh Onion', desc: 'Red onions direct from soil', unit: 'kg', perishable: 0 },
      { id: uuidv4(), catId: ccGrainId, name: 'Sona Masuri Rice', desc: 'Fine grain polished rice', unit: 'bag (25kg)', perishable: 0 },
    ];

    crops.forEach((c) => {
      db.run(
        'INSERT INTO crop (crop_id, category_id, crop_name, description, unit, is_perishable, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [c.id, c.catId, c.name, c.desc, c.unit, c.perishable, 1]
      );
    });

    // Farmer Crops (Harvest Batch) Seed
    const farmerCropList = [];
    farmList.forEach((farm, fIdx) => {
      crops.forEach((crop, cIdx) => {
        if ((fIdx + cIdx) % 2 === 0) {
          const fcId = uuidv4();
          farmerCropList.push({ id: fcId, farmId: farm.farm_id, cropId: crop.id, farmerId: farm.farmer_id });
          db.run(
            'INSERT INTO farmer_crop (farmer_crop_id, farm_id, crop_id, variety, sowing_date, expected_harvest_date, organic_level, grade, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [fcId, farm.farm_id, crop.id, 'Local Premium', '2026-04-10', '2026-07-20', 'Fully Organic', 'A', 1]
          );
        }
      });
    });

    // Aggregators Seed
    const aggregatorList = [];
    aggregatorUsers.forEach((au, idx) => {
      const aggId = uuidv4();
      aggregatorList.push({ id: aggId, partyId: au.partyId });
      db.run(
        'INSERT INTO aggregator (aggregator_id, party_id, aggregator_code, business_name, gstin, kyc_status, bank_account_id, is_verified) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [aggId, au.partyId, `AGG00${idx + 1}`, `AgriHub Logistics ${idx + 1}`, `29GGGGG000${idx}Z1`, 'Approved', 'ACC987654321', 1]
      );
    });

    // Warehouses Seed
    const warehouseList = [];
    aggregatorList.forEach((agg, idx) => {
      const whId = uuidv4();
      warehouseList.push({ id: whId, aggId: agg.id });
      db.run(
        'INSERT INTO warehouse (warehouse_id, aggregator_id, warehouse_name, warehouse_type, location_id, total_capacity_kg, occupied_capacity_kg, cold_storage, temperature_min, temperature_max, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [whId, agg.id, `Central Cold Storage ${idx + 1}`, 'Cold Room', locations[3].id, 100000.0, 500.0, 1, 2.0, 8.0, 1]
      );
    });

    // Procurements Seed
    const procurementList = [];
    farmerCropList.forEach((fc, idx) => {
      if (idx < 2) {
        const procId = uuidv4();
        procurementList.push({ id: procId, farmerId: fc.farmerId, cropId: fc.cropId, farmerCropId: fc.id });
        db.run(
          'INSERT INTO procurement (procurement_id, farmer_id, aggregator_id, farmer_crop_id, quantity_kg, unit_price, total_price, quality_status, payment_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [procId, fc.farmerId, aggregatorList[0].id, fc.id, 500.0, 35.0, 17500.0, 'Passed', 'Paid']
        );
      }
    });

    // Aggregator Inventory Seed
    const inventoryBatchList = [];
    procurementList.forEach((p, idx) => {
      const batchId = uuidv4();
      inventoryBatchList.push({ id: batchId, whId: warehouseList[0].id, cropId: p.cropId });
      db.run(
        'INSERT INTO aggregator_inventory (inventory_batch_id, warehouse_id, farmer_id, farmer_crop_id, batch_no, quantity_kg, unit_cost_price, available_quantity_kg, reserved_quantity_kg, quality_status, expiry_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [batchId, warehouseList[0].id, p.farmerId, p.farmerCropId, `BAT-${2026}-00${idx + 1}`, 500.0, 38.0, 450.0, 50.0, 'Passed', '2026-08-15']
      );
    });

    // Inventory Reservation Seed
    inventoryBatchList.forEach((inv, idx) => {
      db.run(
        'INSERT INTO inventory_reservation (reservation_id, inventory_batch_id, reserved_quantity_kg, reserved_until, status) VALUES (?, ?, ?, ?, ?)',
        [uuidv4(), inv.id, 50.0, '2026-07-10 18:00:00', 'Active']
      );
    });

    // Quality Check Seed
    inventoryBatchList.forEach((inv) => {
      db.run(
        'INSERT INTO quality_check (qc_id, inventory_batch_id, checked_by, quality_grade, qc_status, remarks) VALUES (?, ?, ?, ?, ?, ?)',
        [uuidv4(), inv.id, usersList[0].id, 'A', 'Passed', 'Moisture level optimal (12%). Fruits firm.']
      );
    });

    // Coupon Seed
    const couponId = uuidv4();
    db.run(
      'INSERT INTO coupon (coupon_id, coupon_code, discount_type, discount_value, min_order_amount, valid_from, valid_to, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [couponId, 'AGRILINK50', 'Fixed', 50.0, 200.0, '2026-01-01', '2026-12-31', 1]
    );

    // Orders Seed
    const orderList = [];
    customerList.forEach((cust, idx) => {
      const orderId = uuidv4();
      orderList.push({ id: orderId, custId: cust.id });
      db.run(
        'INSERT INTO orders (order_id, customer_id, order_status, total_amount, payment_status) VALUES (?, ?, ?, ?, ?)',
        [orderId, cust.id, idx === 0 ? 'Placed' : (idx === 1 ? 'Confirmed' : 'Processing'), 750.0 + idx * 100, 'Paid']
      );
    });

    // Order Items Seed
    const orderItemList = [];
    orderList.forEach((ord) => {
      const oiId = uuidv4();
      orderItemList.push({ id: oiId, orderId: ord.id, cropId: crops[2].id }); // Organic Tomato
      db.run(
        'INSERT INTO order_item (order_item_id, order_id, crop_id, quantity, unit_price, selected_type, subtotal) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [oiId, ord.id, crops[2].id, 20.0, 40.0, 'Aggregator', 800.0]
      );
    });

    // Fulfillment Source Seed
    const fsList = [];
    inventoryBatchList.forEach((inv) => {
      const fsId = uuidv4();
      fsList.push({ id: fsId, invId: inv.id });
      db.run(
        'INSERT INTO fulfillment_source (fulfillment_source_id, source_type, source_name, inventory_batch_id) VALUES (?, ?, ?, ?)',
        [fsId, 'Aggregator', 'Main Warehouse Source', inv.id]
      );
    });

    // Order Allocation Seed
    orderItemList.forEach((oi, idx) => {
      if (fsList[0]) {
        db.run(
          'INSERT INTO order_allocation (allocation_id, order_item_id, fulfillment_source_id, source_type, source_id, allocated_quantity_kg, unit_price, subtotal) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
          [uuidv4(), oi.id, fsList[0].id, 'Warehouse', inventoryBatchList[0].id, 20.0, 40.0, 800.0]
        );
      }
    });

    // Order Tracking Seed
    orderList.forEach((ord) => {
      db.run(
        'INSERT INTO order_tracking (tracking_id, order_id, status, remarks) VALUES (?, ?, ?, ?)',
        [uuidv4(), ord.id, 'Confirmed', 'Order confirmed by aggregator, awaiting packaging.']
      );
    });

    // Delivery Partner Seed
    const dpList = [];
    deliveryUsers.forEach((du, idx) => {
      const dpId = uuidv4();
      dpList.push({ id: dpId, partyId: du.partyId });
      db.run(
        'INSERT INTO delivery_partner (delivery_partner_id, party_id, partner_code, rating, kyc_status, bank_account_id, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [dpId, du.partyId, `DEL00${idx + 1}`, 4.8 + idx * 0.1, 'Approved', 'ACC456123789', 1]
      );
    });

    // Vehicle Seed
    dpList.forEach((dp, idx) => {
      db.run(
        'INSERT INTO vehicle (vehicle_id, delivery_partner_id, vehicle_type, vehicle_no, capacity_kg, current_load_kg) VALUES (?, ?, ?, ?, ?, ?)',
        [uuidv4(), dp.id, idx === 0 ? 'Motorcycle' : 'Mini Truck', `KA-03-HA-450${idx}`, idx === 0 ? 100.0 : 800.0, 0.0]
      );
    });

    // Deliveries Seed
    const deliveryList = [];
    orderList.forEach((ord, idx) => {
      const delId = uuidv4();
      deliveryList.push({ id: delId, orderId: ord.id });
      db.run(
        'INSERT INTO delivery (delivery_id, order_id, delivery_type, delivery_status, scheduled_delivery_date, delivery_charge) VALUES (?, ?, ?, ?, ?, ?)',
        [delId, ord.id, 'Drop', 'Assigned', '2026-07-03 14:00:00', 40.0]
      );
    });

    // Delivery Assignment Seed
    deliveryList.forEach((del, idx) => {
      if (dpList[idx % dpList.length]) {
        db.run(
          'INSERT INTO delivery_assignment (assignment_id, delivery_id, delivery_partner_id, status, earning_amount) VALUES (?, ?, ?, ?, ?)',
          [uuidv4(), del.id, dpList[idx % dpList.length].id, 'Assigned', 35.0]
        );
      }
    });

    // Delivery Route Seed
    deliveryList.forEach((del) => {
      db.run(
        'INSERT INTO delivery_route (route_id, delivery_id, sequence_no, stop_location_id, stop_type, estimated_time) VALUES (?, ?, ?, ?, ?, ?)',
        [uuidv4(), del.id, 1, locations[3].id, 'Pickup', '20 mins']
      );
      db.run(
        'INSERT INTO delivery_route (route_id, delivery_id, sequence_no, stop_location_id, stop_type, estimated_time) VALUES (?, ?, ?, ?, ?, ?)',
        [uuidv4(), del.id, 2, locations[1].id, 'Drop', '45 mins']
      );
    });

    // Delivery Proof Seed
    deliveryList.forEach((del) => {
      db.run(
        'INSERT INTO delivery_proof (proof_id, delivery_id, proof_type, otp_verified, remarks) VALUES (?, ?, ?, ?, ?)',
        [uuidv4(), del.id, 'OTP', 'Y', 'Delivered securely to gate manager.']
      );
    });

    // Payments Seed
    const paymentList = [];
    orderList.forEach((ord, idx) => {
      const payId = uuidv4();
      paymentList.push({ id: payId, orderId: ord.id });
      db.run(
        'INSERT INTO payment (payment_id, order_id, amount, payment_method, gateway_name, transaction_id, payment_status) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [payId, ord.id, 790.0 + idx * 100, 'UPI', 'Razorpay', `TXN88990022${idx}`, 'Success']
      );
    });

    // Settlements Seed
    const settlementList = [];
    paymentList.forEach((pay) => {
      const setId = uuidv4();
      settlementList.push({ id: setId, payId: pay.id });
      db.run(
        'INSERT INTO settlement (settlement_id, settlement_type, payment_id, status, settlement_date) VALUES (?, ?, ?, ?, ?)',
        [setId, 'Order Settlement', pay.id, 'Processed', '2026-07-02 10:00:00']
      );
    });

    // Settlement Details Seed
    settlementList.forEach((settle) => {
      db.run(
        'INSERT INTO settlement_detail (detail_id, settlement_id, entity_type, percentage, amount, remarks) VALUES (?, ?, ?, ?, ?, ?)',
        [uuidv4(), settle.id, 'Farmer', 80.0, 640.0, 'Farmer produce share']
      );
      db.run(
        'INSERT INTO settlement_detail (detail_id, settlement_id, entity_type, percentage, amount, remarks) VALUES (?, ?, ?, ?, ?, ?)',
        [uuidv4(), settle.id, 'Platform', 15.0, 120.0, 'Platform commission']
      );
      db.run(
        'INSERT INTO settlement_detail (detail_id, settlement_id, entity_type, percentage, amount, remarks) VALUES (?, ?, ?, ?, ?, ?)',
        [uuidv4(), settle.id, 'GST', 5.0, 40.0, 'CGST + SGST tax dues']
      );
    });

    // Carts Seed
    const cartList = [];
    customerList.forEach((c) => {
      const cartId = uuidv4();
      cartList.push({ id: cartId, custId: c.id });
      db.run('INSERT INTO cart (cart_id, customer_id) VALUES (?, ?)', [cartId, c.id]);
    });

    // Cart Items Seed
    cartList.forEach((cart) => {
      db.run(
        'INSERT INTO cart_item (cart_item_id, cart_id, crop_id, quantity, unit_price) VALUES (?, ?, ?, ?, ?)',
        [uuidv4(), cart.id, crops[0].id, 5.0, 120.0]
      );
      db.run(
        'INSERT INTO cart_item (cart_item_id, cart_id, crop_id, quantity, unit_price) VALUES (?, ?, ?, ?, ?)',
        [uuidv4(), cart.id, crops[1].id, 2.0, 50.0]
      );
    });

    // Wishlist Seed
    customerList.forEach((c) => {
      db.run('INSERT INTO wishlist (wishlist_id, customer_id, crop_id) VALUES (?, ?, ?)', [uuidv4(), c.id, crops[3].id]);
    });

    // Reviews Seed
    customerList.forEach((c, idx) => {
      db.run(
        'INSERT INTO review (review_id, crop_id, customer_id, rating, review_text) VALUES (?, ?, ?, ?, ?)',
        [uuidv4(), crops[2].id, c.id, 5, 'Super fresh and sweet tomatoes! Highly recommend.']
      );
    });

    // Coupon Usages Seed
    orderList.forEach((ord) => {
      db.run(
        'INSERT INTO coupon_usage (usage_id, coupon_id, order_id, discount_amount) VALUES (?, ?, ?, ?)',
        [uuidv4(), couponId, ord.id, 50.0]
      );
    });

    // Notifications Seed
    usersList.forEach((u) => {
      const notifId = uuidv4();
      db.run(
        'INSERT INTO notification (notification_id, user_id, title, message, is_read, is_delivered) VALUES (?, ?, ?, ?, ?, ?)',
        [notifId, u.id, 'Welcome to AgriLink!', 'Explore our intelligent agricultural marketplace.', 'N', 'Y'],
        (err) => {
          if (!err) {
            db.run(
              'INSERT INTO notification_status (status_id, notification_id, device_id, status) VALUES (?, ?, ?, ?)',
              [uuidv4(), notifId, 'DEV-112233', 'Delivered']
            );
          }
        }
      );
    });

    // Price History Seed
    crops.forEach((c) => {
      db.run(
        'INSERT INTO price_history (price_history_id, crop_id, old_price, new_price, source) VALUES (?, ?, ?, ?, ?)',
        [uuidv4(), c.id, 35.0, 40.0, 'Demand']
      );
      db.run(
        'INSERT INTO price_history (price_history_id, crop_id, old_price, new_price, source) VALUES (?, ?, ?, ?, ?)',
        [uuidv4(), c.id, 40.0, 45.0, 'Prediction']
      );
    });

    // ML Price Prediction Seed
    crops.forEach((c) => {
      db.run(
        'INSERT INTO ml_price_prediction (prediction_id, crop_id, predicted_price, factors, effective_from, effective_to) VALUES (?, ?, ?, ?, ?, ?)',
        [uuidv4(), c.id, 48.0, 'Season: Monsoon, Demand: High, Festival: Gowri-Ganesha', '2026-07-01 00:00:00', '2026-07-31 23:59:59']
      );
    });

    // Returns Seed
    const returnList = [];
    orderList.forEach((ord) => {
      const retId = uuidv4();
      returnList.push({ id: retId, orderId: ord.id });
      db.run(
        'INSERT INTO returns (return_id, order_id, reason, status) VALUES (?, ?, ?, ?)',
        [retId, ord.id, 'Damaged during delivery Transit', 'Requested']
      );
    });

    // Return Item Seed
    returnList.forEach((ret, idx) => {
      if (orderItemList[0]) {
        db.run(
          'INSERT INTO return_item (return_item_id, return_id, order_item_id, quantity, refund_amount) VALUES (?, ?, ?, ?, ?)',
          [uuidv4(), ret.id, orderItemList[0].id, 2.0, 80.0]
        );
      }
    });

    // Refund Seed
    returnList.forEach((ret) => {
      db.run(
        'INSERT INTO refund (refund_id, return_id, amount, refund_method, status) VALUES (?, ?, ?, ?, ?)',
        [uuidv4(), ret.id, 80.0, 'UPI Refund', 'Pending']
      );
    });

    // Inventory Movements Seed
    inventoryBatchList.forEach((inv) => {
      db.run(
        'INSERT INTO inventory_movement (movement_id, inventory_batch_id, movement_type, quantity_kg, reference_type, performed_by) VALUES (?, ?, ?, ?, ?, ?)',
        [uuidv4(), inv.id, 'IN', 500.0, 'Procurement', usersList[0].id]
      );
    });

    // Inventory Adjustments Seed
    inventoryBatchList.forEach((inv) => {
      db.run(
        'INSERT INTO inventory_adjustment (adjustment_id, inventory_batch_id, adjustment_type, quantity_kg, reason, performed_by, approved_by, remarks) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [uuidv4(), inv.id, 'Spoilage', 5.0, 'High moisture content spoilage', usersList[0].id, usersList[0].id, 'Disposed safely.']
      );
    });

    // Expiry Alerts Seed
    inventoryBatchList.forEach((inv) => {
      db.run(
        'INSERT INTO batch_expiry_alert (alert_id, inventory_batch_id, alert_type, notified_to, status) VALUES (?, ?, ?, ?, ?)',
        [uuidv4(), inv.id, 'Expiring Soon', usersList[0].id, 'Unread']
      );
    });

    console.log('🎉 Seeding successfully completed!');
  });
});

// Close database connection
db.close((err) => {
  if (err) {
    console.error('❌ Error closing database:', err.message);
  } else {
    console.log('✅ Database connection closed.');
  }
});
