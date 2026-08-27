-- ============================================================
-- 01_user_queries.sql
-- User, Role, Party, and Authentication Verification Queries
-- ============================================================

-- Q1.1: List all active users with their assigned role and party details (BR-A001, BR-A002)
SELECT 
    u.user_id,
    u.phone,
    u.email,
    r.role_name,
    p.party_type,
    p.kyc_status,
    u.status AS user_status
FROM users u
JOIN role r ON u.role_id = r.role_id
JOIN party p ON u.user_id = p.user_id
WHERE u.status = 'Active'
ORDER BY r.role_name, u.created_at DESC;

-- Q1.2: Count of registered users grouped by Role and KYC Status (BR-A008, BR-A021)
SELECT 
    r.role_name,
    p.kyc_status,
    COUNT(u.user_id) AS total_users
FROM users u
JOIN role r ON u.role_id = r.role_id
JOIN party p ON u.user_id = p.user_id
GROUP BY r.role_name, p.kyc_status
ORDER BY r.role_name;

-- Q1.3: Verify party single business entity mapping (BR-A003)
SELECT 
    p.party_id,
    p.party_type,
    f.farmer_id,
    c.customer_id,
    a.aggregator_id,
    dp.delivery_partner_id
FROM party p
LEFT JOIN farmer f ON p.party_id = f.party_id
LEFT JOIN customer c ON p.party_id = c.party_id
LEFT JOIN aggregator a ON p.party_id = a.party_id
LEFT JOIN delivery_partner dp ON p.party_id = dp.party_id;
