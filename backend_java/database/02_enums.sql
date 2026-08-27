-- ============================================================
-- 02_enums.sql
-- AgriLink domain value definitions & constraints documentation
-- ============================================================

-- Domain value specifications:
-- User Status: 'Active', 'Inactive'
-- Party Type: 'Customer', 'Farmer', 'Aggregator', 'Delivery Partner', 'Admin'
-- KYC Status: 'Pending', 'Approved', 'Rejected'
-- Quality Status: 'Pending', 'Passed', 'Failed'
-- Order Status: 'Placed', 'Confirmed', 'Processing', 'OutForDelivery', 'Delivered', 'Cancelled'
-- Payment Status: 'Pending', 'Paid', 'Failed', 'Refunded'
-- Payment Method: 'COD', 'UPI', 'Card', 'NetBanking', 'Wallet'
-- Delivery Status: 'Assigned', 'Accepted', 'PickedUp', 'InTransit', 'Delivered'
-- Grade: 'A', 'B', 'C'
-- Discount Type: 'Fixed', 'Percent'

SELECT 'Domain enums documented and enforced via CHECK constraints.' AS status;
