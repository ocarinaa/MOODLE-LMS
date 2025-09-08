# 🔧 Moodle LMS - Troubleshooting Guide

<div align="center">
  <img src="https://via.placeholder.com/150x100.png?text=Troubleshooting" alt="Troubleshooting" width="150"/>
  <h3>Let's Solve Problems!</h3>
  <p><em>Step-by-step solution guide</em></p>
</div>

---

## 📋 Contents

1. [Quick Diagnosis](#quick-diagnosis)
2. [Installation Issues](#installation-issues)
3. [Docker Issues](#docker-issues)
4. [Moodle Issues](#moodle-issues)
5. [Database Issues](#database-issues)
6. [Integration Issues](#integration-issues)
7. [Performance Issues](#performance-issues)
8. [Security Issues](#security-issues)
9. [Log Analysis](#log-analysis)
10. [Emergency Recovery](#emergency-recovery)

---

## 🩺 Quick Diagnosis

### ⚡ **System Status Check**

```bash
# Basic system check
./quick-diagnose.sh

# Or manual check
echo "=== Moodle LMS System Check ==="
echo "Docker Status: $(docker --version 2>/dev/null || echo 'NOT INSTALLED')"
echo "Docker Compose: $(docker-compose --version 2>/dev/null || echo 'NOT INSTALLED')"
echo "Services Status:"
docker-compose ps 2>/dev/null || echo "Docker Compose not running"
echo "Disk Space: $(df -h . | tail -1 | awk '{print $4}')"
echo "Memory Usage: $(free -h | grep Mem | awk '{print $3"/"$2}')"
```

### 🚦 **Service Status Checks**

| Service | Check Command | Expected Status |
|--------|----------------|----------------|
| **Moodle** | `curl -f http://localhost:8080` | HTTP 200 |
| **MariaDB** | `docker exec mariadb mysqladmin ping` | `mysqld is alive` |
| **Docker** | `docker info` | Running |

---

## 🏗️ Installation Issues

### ❌ **Problem: "Docker not found"**

**Symptom:**
```
bash: docker: command not found
```

**Solution:**
```bash
# Docker installation for Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Re-login or:
newgrp docker

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker
```

### ❌ **Problem: "Permission denied"**

**Symptom:**
```
docker: permission denied while trying to connect to the Docker daemon socket
```

**Solution:**
```bash
# Add current user to docker group
sudo usermod -aG docker $USER

# Activate group change
newgrp docker

# Or restart system
sudo reboot
```

### ❌ **Problem: "Port already in use"**

**Symptom:**
```
ERROR: for moodle  Cannot start service moodle: driver failed programming external connectivity on endpoint
```

**Solution:**
```bash
# Find process using port 8080
sudo lsof -i :8080

# Kill process (with PID)
sudo kill -9 <PID>

# Or use different port (docker-compose.yml)
ports:
  - "8081:8080"  # Use port 8081
```

---

## 🐳 Docker Issues

### ❌ **Problem: Container keeps restarting**

**Symptom:**
```bash
docker-compose ps
# Status: Restarting
```

**Diagnosis and Solution:**
```bash
# Check logs
docker-compose logs moodle

# Detailed log
docker logs --details moodle-container-name

# Enter container and test manually
docker exec -it moodle-container-name bash

# Check memory issue
docker stats
```

**Possible solutions:**
```yaml
# Increase memory limit in docker-compose.yml
services:
  moodle:
    # ... other settings
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 1G
```

### ❌ **Problem: Volume mount issues**

**Symptom:**
```
Error response from daemon: invalid mount config
```

**Solution:**
```bash
# Clean volumes (WARNING: Data will be lost!)
docker-compose down -v

# Recreate volumes
docker volume create moodle-lms_moodle_data
docker volume create moodle-lms_moodledata_data
docker volume create moodle-lms_mariadb_data

# Restart
docker-compose up -d
```

### ❌ **Problem: Network connection issues**

**Symptom:**
```
moodle    | mysqli::real_connect(): (HY000/2002): Connection refused
```

**Solution:**
```bash
# Check network status
docker network ls
docker network inspect moodle-lms_default

# Recreate network
docker-compose down
docker network prune -f
docker-compose up -d
```

---

## 🎓 Moodle Issues

### ❌ **Problem: "Site under maintenance" message**

**Symptom:**
- Home page showing maintenance mode
- Cannot access admin panel

**Solution:**
```bash
# Enter container
docker exec -it moodle-lms_moodle_1 bash

# Disable maintenance mode
php admin/cli/maintenance.php --disable

# Or edit config.php file
vi /opt/bitnami/moodle/config.php
# Remove or comment this line:
# $CFG->maintenance_enabled = true;
```

### ❌ **Problem: "Invalid login credentials"**

**Symptom:**
- Cannot login with admin / Admin@12345

**Solution:**
```bash
# Enter container
docker exec -it moodle-lms_moodle_1 bash

# Reset admin password
php admin/cli/reset_password.php --username=admin --password=NewPassword123!

# Or create new admin user
php admin/cli/install_database.php --adminuser=newadmin --adminpass=NewPass123! --adminemail=admin@example.com
```

### ❌ **Problem: Special characters appear corrupted**

**Symptom:**
- Special characters appear as ? or strange symbols

**Solution:**
```bash
# Check database character set
docker exec -it moodle-lms_mariadb_1 mysql -u bn_moodle -pbitnami123 -e "
SELECT DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME 
FROM information_schema.SCHEMATA 
WHERE SCHEMA_NAME='bitnami_moodle';"

# Set UTF-8 character set
docker exec -it moodle-lms_mariadb_1 mysql -u bn_moodle -pbitnami123 -e "
ALTER DATABASE bitnami_moodle CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

### ❌ **Problem: File upload not working**

**Symptom:**
- File upload operations fail

**Solution:**
```bash
# Check upload limits
docker exec moodle-lms_moodle_1 php -i | grep -E "(upload_max_filesize|post_max_size|max_execution_time)"

# Check Moodle data directory permissions
docker exec moodle-lms_moodle_1 ls -la /bitnami/moodledata/

# Fix permissions
docker exec moodle-lms_moodle_1 chown -R bitnami:bitnami /bitnami/moodledata/
docker exec moodle-lms_moodle_1 chmod -R 755 /bitnami/moodledata/
```

---

## 💾 Database Issues

### ❌ **Problem: "Database connection failed"**

**Symptom:**
```
Error: Database connection failed.
It is possible that the database is overloaded or otherwise not running properly.
```

**Solution:**
```bash
# Check MariaDB container status
docker-compose ps mariadb

# Check MariaDB logs
docker-compose logs mariadb

# Test database connection
docker exec -it moodle-lms_mariadb_1 mysql -u bn_moodle -pbitnami123 -e "SELECT 1;"

# Restart MariaDB
docker-compose restart mariadb
```

### ❌ **Problem: "Table doesn't exist" errors**

**Symptom:**
```
ERROR 1146 (42S02): Table 'bitnami_moodle.mdl_config' doesn't exist
```

**Solution:**
```bash
# Database restore process
docker exec -it moodle-lms_mariadb_1 mysql -u root -proot_password

# Check database status
SHOW DATABASES;
USE bitnami_moodle;
SHOW TABLES;

# If tables are missing, perform restore
# If you have a backup file:
cat backup.sql | docker exec -i moodle-lms_mariadb_1 mysql -u bn_moodle -pbitnami123 bitnami_moodle
```

### ❌ **Problem: Database corruption error**

**Symptom:**
```
MySQL server has gone away
Error reading from database
```

**Solution:**
```bash
# Database repair
docker exec -it moodle-lms_mariadb_1 mysqlcheck --repair --all-databases -u root -proot_password

# Table-based repair
docker exec -it moodle-lms_mariadb_1 mysql -u root -proot_password bitnami_moodle -e "
REPAIR TABLE mdl_sessions;
REPAIR TABLE mdl_log;
REPAIR TABLE mdl_config;
"

# InnoDB recovery mode
# Add to my.cnf file: innodb_force_recovery = 1
```

---

## 🔌 Integration Issues

### 📹 **BigBlueButton Issues**

**❌ Problem: "Unable to join meeting"**

```bash
# Check BBB server status
curl -f "https://your-bbb-server.com/bigbluebutton/api"

# Check Moodle config
docker exec moodle-lms_moodle_1 grep -r "bigbluebutton" /opt/bitnami/moodle/config.php

# API secret verification
# Secret in config.php must match BBB server secret
```

**Solution:**
```php
// config.php update
$CFG->bigbluebuttonbn_server_url = 'https://correct-bbb-server.com/bigbluebutton/api/';
$CFG->bigbluebuttonbn_shared_secret = 'correct_secret_key';
```

### 🔍 **Examus Proctoring System Issues**

**❌ Problem: "Unable to start proctoring session"**

```bash
# Web service token check
docker exec moodle-lms_moodle_1 php -r "
require_once('/opt/bitnami/moodle/config.php');
echo 'Token: ' . get_config('examus', 'token') . \"\n\";
"

# API endpoint test
curl -X POST "http://example-domain.com/webservice/rest/server.php" \
  -d "wstoken=87b5bfe408e6dbe60c21f1630202c02d" \
  -d "wsfunction=core_user_get_users" \
  -d "moodlewsrestformat=json"
```

### 🛡️ **Safe Exam Browser Issues**

**❌ Problem: "SEB not detected"**

```bash
# Check SEB configuration
docker exec moodle-lms_moodle_1 find /opt/bitnami/moodle -name "*seb*" -type f

# Create config file
docker exec moodle-lms_moodle_1 php admin/cli/cfg.php --name=seb_enabled --set=1
```

---

## ⚡ Performance Issues

### ❌ **Problem: Slow page loading**

**Diagnosis:**
```bash
# System resource usage
docker stats

# Disk I/O check
iostat -x 1

# Memory leak check
docker exec moodle-lms_moodle_1 php admin/cli/check_database_schema.php
```

**Solutions:**

1. **Cache cleanup:**
```bash
# Clear Moodle cache
docker exec moodle-lms_moodle_1 php admin/cli/purge_caches.php

# Clear browser cache
# Press Ctrl+Shift+R in browser
```

2. **Database optimization:**
```bash
# Optimize database
docker exec -it moodle-lms_mariadb_1 mysqlcheck --optimize --all-databases -u root -proot_password

# Enable slow query log
docker exec -it moodle-lms_mariadb_1 mysql -u root -proot_password -e "
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL slow_query_log_file = '/var/log/mysql/slow.log';
SET GLOBAL long_query_time = 2;
"
```

3. **Increase resource limits:**
```yaml
# docker-compose.yml
services:
  moodle:
    deploy:
      resources:
        limits:
          memory: 4G
          cpus: '2.0'
```

### ❌ **Problem: High CPU usage**

**Diagnosis:**
```bash
# Top processes
docker exec moodle-lms_moodle_1 top

# PHP processes
docker exec moodle-lms_moodle_1 ps aux | grep php
```

**Solution:**
```bash
# Optimize PHP-FPM settings
docker exec moodle-lms_moodle_1 vi /opt/bitnami/php/etc/php-fpm.d/www.conf

# Reduce cron job frequency
docker exec moodle-lms_moodle_1 crontab -e
# Use */30 instead of */15 minutes
```

---

## 🔒 Security Issues

### ❌ **Problem: "Unauthorized access" warnings**

**Symptoms:**
- Suspicious activity in log files
- Access from unknown IP addresses

**Solution:**
```bash
# Configure IP whitelist
docker exec moodle-lms_moodle_1 php admin/cli/cfg.php --name=allowedips --set="192.168.1.0/24"

# Add security headers (Apache config):
Header always set X-Frame-Options DENY
Header always set X-Content-Type-Options nosniff
Header always set X-XSS-Protection "1; mode=block"
```

### ❌ **Problem: SSL certificate issues**

**Symptoms:**
- "Not secure" warning
- Mixed content errors

**Solution:**
```bash
# Renew Let's Encrypt certificate
certbot renew --dry-run

# Check certificate status
openssl x509 -in /etc/ssl/certs/certificate.crt -text -noout

# Enforce HTTPS
docker exec moodle-lms_moodle_1 php admin/cli/cfg.php --name=httpswwwroot --set="https://your-domain.com"
```

---

## 📊 Log Analysis

### 🔍 **Log File Locations**

| Service | Log File | Path |
| **Moodle** | Error Log | `/opt/bitnami/moodle/error.log` |
| **Apache** | Access Log | `/opt/bitnami/apache/logs/access_log` |
| **MariaDB** | Error Log | `/opt/bitnami/mariadb/logs/mysqld.log` |
| **Docker** | Container Log | `docker logs container-name` |

### 📋 **Log Analysis Commands**

```bash
# Last 100 lines of error log
docker exec moodle-lms_moodle_1 tail -n 100 /opt/bitnami/moodle/error.log

# Filter critical errors
docker logs moodle-lms_moodle_1 2>&1 | grep -i "error\|fatal\|critical"

# Specific time range
docker logs --since="2025-01-01T00:00:00" --until="2025-01-02T00:00:00" moodle-lms_moodle_1

# Check log size
docker exec moodle-lms_moodle_1 du -h /opt/bitnami/moodle/error.log
```

### 🔍 **Common Log Errors**

| Error | Meaning | Solution |
|------|--------|-------|
| `Fatal error: Maximum execution time` | Script timeout | Increase PHP max_execution_time |
| `mysqli_connect(): Connection refused` | DB connection issue | Check MariaDB container |
| `File not found` | Missing file | Check file permissions |
| `Out of memory` | Insufficient memory | Increase memory limit |

---

## 🚨 Emergency Recovery

### 💾 **Quick Backup**

```bash
# Full system backup
./scripts/emergency-backup.sh

# Manual backup
docker exec moodle-lms_mariadb_1 mysqldump -u bn_moodle -pbitnami123 bitnami_moodle > emergency-backup.sql
docker cp moodle-lms_moodle_1:/bitnami/moodledata ./moodledata-backup
```

### 🔄 **System Restore**

```bash
# Stop containers
docker-compose down

# Remove volumes
docker volume rm moodle-lms_mariadb_data moodle-lms_moodledata_data

# Restart
docker-compose up -d

# Restore database
cat emergency-backup.sql | docker exec -i moodle-lms_mariadb_1 mysql -u bn_moodle -pbitnami123 bitnami_moodle

# Restore Moodle data
docker cp ./moodledata-backup/. moodle-lms_moodle_1:/bitnami/moodledata/
```

### 🆘 **Last Resort Commands**

```bash
# Remove all Docker data (CAUTION!)
docker system prune -a --volumes

# Remove all containers
docker stop $(docker ps -aq) && docker rm $(docker ps -aq)

# Fresh setup
git pull origin main
docker-compose up -d --build --force-recreate
```

---

## 🛟 Getting Support

### 📞 **Contact Channels**

| Priority | Channel | Response Time |
| **🚨 Critical** | Phone: +1-555-0123 | < 2 hours |
| **⚠️ High** | Email: support@example.com | < 4 hours |
| **🔵 Normal** | GitHub Issues | < 1 day |

### 📋 **Support Request Template**

```markdown
## 🚨 Issue Description
[Describe the issue in detail]

## 🔄 Reproduction Steps
1. [Step 1]
2. [Step 2]
3. [Error occurs]

## 💻 System Information
- OS: [Ubuntu 20.04]
- Docker Version: [20.10.12]
- Moodle LMS Version: [2.1.0]

## 📊 Log Output
```bash
[Paste log output here]
```

## 🔍 Attempted Solutions
[What you have tried so far]
```

---

## 🧰 Useful Scripts

### 🔍 **System Health Check**

```bash
#!/bin/bash
# health-check.sh

echo "=== Moodle LMS Health Check ==="
echo "Date: $(date)"
echo ""

# Docker checks
echo "🐳 Docker Services:"
docker-compose ps | tail -n +3 | while read line; do
  echo "  - $line"
done

# Resource usage
echo ""
echo "💻 Resource Usage:"
echo "  - Memory: $(free -h | grep Mem | awk '{print $3"/"$2" ("$3/$2*100"%)"}')"
echo "  - Disk: $(df -h . | tail -1 | awk '{print $3"/"$2" ("$5")"}')"

# Service accessibility
echo ""
echo "🌐 Service Accessibility:"
curl -s -f http://localhost:8080/login/index.php >/dev/null && echo "  - Moodle: ✅ OK" || echo "  - Moodle: ❌ FAIL"

# Database connectivity
docker exec moodle-lms_mariadb_1 mysqladmin ping >/dev/null 2>&1 && echo "  - Database: ✅ OK" || echo "  - Database: ❌ FAIL"

echo ""
echo "=== Health Check Complete ==="
```

### 🧹 **Cleanup Script**

```bash
#!/bin/bash
# cleanup.sh

echo "🧹 Moodle LMS Cleanup Starting..."

# Clean log files
echo "📄 Cleaning logs..."
docker exec moodle-lms_moodle_1 find /opt/bitnami/apache/logs -name "*.log" -type f -mtime +7 -delete
docker exec moodle-lms_moodle_1 truncate -s 0 /opt/bitnami/moodle/error.log

# Clean cache
echo "🗂️ Cleaning cache..."
docker exec moodle-lms_moodle_1 php admin/cli/purge_caches.php

# Temporary files
echo "🗑️ Cleaning temp files..."
docker exec moodle-lms_moodle_1 find /tmp -type f -mtime +3 -delete

# Docker cleanup
echo "🐳 Docker cleanup..."
docker system prune -f

echo "✅ Cleanup complete!"
```

---

<div align="center">

## 🎯 Still need help?

**No worries! Contact us:**

📧 **Email:** support@example.com  
📱 **Phone:** +1-555-0123  
🐛 **GitHub:** [Issues page](https://github.com/umur957/moodle-lms/issues)

---

*This guide is updated regularly. Please report new issues!*

**© 2025 UMUR KIZILDAS • MIT License • Made with ❤️ for the community**

</div>