# Grafana Setup with Docker and Envoy Proxy

Complete Docker-based Grafana deployment with automated SSL/TLS certificates using Let's Encrypt and Envoy as a reverse proxy.

## 🏗️ Architecture

```
Internet → Envoy Proxy (Port 443/SSL) → Grafana (Port 3000)
           ↳ (Port 80 → Auto-redirect to HTTPS)
```

## ✨ Features

- 🐳 **Docker-based** - Easy deployment and management
- 🔒 **Automated SSL/TLS** - Let's Encrypt certificates with auto-renewal
- 🚀 **Envoy Proxy** - High-performance reverse proxy
- 🔄 **HTTP to HTTPS** - Automatic redirect
- 📦 **One-line setup** - Automated deployment script

## 📁 Directory Structure

```
grafana-setup/
├── docker-envoy-no-ssl/        # Basic setup without SSL
│   ├── docker-compose.yaml
│   ├── envoy/envoy.yaml
│   └── README.md
│
└── docker-envoy-with-ssl/      # Production setup with SSL (Recommended)
    ├── setup.sh                # Automated setup script
    ├── docker-compose.yaml
    ├── envoy/envoy.yaml
    └── README.md
```

## 🚀 Quick Start

### Option 1: With SSL/TLS (Recommended for Production)

**Prerequisites:**
- Amazon Linux 2023 (or RHEL-based distribution)
- Domain name with DNS configured
- Ports 80 and 443 open

**Deploy:**
```bash
# Clone the repository
git clone https://github.com/shamimice03/grafana-setup.git
cd grafana-setup/docker-envoy-with-ssl

# Run the setup script
sudo ./setup.sh your-domain.com your@email.com [YourSecurePassword]
```

**What it does:**
1. Installs Docker and Docker Compose
2. Installs Certbot
3. Obtains SSL/TLS certificate from Let's Encrypt
4. Configures Envoy with your domain
5. Sets up Grafana with proper permissions
6. Starts all services

**Access Grafana:**
- URL: `https://your-domain.com`
- Username: `admin`
- Password: As configured (default: `Admin@123`)

### Option 2: Without SSL (For Testing/Development)

```bash
cd docker-envoy-no-ssl
docker-compose up -d
```

Access Grafana at `http://localhost`

## 📖 Documentation

- **[With SSL Setup](docker-envoy-with-ssl/README.md)** - Complete guide with SSL/TLS
- **[Without SSL Setup](docker-envoy-no-ssl/README.md)** - Basic setup for testing

## 🖥️ EC2 User Data Script

For automated EC2 deployment, use this as user data:

```bash
#!/bin/bash
set -e

DOMAIN="grafana-oss.stg.cloudterms.net"
EMAIL="your@email.com"
GRAFANA_ADMIN_PASSWORD="YourSecurePassword"

# Install git
sudo dnf install git -y

# Clone the repository
sudo git clone https://github.com/shamimice03/grafana-setup.git

# Change to the directory and run setup
cd grafana-setup/docker-envoy-with-ssl
sudo bash setup.sh $DOMAIN $EMAIL $GRAFANA_ADMIN_PASSWORD
```

## 🔧 Configuration

### SSL/TLS Setup (docker-envoy-with-ssl/)

**Command-line arguments:**
```bash
sudo ./setup.sh <DOMAIN> <EMAIL> [ADMIN_PASSWORD]
```

**Examples:**
```bash
# Default admin password
sudo ./setup.sh grafana.example.com admin@example.com

# Custom admin password
sudo ./setup.sh grafana.example.com admin@example.com MySecurePass123
```

### No SSL Setup (docker-envoy-no-ssl/)

Edit `docker-compose.yaml` to change the Grafana admin password:

```yaml
environment:
  - GF_SECURITY_ADMIN_PASSWORD=Admin@123  # Change this
  - GF_USERS_ALLOW_SIGN_UP=false
```

## 🔐 Security Features

- ✅ Automated SSL/TLS certificates
- ✅ HTTP to HTTPS redirect
- ✅ Secure certificate permissions
- ✅ Configurable admin password
- ✅ Envoy as reverse proxy

## 🔄 Certificate Renewal

Let's Encrypt certificates are valid for 90 days. Setup auto-renewal:

```bash
# Add to crontab
crontab -e

# Add this line for daily renewal check at 3 AM
0 3 * * * certbot renew --quiet --post-hook "docker-compose -f /var/lib/grafana-proxy/docker-compose.yaml restart envoy"
```

## 🛠️ Management Commands

```bash
# View logs
sudo docker-compose -f /var/lib/grafana-proxy/docker-compose.yaml logs -f

# Restart services
sudo docker-compose -f /var/lib/grafana-proxy/docker-compose.yaml restart

# Stop services
sudo docker-compose -f /var/lib/grafana-proxy/docker-compose.yaml down

# Check certificate status
sudo certbot certificates
```

## 📋 Requirements

### For SSL Setup
- Amazon Linux 2023 or compatible RHEL-based distribution
- Root/sudo access
- Domain name with DNS configured
- Ports 80 and 443 open in firewall/security group

### For Non-SSL Setup
- Docker and Docker Compose
- Ports 80 available

## 🐛 Troubleshooting

### Container won't start
```bash
# Check logs
sudo docker-compose logs -f

# Verify configuration
sudo docker run --rm -v /var/lib/grafana-proxy/envoy/envoy.yaml:/etc/envoy/envoy.yaml envoyproxy/envoy:v1.28-latest envoy --mode validate
```

### Certificate issues
```bash
# Check certificate
sudo certbot certificates

# Re-obtain certificate
sudo certbot certonly --standalone --force-renewal -d your-domain.com
```

### Permission errors
```bash
# Fix certificate permissions
sudo chmod 755 /etc/letsencrypt/live /etc/letsencrypt/archive
sudo chmod 755 /etc/letsencrypt/live/your-domain.com
sudo chmod 644 /etc/letsencrypt/archive/your-domain.com/*.pem
```

## 📚 Documentation Links

- [Grafana Documentation](https://grafana.com/docs/)
- [Envoy Proxy Documentation](https://www.envoyproxy.io/docs/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Docker Documentation](https://docs.docker.com/)

## 📝 License

This setup is provided as-is for deployment convenience.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## ⭐ Support

For issues and questions:
- Check the README in each directory
- Review the troubleshooting section
- Open an issue on GitHub

---

**Made with ❤️ for easy Grafana deployment**
