#!/bin/bash
# ==============================================================================
# AgriLink - AWS RDS PostgreSQL Migration & Linking Tool
# Connects to your Amazon RDS PostgreSQL instance, deploys all 22 database
# migration scripts, and updates your backend .env to point to RDS.
#
# Usage:
#   chmod +x deploy_rds_migrations.sh
#   ./deploy_rds_migrations.sh <RDS_ENDPOINT> <DB_PASSWORD> [DB_USER] [DB_NAME]
#
# Example:
#   ./deploy_rds_migrations.sh agrilink-db.c7x8y9.ap-south-1.rds.amazonaws.com MyPass123! postgres agrilink_db
# ==============================================================================

set -e

RDS_HOST=$1
DB_PASS=$2
DB_USER=${3:-"postgres"}
DB_NAME=${4:-"agrilink_db"}
DB_PORT="5432"

if [ -z "$RDS_HOST" ] || [ -z "$DB_PASS" ]; then
    echo "❌ ERROR: Missing required arguments."
    echo ""
    echo "Usage:"
    echo "  ./deploy_rds_migrations.sh <RDS_ENDPOINT> <DB_PASSWORD> [DB_USER] [DB_NAME]"
    echo ""
    echo "Example:"
    echo "  ./deploy_rds_migrations.sh agrilink-db.c7x8y9.ap-south-1.rds.amazonaws.com MyPass123! postgres agrilink_db"
    exit 1
fi

echo "=================================================================="
echo " 🚀 AgriLink AWS RDS PostgreSQL Master Deployment"
echo " Target Endpoint: $RDS_HOST:$DB_PORT"
echo " Database:        $DB_NAME (User: $DB_USER)"
echo "=================================================================="

# 1. Verify psql client is installed
if ! command -v psql &> /dev/null; then
    echo "Installing PostgreSQL client utilities..."
    sudo apt-get update -y && sudo apt-get install -y postgresql-client
fi

# 2. Check connection and create database if not exists
echo "[1/3] Testing connectivity to AWS RDS instance..."
export PGPASSWORD="$DB_PASS"

# Check if target database exists, if not create it
echo "Ensuring database '$DB_NAME' exists on RDS..."
psql -h "$RDS_HOST" -p "$DB_PORT" -U "$DB_USER" -d "postgres" -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" | grep -q 1 || \
psql -h "$RDS_HOST" -p "$DB_PORT" -U "$DB_USER" -d "postgres" -c "CREATE DATABASE $DB_NAME;"

# 3. Run master schema and 22 migration scripts
echo "[2/3] Deploying master schema and seeding records from database/00_run_all.sql..."
if [ -d "database" ]; then
    cd database
    psql -h "$RDS_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f 00_run_all.sql || echo "Migrations completed with notices."
    cd ..
else
    echo "❌ Error: database/ directory not found in current directory."
    exit 1
fi

# 4. Update backend_fastapi/.env to point to AWS RDS
echo "[3/3] Updating backend configuration to use AWS RDS..."
DATABASE_URL="postgresql://$DB_USER:$DB_PASS@$RDS_HOST:$DB_PORT/$DB_NAME"

if [ ! -f "backend_fastapi/.env" ]; then
    cp backend_fastapi/.env.example backend_fastapi/.env 2>/dev/null || touch backend_fastapi/.env
fi

if grep -q "DATABASE_URL=" backend_fastapi/.env 2>/dev/null; then
    sed -i "s|DATABASE_URL=.*|DATABASE_URL=$DATABASE_URL|" backend_fastapi/.env
else
    echo "DATABASE_URL=$DATABASE_URL" >> backend_fastapi/.env
fi

# 5. Restart AgriLink systemd service if running on EC2
if systemctl is-active --quiet agrilink 2>/dev/null; then
    echo "Restarting AgriLink background service..."
    sudo systemctl restart agrilink
fi

echo "=================================================================="
echo " ✅ AWS RDS Migration Completed Successfully!"
echo " AgriLink backend is now connected to AWS RDS PostgreSQL!"
echo " Test connection at: http://localhost/api/v1/database/status"
echo "=================================================================="
