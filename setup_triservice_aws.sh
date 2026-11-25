#!/bin/bash
# ==============================================================================
# AgriLink Tri-Service AWS Production Integration Script
# ==============================================================================
# Run this ONCE on your AgriLink EC2 instance (where M1 is deployed).
# It will:
#   1. Add the 3 inter-service env vars to backend_fastapi/.env
#   2. Run the additive migration (25_triservice_integration.sql) on RDS
#   3. Restart the agrilink systemd service
#
# Usage:
#   chmod +x setup_triservice_aws.sh
#   ./setup_triservice_aws.sh \
#       <AGRILINK_RDS_ENDPOINT> <AGRILINK_RDS_PASSWORD> \
#       <CITIZEN_AWS_URL> <RTO_AWS_URL> <INTERNAL_SECRET>
#
# Example:
#   ./setup_triservice_aws.sh \
#       agrilink-db.xxxxxx.ap-south-1.rds.amazonaws.com MyRdsPwd123! \
#       http://ec2-1-2-3-4.ap-south-1.compute.amazonaws.com \
#       http://ec2-5-6-7-8.ap-south-1.compute.amazonaws.com \
#       my-shared-internal-secret-32chars
# ==============================================================================

set -e

RDS_HOST="${1:?Usage: $0 <RDS_HOST> <RDS_PASS> <CITIZEN_URL> <RTO_URL> <SECRET>}"
RDS_PASS="${2:?Missing RDS password}"
CITIZEN_URL="${3:?Missing Citizen (M2) AWS URL}"
RTO_URL="${4:?Missing RTO Vehicle (M3) AWS URL}"
INTERNAL_SECRET="${5:?Missing INTERNAL_SERVICE_SECRET}"

DB_USER="${DB_USER:-postgres}"
DB_NAME="${DB_NAME:-agrilink_db}"
DB_PORT="5432"

CITIZEN_API_URL="${CITIZEN_URL%/}/api/v1"
RTO_API_URL="${RTO_URL%/}/v1"

ENV_FILE="backend_fastapi/.env"

echo "=================================================================="
echo "  AgriLink Tri-Service AWS Integration Setup"
echo "=================================================================="
echo "  AgriLink RDS:   $RDS_HOST"
echo "  Citizen (M2):   $CITIZEN_API_URL"
echo "  RTO M3:         $RTO_API_URL"
echo "=================================================================="

# ── 1. Verify .env exists ────────────────────────────────────────────────────
if [ ! -f "$ENV_FILE" ]; then
    echo "Creating $ENV_FILE from .env.example..."
    cp backend_fastapi/.env.example "$ENV_FILE" 2>/dev/null || touch "$ENV_FILE"
fi

# ── 2. Write / update tri-service env vars ────────────────────────────────────
update_env() {
    local KEY="$1" VAL="$2"
    if grep -q "^${KEY}=" "$ENV_FILE" 2>/dev/null; then
        sed -i "s|^${KEY}=.*|${KEY}=${VAL}|" "$ENV_FILE"
        echo "  Updated  $KEY"
    else
        echo "${KEY}=${VAL}" >> "$ENV_FILE"
        echo "  Added    $KEY"
    fi
}

echo ""
echo "[1/3] Writing inter-service config to $ENV_FILE ..."
update_env "CITIZEN_SERVICE_URL" "$CITIZEN_API_URL"
update_env "RTO_SERVICE_URL" "$RTO_API_URL"
update_env "INTERNAL_SERVICE_SECRET" "$INTERNAL_SECRET"
update_env "INTER_SERVICE_TIMEOUT" "5.0"

# ── 3. Run additive migration on AgriLink RDS ─────────────────────────────────
echo ""
echo "[2/3] Running additive tri-service migration (25_triservice_integration.sql) on RDS..."

if [ ! -f "database/25_triservice_integration.sql" ]; then
    echo "ERROR: database/25_triservice_integration.sql not found. Run from agrilink_github root."
    exit 1
fi

export PGPASSWORD="$RDS_PASS"
psql -h "$RDS_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
     -f database/25_triservice_integration.sql \
  && echo "  Migration applied successfully." \
  || echo "  Migration completed (some notices may be expected — IF NOT EXISTS is safe)."

# ── 4. Restart AgriLink service ───────────────────────────────────────────────
echo ""
echo "[3/3] Restarting AgriLink systemd service..."
if systemctl is-active --quiet agrilink 2>/dev/null; then
    sudo systemctl restart agrilink
    sleep 2
    sudo systemctl is-active agrilink && echo "  agrilink.service restarted OK." || echo "  WARNING: service did not restart cleanly."
else
    echo "  agrilink.service not running (run 'sudo systemctl start agrilink' or restart manually)."
fi

echo ""
echo "=================================================================="
echo "  DONE. Verify the integration at:"
echo "    GET <your-agrilink-url>/api/v1/ecosystem/status"
echo "=================================================================="
