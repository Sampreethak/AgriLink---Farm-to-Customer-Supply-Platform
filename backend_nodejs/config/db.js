// config/db.js
require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || `postgresql://${process.env.DB_USER}:${process.env.DB_PASSWORD}@${process.env.DB_HOST}:${process.env.DB_PORT}/${process.env.DB_NAME}`,
  max: parseInt(process.env.DB_POOL_MAX) || 20,
  idleTimeoutMillis: parseInt(process.env.DB_POOL_IDLE_TIMEOUT) || 30000,
  connectionTimeoutMillis: parseInt(process.env.DB_POOL_CONNECTION_TIMEOUT) || 2000,
  ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
});

// Simple wrapper for queries to log slow queries
async function query(text, params) {
  const start = Date.now();
  const res = await pool.query(text, params);
  const duration = Date.now() - start;
  const threshold = parseInt(process.env.DB_SLOW_QUERY_THRESHOLD_MS) || 1000;
  if (duration > threshold) {
    console.warn(`Slow query (${duration}ms): ${text}`);
  }
  return res;
}

module.exports = { query, pool };
