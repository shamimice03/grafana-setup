# Grafana with Docker and Envoy (No SSL)

Simple Docker Compose setup for running Grafana behind an Envoy reverse proxy **without SSL/TLS**.

## Architecture

```
Internet → Envoy (Port 80) → Grafana (Port 3000)
```

## Prerequisites

- Docker
- Docker Compose

## Quick Start

1. **Start the services:**
   ```bash
   docker-compose up -d
   ```

2. **Access Grafana:**
   - URL: `http://localhost`
   - Default credentials:
     - Username: `admin`
     - Password: `Admin@123`

## Configuration

### Environment Variables

Edit `docker-compose.yaml` to customize:

```yaml
environment:
  - GF_SECURITY_ADMIN_PASSWORD=Admin@123  # Change this!
  - GF_USERS_ALLOW_SIGN_UP=false
```

### Ports

- **80**: Envoy proxy (HTTP)
- **3000**: Grafana (direct access, not exposed externally)

## Files

- `docker-compose.yaml` - Service orchestration
- `envoy/envoy.yaml` - Envoy proxy configuration

## Customization

### Change Grafana Admin Password

Edit the password in `docker-compose.yaml`:

```yaml
- GF_SECURITY_ADMIN_PASSWORD=YourSecurePassword
```

Then restart:
```bash
docker-compose down
docker-compose up -d
```

### Modify Envoy Configuration

Edit `envoy/envoy.yaml` and restart:

```bash
docker-compose restart envoy
```

## Management Commands

```bash
# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Restart services
docker-compose restart

# View running containers
docker-compose ps
```

## Data Persistence

Grafana data is stored in `/var/lib/grafana/data` on the host.

## Security Notes

⚠️ **This setup does not use SSL/TLS.** All traffic is unencrypted.

**For production use with SSL/TLS, see the `docker-envoy-with-ssl` directory.**

## Troubleshooting

### Grafana not accessible?

```bash
# Check container status
docker-compose ps

# Check logs
docker-compose logs grafana
docker-compose logs envoy
```

### Port 80 already in use?

Edit the port mapping in `docker-compose.yaml`:

```yaml
ports:
  - "8080:80"  # Use port 8080 instead
```

## Next Steps

- For SSL/TLS setup with Let's Encrypt certificates, see [../docker-envoy-with-ssl/](../docker-envoy-with-ssl/)
- For production deployment, always use HTTPS
