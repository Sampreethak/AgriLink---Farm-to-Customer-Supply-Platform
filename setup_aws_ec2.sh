#!/bin/bash
# ==============================================================================
# AgriLink - Automated AWS EC2 Deployment Script
# Supports: Ubuntu 20.04 / 22.04 / 24.04 LTS (AWS EC2 t2.micro / t3.micro)
# ==============================================================================

set -e

echo "=========================================="
echo " Starting AgriLink AWS EC2 Automated Setup"
echo "=========================================="

# 1. Update OS packages
echo "[1/6] Updating system repositories and installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y python3-pip python3-venv git nginx curl ufw

# 2. Setup Python virtual environment
echo "[2/6] Configuring isolated Python virtual environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate

# 3. Install project dependencies
echo "[3/6] Installing Python & ML requirements..."
pip install --upgrade pip
pip install -r requirements.txt

# 4. Setup systemd service for 24/7 background execution
echo "[4/6] Configuring systemd background daemon (agrilink.service)..."
REPO_DIR=$(pwd)
CURRENT_USER=$(whoami)

# Create .env if not exists
if [ ! -f "backend_fastapi/.env" ] && [ -f "backend_fastapi/.env.example" ]; then
    cp backend_fastapi/.env.example backend_fastapi/.env
fi

sudo tee /etc/systemd/system/agrilink.service > /dev/null <<EOF
[Unit]
Description=AgriLink FastAPI Backend and ML Models Engine
After=network.target

[Service]
User=$CURRENT_USER
WorkingDirectory=$REPO_DIR
ExecStart=$REPO_DIR/venv/bin/uvicorn backend_fastapi.main:app --host 127.0.0.1 --port 8000 --workers 2
Restart=always
RestartSec=5
Environment=PYTHONPATH=$REPO_DIR

[Install]
WantedBy=multi-user.target
EOF

# 5. Configure Nginx reverse proxy (Port 80 -> Port 8000)
echo "[5/6] Configuring Nginx reverse proxy on Port 80..."
sudo tee /etc/nginx/sites-available/agrilink > /dev/null <<EOF
server {
    listen 80;
    server_name _;

    client_max_body_size 50M;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 120s;
    }
}
EOF

sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/agrilink /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# 6. Enable and start AgriLink service
echo "[6/6] Reloading and starting AgriLink systemd service..."
sudo systemctl daemon-reload
sudo systemctl enable agrilink
sudo systemctl restart agrilink

echo "=========================================="
echo " AgriLink AWS EC2 Deployment Complete!"
echo "=========================================="
echo "Service status:"
sudo systemctl status agrilink --no-pager
echo ""
echo "Test the deployment by opening in your browser:"
echo "http://$(curl -s http://checkip.amazonaws.com)/docs"
