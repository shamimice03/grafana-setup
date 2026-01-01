#!/bin/bash

set -e

DOMAIN="grafana.stg.cloudterms.net"

# Install Certbot for SSL certificate management
sudo dnf install -y certbot

# Requesting certificates from Let's Encrypt
sudo certbot certonly --webroot \
  -w /var/www/certbot \
  -d grafana.stg.cloudterms.net

# Create the directory with sudo
sudo mkdir -p /opt/grafana/data
# Change ownership to the grafana user's UID (472) and GID (472)
sudo chown -R 472:472 /opt/grafana/data


# Create the main directory for grafana-proxy if it doesn't exist, 
sudo mkdir -p /var/lib/grafana-proxy/

# Copy everything from the current directory to the new location
sudo cp -r . /var/lib/grafana-proxy/

# Move to the grafana-proxy directory
cd /var/lib/grafana-proxy/

# Check if docker-compose.yml exists in the target directory
if [ ! -f docker-compose.yaml ]; then
    echo "Error: docker-compose.yml not found in /var/lib/grafana-proxy/"
    exit 1
fi

# check if ./envoy/envoy.yaml exists
if [ ! -f ./envoy/envoy.yaml ]; then
    echo "Error: envoy.yaml not found in /var/lib/grafana-proxy/envoy/"
    exit 1
fi

docker-compose up -d