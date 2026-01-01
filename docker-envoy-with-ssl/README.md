# Grafana with Docker, Envoy, and SSL/TLS

Complete setup for running Grafana behind an Envoy reverse proxy with **automated SSL/TLS certificates** from Let's Encrypt.

## Architecture

```
Internet → Envoy (Port 443/SSL) → Grafana (Port 3000)
           ↳ (Port 80 → Redirects to 443)
```

## Prerequisites

- **Amazon Linux 2023** or compatible RHEL-based distribution
- Root/sudo access
- Domain name with DNS configured to point to your server
- Ports 80 and 443 open in your security group/firewall

## Quick Start

### Automated Setup (Recommended)

Run the setup script with your configuration:

```bash
# Basic usage (default admin password)
sudo ./setup.sh your-domain.com your@email.com

# With custom admin password
sudo ./setup.sh your-domain.com your@email.com YourSecurePassword
```

**What the script does:**
1. Installs Docker and Docker Compose
2. Installs Certbot
3. Obtains SSL/TLS certificate from Let's Encrypt
4. Sets up Grafana data directory
5. Copies files to `/var/lib/grafana-proxy/`
6. Configures Envoy with your domain
7. Sets up proper certificate permissions
8. Starts all services

### Command-Line Arguments

```bash
sudo ./setup.sh <DOMAIN> <EMAIL> [ADMIN_PASSWORD]

Arguments:
  DOMAIN              Your domain name (required)
  EMAIL               Email for Let's Encrypt notifications (required)
  ADMIN_PASSWORD      Grafana admin password (optional, default: Admin@123)

Examples:
  sudo ./setup.sh grafana.example.com admin@example.com
  sudo ./setup.sh grafana.example.com admin@example.com MySecurePass123
```

## Configuration

Edit `docker-compose.yaml`:

```yaml
environment:
  - GF_SECURITY_ADMIN_PASSWORD=${ADMIN_PASSWORD}  # Set via --admin_pass flag
  - GF_USERS_ALLOW_SIGN_UP=false
```

## Accessing Grafana

After setup:

- **URL**: `https://your-domain.com`
- **Username**: `admin`
- **Password**: As configured (default: `Admin@123`)

## Files

- `setup.sh` - Automated setup script
- `docker-compose.yaml` - Service orchestration
- `envoy/envoy.yaml` - Envoy proxy configuration template

## Deployment Directory Structure

```
/var/lib/grafana-proxy/          # Deployment directory
├── docker-compose.yaml          # Service configuration
├── envoy/
│   └── envoy.yaml               # Envoy proxy config
└── setup.sh                     # Setup script

/etc/letsencrypt/                # SSL certificates
└── live/
    └── your-domain.com/
        ├── fullchain.pem        # Certificate chain
        └── privkey.pem          # Private key

/var/lib/grafana/data/           # Grafana data persistence
```

## Deployment Directory

The setup script deploys everything to `/var/lib/grafana-proxy/`:

```bash
# Working from deployment directory
cd /var/lib/grafana-proxy
```

## Certificate Renewal

Let's Encrypt certificates are valid for 90 days. Setup a renewal cron job:

```bash
# Add to crontab (crontab -e)
0 3 * * * certbot renew --quiet --post-hook "docker-compose -f /var/lib/grafana-proxy/docker-compose.yaml restart envoy"
```

## Management Commands

```bash
# View logs
sudo docker-compose -f /var/lib/grafana-proxy/docker-compose.yaml logs -f

# Restart services
sudo docker-compose -f /var/lib/grafana-proxy/docker-compose.yaml restart

# Stop services
sudo docker-compose -f /var/lib/grafana-proxy/docker-compose.yaml down

# Start services
sudo docker-compose -f /var/lib/grafana-proxy/docker-compose.yaml up -d

# Check certificate status
sudo certbot certificates
```

## Security Features

- ✅ Automated SSL/TLS with Let's Encrypt
- ✅ HTTP to HTTPS redirect
- ✅ Secure certificate permissions
- ✅ Envoy as reverse proxy
- ✅ Configurable admin password

## Troubleshooting

### Envoy fails to start - certificate error

```bash
# Check certificate permissions
ls -la /etc/letsencrypt/live/your-domain.com/

# Fix permissions
sudo chmod 755 /etc/letsencrypt/live/your-domain.com
sudo chmod 644 /etc/letsencrypt/archive/your-domain.com/*.pem
```

### Certificate not found

```bash
# Verify certificate exists
sudo certbot certificates

# Re-obtain certificate if needed
sudo certbot certonly --standalone -d your-domain.com --force-renewal
```

### Port 80/443 already in use

```bash
# Check what's using the ports
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443

# Stop conflicting services (e.g., nginx, apache)
sudo systemctl stop nginx
```

### Container won't start

```bash
# Check container logs
sudo docker-compose -f /var/lib/grafana-proxy/docker-compose.yaml logs envoy
sudo docker-compose -f /var/lib/grafana-proxy/docker-compose.yaml logs grafana

# Verify Envoy configuration
sudo docker run --rm -v /var/lib/grafana-proxy/envoy/envoy.yaml:/etc/envoy/envoy.yaml envoyproxy/envoy:v1.28-latest envoy --mode validate
```

## Customization

### Change Domain or Password

Re-run the setup script with new values:

```bash
# Change domain
sudo ./setup.sh new-domain.com your@email.com

# Change admin password
sudo ./setup.sh your-domain.com your@email.com NewPassword123
```

### Modify Envoy Configuration

Edit `/var/lib/grafana-proxy/envoy/envoy.yaml` and restart:

```bash
sudo docker-compose -f /var/lib/grafana-proxy/docker-compose.yaml restart envoy
```

## Production Checklist

Before deploying to production:

- [ ] Change default admin password
- [ ] Configure firewall/security groups (ports 80, 443)
- [ ] Setup certificate renewal cron job
- [ ] Configure Grafana backups (backup `/var/lib/grafana/data`)
- [ ] Monitor certificate expiration
- [ ] Review and update Envoy configuration for your needs
- [ ] Setup monitoring/alerting

## Performance Tuning

### Grafana Resources

Edit `docker-compose.yaml` to add resource limits:

```yaml
services:
  grafana:
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
```

## Pass it as  EC2 user-data
```bash
#!/bin/bash
set -e

DOMAIN="grafana-oss.stg.cloudterms.net"
EMAIL="shamimice03@gmail.com"
GRAFANA_ADMIN_PASSWORD="Shamimice@03"

# Install git
sudo dnf install git -y

# Clone the repository
sudo git clone https://github.com/shamimice03/grafana-setup.git

# Change to the directory and run setup (cd doesn't need sudo)
cd grafana-setup/docker-envoy-with-ssl
sudo bash setup.sh $DOMAIN $EMAIL $GRAFANA_ADMIN_PASSWORD
```

## Support and Documentation

- [Grafana Documentation](https://grafana.com/docs/)
- [Envoy Documentation](https://www.envoyproxy.io/docs/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)

## License

This setup script is provided as-is for deployment convenience.

