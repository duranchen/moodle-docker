# Moodle Development Environments

This project supports three distinct environments: **Development**, **Staging**, and **Production**.

## Overview

| Environment | Dockerfile | Docker Compose | Use Case | Code Location | Image Size |
|------------|-----------|----------------|----------|---------------|-----------|
| **Development** | `Dockerfile.dev` | `docker-compose.dev.yml` | Local development | Volume mount | ~1.5GB |
| **Staging** | `Dockerfile.staging` | `docker-compose.staging.yml` | Testing/Staging | Copied in image | ~600MB |
| **Production** | `Dockerfile.prod` | `docker-compose.prod.yml` | Azure deployment | Copied in image | ~400MB |

## Development Environment

**For local development with live code editing and debugging.**

### Features:
- ✅ xdebug enabled (port 9003)
- ✅ Node.js, npm, Grunt, Webpack
- ✅ Composer
- ✅ Volume mounts for live code editing
- ✅ All development tools

### Start:
```bash
docker-compose -f docker-compose.dev.yml up -d --build
```

### Access:
- **Moodle:** http://localhost
- **Database:** localhost:3306
- **Redis:** localhost:6379
- **Debugging:** Port 9003

### Logs:
```bash
docker-compose -f docker-compose.dev.yml logs -f php
```

### Stop:
```bash
docker-compose -f docker-compose.dev.yml down
```

## Staging Environment

**For staging/testing before production.**

### Features:
- ✅ Moodle code baked into image
- ✅ Opcache enabled (production-like)
- ✅ Logging enabled
- ✅ Closer to production behavior
- ❌ No xdebug

### Start:
```bash
docker-compose -f docker-compose.staging.yml up -d --build
```

### Access:
- **Moodle:** http://localhost (or configured URL)
- **Database:** localhost:3306
- **Redis:** localhost:6379

### Logs:
```bash
docker-compose -f docker-compose.staging.yml logs -f php
```

## Production Environment

**Optimized for Azure Container Apps.**

### Features:
- ✅ Alpine Linux (minimal, ~400MB)
- ✅ Moodle code baked into image
- ✅ Opcache + preload optimized
- ✅ Production-ready configuration
- ✅ Restart policy: always
- ❌ No debug tools

### Build for Azure:
```bash
docker build -f Dockerfile.prod -t <registry>.azurecr.io/moodle:latest .
docker push <registry>.azurecr.io/moodle:latest
```

### Test locally:
```bash
docker-compose -f docker-compose.prod.yml up -d --build
```

## Development Workflow

### 1. Setup:
```bash
# Clone Moodle
mkdir moodle
cd moodle
git clone -b MOODLE_404_STABLE --depth 1 https://github.com/moodle/moodle.git .
cd ..

# Create directories
mkdir -p moodledata logs/{nginx,php,supervisor}
chmod 777 moodledata

# Copy .env
cp .env.example .env
```

### 2. Develop locally:
```bash
# Start dev environment
docker-compose -f docker-compose.dev.yml up -d

# Edit files in ./moodle - changes are live
# Debug with xdebug on port 9003

# View logs
docker-compose -f docker-compose.dev.yml logs -f php
```

### 3. Test in Staging:
```bash
# Build Staging image
docker-compose -f docker-compose.staging.yml up -d --build

# Test customizations
# Invite clients/QA to test
```

### 4. Deploy to Production:
```bash
# Build production image
docker build -f Dockerfile.prod -t <registry>.azurecr.io/moodle:latest .

# Push to Azure
docker push <registry>.azurecr.io/moodle:latest

# Deploy via Azure Container Apps
# (See Azure deployment guides)
```

## Environment Variables

All environments use `.env` file:
```
DB_ROOT_PASSWORD=rootpassword
DB_NAME=moodle
DB_USER=moodleuser
DB_PASSWORD=moodlepass
```

## Switching Between Environments

```bash
# Stop current environment
docker-compose -f docker-compose.<ENV>.yml down

# Start another environment
docker-compose -f docker-compose.<NEW_ENV>.yml up -d
```

## Key Differences Summary

**Dockerfile.dev:**
- Debian-based (larger)
- xdebug + development tools
- Fast iteration but larger image

**Dockerfile.staging:**
- Debian-based
- Moodle code copied in
- Opcache enabled
- Production-like but testable

**Dockerfile.prod:**
- Alpine-based (minimal)
- Moodle code copied in
- Optimized for performance
- Best for Azure Container Apps

## Troubleshooting

### Dev environment code not updating?
```bash
# Check volume mount
docker-compose -f docker-compose.dev.yml exec php ls -la /var/www/html

# Rebuild if needed
docker-compose -f docker-compose.dev.yml up -d --build
```

### Staging image too large?
```bash
# Use prod image instead
docker-compose -f docker-compose.prod.yml up -d --build
```

### Production deploy to Azure?
```bash
# Build minimal image
docker build -f Dockerfile.prod -t myregistry.azurecr.io/moodle:v1.0 .

# Push to Azure Container Registry
docker push myregistry.azurecr.io/moodle:v1.0
```

## Getting Help

- **Development issues?** Check logs: `docker-compose -f docker-compose.dev.yml logs -f`
- **Build issues?** Rebuild: `docker-compose -f docker-compose.<ENV>.yml up -d --build`
- **Database issues?** Access database: `docker-compose -f docker-compose.<ENV>.yml exec db mariadb -u moodleuser -p`
