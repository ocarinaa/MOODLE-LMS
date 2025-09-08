# 🚀 Moodle LMS Installation Guide

This guide explains the detailed installation process of the Moodle LMS system.

## 📋 Table of Contents

1. [System Requirements](#system-requirements)
2. [Server Preparation](#server-preparation)
3. [Docker Installation](#docker-installation)
4. [Moodle LMS Installation](#moodle-lms-installation)
5. [Initial Configuration](#initial-configuration)
6. [SSL Certificate](#ssl-certificate)
7. [Production Optimization](#production-optimization)
8. [Troubleshooting](#troubleshooting)

---

## 💻 System Requirements

### Minimum Requirements

| Component | Minimum | Recommended | Enterprise |
|---------|---------|----------|------------|
| **CPU** | 2 vCPU | 4 vCPU | 8+ vCPU |
| **RAM** | 4GB | 8GB | 16GB+ |
| **Disk** | 20GB SSD | 50GB SSD | 100GB+ NVMe |
| **Network** | 100Mbps | 1Gbps | 10Gbps |
| **Concurrent Users** | 50 | 500 | 5000+ |

### Supported Operating Systems

#### ✅ Full Support
- **Ubuntu** 24.04 LTS (Recommended)
- **Ubuntu** 22.04 LTS  
- **Ubuntu** 20.04 LTS
- **Debian** 12 (Bookworm)
- **Debian** 11 (Bullseye)

#### ⚠️ Partial Support
- **CentOS** 8 Stream
- **RHEL** 8+
- **Rocky Linux** 8+
- **Amazon Linux** 2

#### ❌ Not Supported
- Ubuntu < 20.04
- CentOS < 8
- Windows Server (testing with WSL2)

### Network Requirements

#### Required Open Ports:
```bash
# HTTP/HTTPS
80/tcp    # HTTP
443/tcp   # HTTPS

# SSH (for management)
22/tcp    # SSH

# Database (internal network)
3306/tcp  # MariaDB (container network only)

# BigBlueButton (Optional)
80/tcp, 443/tcp, 1935/tcp, 7443/tcp
```

---

## 🔧 Server Preparation

### 1. System Update

```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade -y

# CentOS/RHEL
sudo yum update -y
# or (newer versions)
sudo dnf update -y
```

### 2. Install Required Packages

```bash
# Ubuntu/Debian
sudo apt install -y \
    curl \
    wget \
    unzip \
    git \
    vim \
    nano \
    htop \
    net-tools \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# CentOS/RHEL
sudo yum install -y \
    curl \
    wget \
    unzip \
    git \
    vim \
    nano \
    htop \
    net-tools
```

### 3. Set Timezone

```bash
# Check current timezone
timedatectl

# Set Turkey timezone
sudo timedatectl set-timezone Europe/Istanbul

# Set Germany timezone (alternative)
sudo timedatectl set-timezone Europe/Berlin

# Enable time synchronization
sudo timedatectl set-ntp true
```

### 4. Firewall Configuration

#### Ubuntu UFW:
```bash
# Enable UFW
sudo ufw enable

# Basic rules
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS

# Check status
sudo ufw status verbose
```

#### CentOS/RHEL Firewalld:
```bash
# Start firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Open ports
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https

# Reload rules
sudo firewall-cmd --reload

# Check status
sudo firewall-cmd --list-all
```

### 5. Create Swap Space

```bash
# Create 4GB swap space
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Check swap usage
free -h
```

---

## 🐳 Docker Installation

### Docker Installation for Ubuntu/Debian

```bash
# Remove old Docker versions
sudo apt remove -y docker docker-engine docker.io containerd runc

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update repository and install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER

# Refresh session (or logout/login)
newgrp docker
```

### Docker Installation for CentOS/RHEL

```bash
# Remove old versions
sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

# Add Docker repository
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### Docker Compose Installation (For Older Systems)

```bash
# Check latest version: https://github.com/docker/compose/releases
DOCKER_COMPOSE_VERSION="v2.24.0"

# Download Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make executable
sudo chmod +x /usr/local/bin/docker-compose

# Check version
docker-compose --version
```

### Docker Installation Verification

```bash
# Docker service status
sudo systemctl status docker

# Docker version info
docker --version
docker compose version

# Run test container
docker run hello-world

# Docker system info
docker system info
```

---

## 📦 Moodle LMS Installation

### 1. Clone Repository

```bash
# Go to main directory
cd /opt

# Clone repository
sudo git clone https://github.com/umur957/moodle-lms.git moodle-lms

# Change directory ownership
sudo chown -R $USER:$USER /opt/moodle-lms

# Go to working directory
cd /opt/moodle-lms
```

### 2. Review Configuration Files

```bash
# Review Docker Compose file
cat docker-compose.yml

# Review Gitpod configuration
cat gitpod.yaml

# Review startup script
cat start.sh
```

### 3. Create Environment File (Optional)

```bash
# Create .env file
cat > .env << EOF
# Moodle Configuration
MOODLE_SITE_NAME=Moodle LMS
MOODLE_USERNAME=admin
MOODLE_PASSWORD=Secure_Password_2025!
MOODLE_EMAIL=admin@example.com

# Database Configuration
MARIADB_USER=bn_moodle
MARIADB_PASSWORD=Secure_DB_Password_2025!
MARIADB_DATABASE=bitnami_moodle
MARIADB_ROOT_PASSWORD=Secure_Root_Password_2025!

# Security
ALLOW_EMPTY_PASSWORD=no

# Timezone
TZ=Europe/Istanbul
EOF

# Secure .env file
chmod 600 .env
```

### 4. Start with Docker Compose

```bash
# Start services in background
docker compose up -d

# Check startup status
docker compose ps

# Follow logs
docker compose logs -f
```

### 5. Monitor Installation Progress

```bash
# Monitor Moodle container logs
docker compose logs -f moodle

# Monitor MariaDB container logs
docker compose logs -f mariadb

# Check all services status
docker compose ps

# Monitor container resource usage
docker stats
```

---

## ⚙️ Initial Configuration

### 1. Web Interface Access

After installation is complete (approximately 3-5 minutes):

```bash
# Local access
http://localhost:8080

# Remote server access
http://YOUR_SERVER_IP:8080

# HTTPS (if SSL is configured)
https://YOUR_DOMAIN:8443
```

### 2. Initial Login Credentials

| Field | Value |
|------|--------|
| **URL** | `http://your-server:8080` |
| **Username** | `admin` |
| **Password** | `Admin@12345` (change this!) |
| **Email** | `admin@example.com` |

### 3. Administrator Account Security Settings

```bash
# Enter container
docker exec -it moodle-lms-moodle-1 bash

# Go to Moodle CLI
cd /opt/bitnami/moodle

# Change admin password
php admin/cli/reset_password.php --username=admin

# Create new user
php admin/cli/create_user.php --username=new_admin --password=SecurePassword123! --email=admin@example.com --firstname=Admin --lastname=User

# Exit container
exit
```

### 4. Basic Site Configuration

#### Site Settings:
1. **Site Administration** > **Server** > **System information**
2. **Site Administration** > **Appearance** > **Themes**
3. **Site Administration** > **Language** > **Language packs**

#### Security Settings:
1. **Site Administration** > **Security** > **Site security settings**
2. **Site Administration** > **Users** > **Permissions** > **User policies**

---

## 🔒 SSL Certificate Setup

### Automatic SSL with Let's Encrypt

#### 1. Install Certbot

```bash
# Ubuntu/Debian
sudo apt install -y certbot python3-certbot-nginx

# CentOS/RHEL
sudo yum install -y certbot python3-certbot-nginx
```

#### 2. Nginx Reverse Proxy Configuration

```bash
# Install Nginx
sudo apt install -y nginx

# Create Nginx config file
sudo tee /etc/nginx/sites-available/moodle-lms << EOF
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

# Enable site
sudo ln -s /etc/nginx/sites-available/moodle-lms /etc/nginx/sites-enabled/

# Test and start Nginx
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx
```

#### 3. Obtain SSL Certificate

```bash
# Get SSL certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com --email admin@example.com --agree-tos --no-eff-email

# Test automatic renewal
sudo certbot renew --dry-run

# Add automatic renewal to crontab
echo "0 3 * * 1 certbot renew --quiet" | sudo crontab -
```

### Manual SSL Certificate

```bash
# Create SSL directory
sudo mkdir -p /opt/moodle-lms/ssl

# Create self-signed certificate (for testing only)
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /opt/moodle-lms/ssl/moodle.key \
    -out /opt/moodle-lms/ssl/moodle.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=moodle.local"

# Add SSL to Docker Compose
# Add to docker-compose.yml:
# volumes:
#   - ./ssl/moodle.crt:/opt/bitnami/apache/conf/ssl/server.crt:ro
#   - ./ssl/moodle.key:/opt/bitnami/apache/conf/ssl/server.key:ro
```

---

## ⚡ Production Optimization

### 1. Performance Tuning

```bash
# Add environment variables to docker-compose.yml
cat >> docker-compose.yml << EOF
    environment:
      # ... existing environment variables ...
      
      # Performance optimization
      - MOODLE_ENABLE_CACHING=yes
      - MOODLE_CACHE_STORE=redis
      - MOODLE_SESSION_HANDLER=redis
      
      # PHP optimization
      - PHP_MEMORY_LIMIT=512M
      - PHP_MAX_EXECUTION_TIME=300
      - PHP_UPLOAD_MAX_FILESIZE=100M
      - PHP_POST_MAX_SIZE=100M
      
      # Database optimization
      - MARIADB_INNODB_BUFFER_POOL_SIZE=512M
      - MARIADB_QUERY_CACHE_SIZE=128M
EOF
```

### 2. Add Redis Cache

```yaml
# Add Redis service to docker-compose.yml
services:
  redis:
    image: bitnami/redis:latest
    container_name: redis
    environment:
      - REDIS_PASSWORD=redis_secure_password
    volumes:
      - redis_data:/bitnami/redis
    restart: always
    networks:
      - moodle_network

volumes:
  redis_data:
    driver: local
```

### 3. Add Monitoring

```yaml
# Monitoring stack with Prometheus and Grafana
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro
    ports:
      - "9090:9090"
    networks:
      - moodle_network
      
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin_password
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - moodle_network
```

### 4. Backup System

```bash
# Create backup script
sudo tee /opt/moodle-lms/scripts/backup.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/opt/backups/moodle-lms"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RETENTION_DAYS=30

# Create backup directory
mkdir -p $BACKUP_DIR

echo "🔄 Moodle LMS backup starting..."

# Database backup
echo "📊 Creating database backup..."
docker exec moodle-lms-mariadb-1 mysqldump \
    -u bn_moodle -pbitnami123 bitnami_moodle \
    > $BACKUP_DIR/database_$TIMESTAMP.sql

# Moodledata backup
echo "📁 Creating Moodle data backup..."
docker run --rm \
  -v moodle-lms_moodledata_data:/data:ro \
    -v $BACKUP_DIR:/backup \
    alpine tar czf /backup/moodledata_$TIMESTAMP.tar.gz -C /data .

# Configuration backup
echo "⚙️ Creating configuration backup..."
cp -r /opt/moodle-lms $BACKUP_DIR/config_$TIMESTAMP

# Remove old backups (30 days)
find $BACKUP_DIR -type f -mtime +$RETENTION_DAYS -delete

echo "✅ Backup completed: $BACKUP_DIR"
EOF

# Make script executable
chmod +x /opt/moodle-lms/scripts/backup.sh

# Add daily backup to crontab
echo "0 2 * * * /opt/moodle-lms/scripts/backup.sh >> /var/log/moodle-lms-backup.log 2>&1" | crontab -
```

---

## 🐛 Troubleshooting

### Common Problems and Solutions

#### 1. Container Startup Issues

```bash
# Check container status
docker compose ps

# Check container logs
docker compose logs moodle
docker compose logs mariadb

# Restart containers
docker compose restart

# Completely recreate containers
docker compose down
docker compose up -d --force-recreate
```

#### 2. Port Conflict Issues

```bash
# Check port usage
sudo netstat -tulpn | grep :8080
sudo ss -tulpn | grep :8080

# Kill conflicting process
sudo fuser -k 8080/tcp

# Use alternative port (change in docker-compose.yml)
ports:
  - "8081:8080"  # Use port 8081
```

#### 3. Database Connection Issues

```bash
# Connect to MariaDB container
docker exec -it moodle-lms-mariadb-1 mysql -u bn_moodle -pbitnami123

# Check database status
SHOW DATABASES;
USE bitnami_moodle;
SHOW TABLES;

# Exit container
exit
```

#### 4. Memory/Performance Issues

```bash
# Check container resource usage
docker stats

# Check system resources
free -h
df -h
htop

# Clear Moodle cache
docker exec moodle-lms-moodle-1 php /opt/bitnami/moodle/admin/cli/purge_caches.php
```

#### 5. SSL/HTTPS Issues

```bash
# Check Nginx status
sudo systemctl status nginx

# Test Nginx configuration
sudo nginx -t

# Check SSL certificate status
sudo certbot certificates

# Renew SSL certificate
sudo certbot renew --force-renewal
```

### Log Analysis

```bash
# Monitor all container logs
docker compose logs -f --tail=100

# Monitor specific service logs
docker compose logs -f moodle

# Check system logs
sudo journalctl -u docker
sudo tail -f /var/log/syslog

# Nginx access logs
sudo tail -f /var/log/nginx/access.log

# Nginx error logs  
sudo tail -f /var/log/nginx/error.log
```

### Diagnostic Script

```bash
# Create diagnostic script
cat > diagnostic.sh << 'EOF'
#!/bin/bash

echo "🔍 Moodle LMS System Diagnostics"
echo "================================"

echo "📊 System Information:"
echo "OS: $(lsb_release -d | cut -f2)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"

echo -e "\n🐳 Docker Information:"
echo "Docker Version: $(docker --version)"
echo "Docker Compose Version: $(docker compose version --short)"

echo -e "\n📦 Container Status:"
docker compose ps

echo -e "\n💾 Disk Usage:"
df -h | grep -E "(Filesystem|/dev/)"

echo -e "\n🧠 Memory Usage:"
free -h

echo -e "\n🌐 Network Status:"
ss -tulpn | grep -E ":80|:443|:8080|:8443|:3306"

echo -e "\n🔗 Moodle Access Test:"
curl -f -s -I http://localhost:8080/login/index.php && echo "✅ Moodle accessible" || echo "❌ Moodle not accessible"

echo -e "\n📋 Last 10 Moodle Logs:"
docker compose logs moodle --tail=10

EOF

chmod +x diagnostic.sh
./diagnostic.sh
```

---

## 📞 Support

Having trouble with this installation guide?

- 🐛 **Bug Report**: [GitHub Issues](https://github.com/umur957/moodle-lms/issues)
- 📚 **Documentation**: [docs/](../README.md)

---

*This installation guide is continuously updated. You can share your suggestions through [GitHub Issues](https://github.com/umur957/moodle-lms/issues).*