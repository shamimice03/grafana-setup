#!/bin/bash

set -e

# Configuration
DOMAIN="grafana.stg.cloudterms.net"
EMAIL="mrseeker420@gmail.com"
DEPLOY_DIR="/var/lib/grafana-proxy"

echo "================================================"
echo "Grafana + Envoy SSL Proxy Setup"
echo "Domain: $DOMAIN"
echo "================================================"

# ============================================================
# STEP 1: Install Certbot
# ============================================================
echo ""
echo "[1/5] Installing Certbot..."
sudo dnf install -y certbot

# ============================================================
# STEP 2: Stop any services using port 80
# ============================================================
echo ""
echo "[2/5] Checking for services on port 80..."
sudo systemctl stop httpd 2>/dev/null || true
sudo systemctl stop nginx 2>/dev/null || true
sudo docker stop envoy_proxy 2>/dev/null || true

# ============================================================
# STEP 3: Request SSL Certificate
# ============================================================
echo ""
echo "[3/5] Requesting SSL certificate from Let's Encrypt..."
sudo certbot certonly --standalone \
  -d $DOMAIN \
  --email $EMAIL \
  --agree-tos \
  --non-interactive

if [ $? -eq 0 ]; then
    echo "✅ Certificate obtained successfully!"
else
    echo "❌ Failed to obtain certificate. Exiting."
    exit 1
fi

# ============================================================
# STEP 4: Setup Grafana Data Directory
# ============================================================
echo ""
echo "[4/5] Setting up Grafana data directory..."
sudo mkdir -p /var/lib/grafana/data
sudo chown -R 472:472 /var/lib/grafana/data
echo "✅ Grafana data directory created"

# ============================================================
# STEP 5: Deploy with Docker Compose
# ============================================================
echo ""
echo "[5/5] Deploying services..."

# Create deployment directory
sudo mkdir -p $DEPLOY_DIR

# Copy all files to deployment directory
echo "Copying files to $DEPLOY_DIR..."
sudo cp -r . $DEPLOY_DIR/

# Navigate to deployment directory
cd $DEPLOY_DIR

# Verify required files exist
if [ ! -f docker-compose.yaml ]; then
    echo "❌ Error: docker-compose.yaml not found in $DEPLOY_DIR"
    exit 1
fi

if [ ! -f ./envoy/envoy.yaml ]; then
    echo "❌ Error: envoy.yaml not found in $DEPLOY_DIR/envoy/"
    exit 1
fi

# Start services
echo "Starting Docker containers..."
docker-compose up -d

if [ $? -eq 0 ]; then
    echo ""
    echo "================================================"
    echo "✅ Setup Complete!"
    echo "================================================"
    echo ""
    echo "Grafana is now available at:"
    echo "  🔒 https://$DOMAIN"
    echo ""
    echo "Default credentials:"
    echo "  Username: admin"
    echo "  Password: Admin@123"
    echo ""
    echo "Useful commands:"
    echo "  View logs:    cd $DEPLOY_DIR && docker-compose logs -f"
    echo "  Restart:      cd $DEPLOY_DIR && docker-compose restart"
    echo "  Stop:         cd $DEPLOY_DIR && docker-compose down"
    echo "  Status:       cd $DEPLOY_DIR && docker-compose ps"
    echo ""
else
    echo "❌ Failed to start Docker containers"
    exit 1
fi