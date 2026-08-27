-- ============================================================
-- 01_extensions.sql
-- Enable required PostgreSQL extensions
-- Run this FIRST as superuser
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

SELECT name, default_version, installed_version, comment
FROM pg_available_extensions
WHERE name IN ('uuid-ossp', 'pgcrypto', 'pg_trgm')
ORDER BY name;
