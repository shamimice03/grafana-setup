#!/bin/bash

set -e
# Create the directory with sudo
sudo mkdir -p /opt/grafana/data

# Change ownership to the grafana user's UID (472) and GID (472)
sudo chown -R 472:472 /opt/grafana/data

# docker-compose up -d