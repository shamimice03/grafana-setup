#!/bin/bash

set -e

set -a
# Configuration
DOMAIN="grafana-oss.stg.cloudterms.net"
EMAIL="mrseeker420@gmail.com"
DEPLOY_DIR="/var/lib/grafana-proxy"
set +a  # Stop automatic export


# Install docker and compose
sudo dnf install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
sudo usermod -a -G docker ssm-user

sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
if [ ! -L /usr/bin/docker-compose ]; then
  sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
fi

# Install certbot
sudo dnf install -y certbot

# Request for certificate
sudo certbot certonly --standalone \
  -d $DOMAIN \
  --email $EMAIL \
  --agree-tos \
  --non-interactive

if [ $? -eq 0 ]; then
    echo "Certificate obtained successfully!"
else
    echo "Failed to obtain certificate. Exiting."
    exit 1
fi

# Setup grafana data directory
sudo mkdir -p /var/lib/grafana/data
sudo chown -R 472:472 /var/lib/grafana/data

# Create deployment directory
sudo mkdir -p $DEPLOY_DIR

# Copy all files to deployment directory
echo "Copying files to $DEPLOY_DIR..."
sudo cp -r . $DEPLOY_DIR/

# Navigate to deployment directory
cd $DEPLOY_DIR

# Verify required files exist
if [ ! -f docker-compose.yaml ]; then
    echo "Error: docker-compose.yaml not found in $DEPLOY_DIR"
    exit 1
fi

if [ ! -f ./envoy/envoy.yaml ]; then
    echo "Error: envoy.yaml not found in $DEPLOY_DIR/envoy/"
    exit 1
fi

# Generate envoy.yaml
echo "Configuring Envoy for domain: $DOMAIN"
sudo sed -i.bak "s|\${DOMAIN}|$DOMAIN|g" ./envoy/envoy.yaml
sudo rm -f ./envoy/envoy.yaml.bak

# Fix certificate permissions
echo "Setting certificate permissions..."
sudo chmod 644 /etc/letsencrypt/archive/$DOMAIN/privkey1.pem
sudo chmod 644 /etc/letsencrypt/archive/$DOMAIN/fullchain1.pem
sudo chmod 755 /etc/letsencrypt/archive/$DOMAIN
sudo chmod 755 /etc/letsencrypt/live/$DOMAIN

# Start services
echo "Starting Docker containers..."
sudo docker-compose up -d

if [ $? -eq 0 ]; then
    echo "Setup Complete!"
else
    echo "Failed to start Docker containers"
    exit 1
fi