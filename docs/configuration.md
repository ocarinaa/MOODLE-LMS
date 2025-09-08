# ⚙️ Moodle LMS Configuration Guide

Detailed configuration options and optimization settings for the Moodle LMS system.

## 📋 Table of Contents

1. [Docker Compose Configuration](#docker-compose-configuration)
2. [Moodle Configuration](#moodle-configuration)
3. [Database Optimization](#database-optimization)
4. [Performance Tuning](#performance-tuning)
5. [Security Configuration](#security-configuration)
6. [Multi-language Settings](#multi-language-settings)
7. [Email Configuration](#email-configuration)
8. [Backup Configuration](#backup-configuration)

---

## 🐳 Docker Compose Configuration

### Basic Configuration

```yaml
version: '3'

services:
  mariadb:
    image: bitnami/mariadb:latest
    container_name: moodle-lms-mariadb
    environment:
      # Basic Database Settings
      - MARIADB_USER=bn_moodle
      - MARIADB_PASSWORD=secure_password_2025
      - MARIADB_DATABASE=bitnami_moodle
      - MARIADB_ROOT_PASSWORD=root_secure_password_2025
      - ALLOW_EMPTY_PASSWORD=no
      
      # Performance Optimization
      - MARIADB_INNODB_BUFFER_POOL_SIZE=512M
      - MARIADB_QUERY_CACHE_SIZE=128M
      - MARIADB_QUERY_CACHE_TYPE=1
      - MARIADB_MAX_CONNECTIONS=200
      - MARIADB_THREAD_CACHE_SIZE=16
      
      # Character Set (UTF-8 and Emoji support)
      - MARIADB_CHARACTER_SET=utf8mb4
      - MARIADB_COLLATE=utf8mb4_unicode_ci
      
    volumes:
      - mariadb_data:/bitnami/mariadb
      - ./config/mariadb/my.cnf:/opt/bitnami/mariadb/conf/my.cnf:ro
    restart: always
    networks:
      - moodle_network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 5s
      retries: 10

  moodle:
    image: bitnami/moodle:latest
    container_name: moodle-lms-moodle
    environment:
      # Database Connection Settings
      - MARIADB_HOST=mariadb
      - MARIADB_PORT_NUMBER=3306
      - MOODLE_DATABASE_USER=bn_moodle
      - MOODLE_DATABASE_PASSWORD=secure_password_2025
      - MOODLE_DATABASE_NAME=bitnami_moodle
      
      # Site Basic Settings
      - MOODLE_SITE_NAME=Moodle LMS
      - MOODLE_USERNAME=admin
      - MOODLE_PASSWORD=Admin_Secure_2025!
      - MOODLE_EMAIL=admin@example.com
      - MOODLE_SKIP_BOOTSTRAP=no
      
      # Language and Localization
      - MOODLE_LANG=en
      - TZ=Europe/Istanbul
      
      # PHP Optimization
      - PHP_MEMORY_LIMIT=512M
      - PHP_MAX_EXECUTION_TIME=300
      - PHP_UPLOAD_MAX_FILESIZE=100M
      - PHP_POST_MAX_SIZE=100M
      - PHP_MAX_INPUT_VARS=5000
      
      # Apache Settings
      - APACHE_SERVER_TOKENS=Prod
      - APACHE_SERVER_SIGNATURE=Off
      
    ports:
      - "8080:8080"
      - "8443:8443"
    volumes:
      - moodle_data:/bitnami/moodle
      - moodledata_data:/bitnami/moodledata
      - ./config/moodle/config.php:/opt/bitnami/moodle/config.php:ro
      - ./config/moodle/php.ini:/opt/bitnami/php/etc/php.ini:ro
    depends_on:
      mariadb:
        condition: service_healthy
    restart: always
    networks:
      - moodle_network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/login/index.php"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Redis Cache (for performance)
  redis:
    image: bitnami/redis:latest
    container_name: moodle-lms-redis
    environment:
      - REDIS_PASSWORD=redis_secure_password_2025
      - REDIS_DISABLE_COMMANDS=FLUSHDB,FLUSHALL,CONFIG
      - REDIS_MAXMEMORY=256mb
      - REDIS_MAXMEMORY_POLICY=allkeys-lru
    volumes:
      - redis_data:/bitnami/redis
    restart: always
    networks:
      - moodle_network

networks:
  moodle_network:
    driver: bridge

volumes:
  mariadb_data:
    driver: local
  moodle_data:
    driver: local
  moodledata_data:
    driver: local
  redis_data:
    driver: local
```

### Environment File (.env)

```bash
# Create .env file
cat > .env << 'EOF'
# Moodle LMS Environment Configuration

# Site Configuration
MOODLE_SITE_NAME=Moodle LMS
MOODLE_URL=https://your-domain.com
MOODLE_ADMIN_EMAIL=admin@example.com

# Admin Account
MOODLE_USERNAME=admin
MOODLE_PASSWORD=Generate_Strong_Password_Here!
MOODLE_EMAIL=admin@example.com

# Database Configuration
MARIADB_HOST=mariadb
MARIADB_PORT=3306
MARIADB_USER=bn_moodle
MARIADB_PASSWORD=Generate_DB_Password_Here!
MARIADB_DATABASE=bitnami_moodle
MARIADB_ROOT_PASSWORD=Generate_Root_Password_Here!

# Redis Configuration
REDIS_PASSWORD=Generate_Redis_Password_Here!

# Security
ALLOW_EMPTY_PASSWORD=no

# Localization
TZ=Europe/Istanbul
MOODLE_LANG=en

# Performance
PHP_MEMORY_LIMIT=512M
PHP_MAX_EXECUTION_TIME=300

# BigBlueButton (Optional)
BBB_SERVER_URL=https://your-bbb-server.com/bigbluebutton/api/
BBB_SHARED_SECRET=your_bbb_shared_secret

# Examus (Optional)
EXAMUS_API_TOKEN=your_examus_api_token
EXAMUS_API_URL=https://your-domain.com/webservice/rest/server.php
EOF

# Secure .env file
chmod 600 .env
```

---

## 📚 Moodle Configuration

### Detailed config.php Settings

```php
<?php
// config/moodle/config.php

unset($CFG);
global $CFG;
$CFG = new stdClass();

//=========================================================================
// 1. DATABASE SETUP
//=========================================================================
$CFG->dbtype    = 'mariadb';
$CFG->dblibrary = 'native';
$CFG->dbhost    = getenv('MARIADB_HOST') ?: 'mariadb';
$CFG->dbname    = getenv('MARIADB_DATABASE') ?: 'bitnami_moodle';
$CFG->dbuser    = getenv('MARIADB_USER') ?: 'bn_moodle';
$CFG->dbpass    = getenv('MARIADB_PASSWORD') ?: '';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array(
    'dbpersist' => false,
    'dbsocket'  => false,
    'dbport'    => getenv('MARIADB_PORT') ?: '3306',
    'dbcollation' => 'utf8mb4_unicode_ci',
);

//=========================================================================
// 2. WEB ADDRESS
//=========================================================================
$CFG->wwwroot   = getenv('MOODLE_URL') ?: 'http://localhost:8080';

//=========================================================================
// 3. DATA DIRECTORIES
//=========================================================================
$CFG->dataroot  = '/bitnami/moodledata';
$CFG->directorypermissions = 02777;

//=========================================================================
// 4. ADMIN SETTINGS
//=========================================================================
$CFG->admin     = 'admin';
$CFG->passwordsaltmain = 'YourRandomSaltHereChangeThis123456789012';

//=========================================================================
// 5. LANGUAGE SETTINGS
//=========================================================================
$CFG->lang = getenv('MOODLE_LANG') ?: 'en';
$CFG->langmenu = true;
$CFG->langlist = 'en,de,tr';

//=========================================================================
// 6. PERFORMANCE SETTINGS
//=========================================================================
// Caching
$CFG->cachejs = true;
$CFG->cachetemplates = true;
$CFG->cachetext = 60;

// Session handling
$CFG->sessiontimeout = 7200;
$CFG->sessioncookie = 'MoodleLMS';
$CFG->sessioncookiepath = '/';
$CFG->sessioncookiedomain = '';

// Redis Cache Configuration
$CFG->session_handler_class = '\core\session\redis';
$CFG->session_redis_host = 'redis';
$CFG->session_redis_port = 6379;
$CFG->session_redis_auth = getenv('REDIS_PASSWORD');
$CFG->session_redis_database = 0;
$CFG->session_redis_prefix = 'mdl_session_';

// Application Cache
$CFG->cache_stores['redis'] = array(
    'plugin' => 'cachestore_redis',
    'configuration' => array(
        'server' => 'redis:6379',
        'password' => getenv('REDIS_PASSWORD'),
        'database' => 1,
        'prefix' => 'mdl_cache_',
        'compressor' => 'gzip',
        'serializer' => 'php',
    ),
);

//=========================================================================
// 7. SECURITY SETTINGS
//=========================================================================
$CFG->passwordpolicy = 1;
$CFG->minpasswordlength = 8;
$CFG->minpassworddigits = 1;
$CFG->minpasswordlower = 1;
$CFG->minpasswordupper = 1;
$CFG->minpasswordnonalphanum = 1;

// Session Security
$CFG->cookiesecure = true;
$CFG->cookiehttponly = true;

// IP Restriction (optional)
// $CFG->allowedips = '192.168.1.0/24,10.0.0.0/8';

//=========================================================================
// 8. EMAIL SETTINGS
//=========================================================================
$CFG->smtphosts = getenv('SMTP_HOST') ?: 'localhost';
$CFG->smtpsecure = 'tls';
$CFG->smtpuser = getenv('SMTP_USER') ?: '';
$CFG->smtppass = getenv('SMTP_PASS') ?: '';
$CFG->smtpmaxbulk = 1;
$CFG->noreplyaddress = getenv('MOODLE_ADMIN_EMAIL') ?: 'noreply@example.com';
$CFG->supportemail = getenv('MOODLE_ADMIN_EMAIL') ?: 'info@example.com';

//=========================================================================
// 9. FILE UPLOAD SETTINGS
//=========================================================================
$CFG->maxbytes = 104857600; // 100MB
$CFG->userquota = 1073741824; // 1GB per user

//=========================================================================
// 10. BIGBLUEBUTTON INTEGRATION
//=========================================================================
$CFG->bigbluebuttonbn_server_url = getenv('BBB_SERVER_URL') ?: '';
$CFG->bigbluebuttonbn_shared_secret = getenv('BBB_SHARED_SECRET') ?: '';

//=========================================================================
// 11. EXAMUS INTEGRATION
//=========================================================================
// Web service token for Examus
$CFG->examus_token = getenv('EXAMUS_API_TOKEN') ?: '';

//=========================================================================
// 12. DEBUG SETTINGS (Should be disabled in Production)
//=========================================================================
$CFG->debug = 0;
$CFG->debugdisplay = 0;
$CFG->debugstringids = 0;
$CFG->debugvalidators = 0;
$CFG->debugpageinfo = 0;
$CFG->perfdebug = 0;
$CFG->debugpdb = false;

//=========================================================================
// 13. CRON SETTINGS
//=========================================================================
$CFG->cronclionly = true;
$CFG->cron_enabled = true;

//=========================================================================
// 14. ADDITIONAL SETTINGS
//=========================================================================
// Timezone
date_default_timezone_set(getenv('TZ') ?: 'Europe/Istanbul');

// Maintenance mode
$CFG->maintenance_enabled = false;
$CFG->maintenance_message = 'Site is under maintenance. Please try again later.';

require_once(__DIR__ . '/lib/setup.php');
?>
```

### PHP Configuration

```ini
; config/moodle/php.ini

[PHP]
; Resource Limits
memory_limit = 512M
max_execution_time = 300
max_input_time = 300
max_input_vars = 5000

; File Uploads
file_uploads = On
upload_max_filesize = 100M
post_max_size = 100M
max_file_uploads = 50

; Session
session.gc_maxlifetime = 7200
session.cookie_lifetime = 0
session.cookie_secure = 1
session.cookie_httponly = 1

; Error Reporting (Production)
display_errors = Off
display_startup_errors = Off
log_errors = On
error_log = /opt/bitnami/php/logs/php_errors.log

; OpCache Configuration
opcache.enable = 1
opcache.memory_consumption = 128
opcache.interned_strings_buffer = 8
opcache.max_accelerated_files = 4000
opcache.revalidate_freq = 60
opcache.fast_shutdown = 1

; Date/Time
date.timezone = "Europe/Istanbul"

; Security
expose_php = Off
allow_url_fopen = Off
allow_url_include = Off

; Extensions required by Moodle
extension=curl
extension=gd
extension=intl
extension=mbstring
extension=mysql
extension=openssl
extension=soap
extension=xml
extension=zip
extension=redis
```

---

## 🗄️ Database Optimization

### MariaDB Configuration

```ini
# config/mariadb/my.cnf

[mysqld]
# Basic Settings
port = 3306
socket = /opt/bitnami/mariadb/tmp/mysql.sock
tmpdir = /opt/bitnami/mariadb/tmp
max_allowed_packet = 256M
bind-address = 0.0.0.0

# Character Set
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
init-connect = 'SET NAMES utf8mb4'

# InnoDB Settings
innodb_file_per_table = 1
innodb_buffer_pool_size = 512M
innodb_log_file_size = 128M
innodb_log_buffer_size = 16M
innodb_flush_log_at_trx_commit = 2
innodb_flush_method = O_DIRECT

# Query Cache
query_cache_type = 1
query_cache_size = 128M
query_cache_limit = 4M

# Connection Settings
max_connections = 200
connect_timeout = 10
wait_timeout = 600
interactive_timeout = 600

# Thread Settings
thread_cache_size = 16
thread_stack = 256K

# Table Settings
table_open_cache = 4000
tmp_table_size = 64M
max_heap_table_size = 64M

# Logging
slow_query_log = 1
slow_query_log_file = /opt/bitnami/mariadb/logs/mysql_slow.log
long_query_time = 2
log_queries_not_using_indexes = 0

# Binary Logging (for replication)
log-bin = mysql-bin
binlog_format = ROW
expire_logs_days = 7

[mysql]
default-character-set = utf8mb4

[client]
default-character-set = utf8mb4
port = 3306
socket = /opt/bitnami/mariadb/tmp/mysql.sock
```

### Database Maintenance Scripts

```bash
#!/bin/bash
# scripts/db-maintenance.sh

# Database optimization script
DB_CONTAINER="moodle-lms-mariadb"
DB_USER="bn_moodle"
DB_PASS="secure_password_2025"
DB_NAME="bitnami_moodle"

echo "🔧 Database maintenance starting..."

# 1. Table optimization
echo "📊 Optimizing tables..."
docker exec $DB_CONTAINER mysqlcheck \
    --optimize --all-databases \
    -u $DB_USER -p$DB_PASS

# 2. Table repair
echo "🔨 Repairing tables..."
docker exec $DB_CONTAINER mysqlcheck \
    --repair --all-databases \
    -u $DB_USER -p$DB_PASS

# 3. Log cleanup
echo "🧹 Cleaning old logs..."
docker exec $DB_CONTAINER mysql \
    -u root -p$MARIADB_ROOT_PASSWORD \
    -e "PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 7 DAY);"

# 4. Update statistics
echo "📈 Updating statistics..."
docker exec $DB_CONTAINER mysql \
    -u $DB_USER -p$DB_PASS \
    -e "USE $DB_NAME; ANALYZE TABLE mdl_course, mdl_user, mdl_quiz, mdl_question;"

echo "✅ Database maintenance completed!"
```

---

## ⚡ Performance Tuning

### System Level Optimizations

```bash
# /etc/sysctl.conf optimizations
cat >> /etc/sysctl.conf << EOF

# Network optimizations
net.core.rmem_max = 268435456
net.core.wmem_max = 268435456
net.ipv4.tcp_rmem = 4096 65536 268435456
net.ipv4.tcp_wmem = 4096 65536 268435456
net.ipv4.tcp_congestion_control = bbr

# File descriptor limits
fs.file-max = 1000000

# Virtual memory
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5

EOF

# Apply changes
sysctl -p
```

### Docker Container Limits

```yaml
# Add resource limits to docker-compose.yml
services:
  mariadb:
    # ... other settings ...
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '2.0'
        reservations:
          memory: 512M
          cpus: '1.0'

  moodle:
    # ... other settings ...
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '4.0'
        reservations:
          memory: 1G
          cpus: '2.0'
          
  redis:
    # ... other settings ...
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1.0'
        reservations:
          memory: 256M
          cpus: '0.5'
```

### Moodle Cache Configuration

From Moodle admin panel **Site Administration > Plugins > Caching > Configuration**:

```php
// Cache store definitions
'default_application_store' => 'redis',
'default_session_store' => 'redis',
'default_request_store' => 'static',

// Custom cache definitions
$CFG->cache_stores = array(
    'redis_sessions' => array(
        'plugin' => 'cachestore_redis',
        'configuration' => array(
            'server' => 'redis:6379',
            'password' => getenv('REDIS_PASSWORD'),
            'database' => 0,
            'prefix' => 'mdl_sess_',
        ),
    ),
    'redis_application' => array(
        'plugin' => 'cachestore_redis',
        'configuration' => array(
            'server' => 'redis:6379',
            'password' => getenv('REDIS_PASSWORD'),
            'database' => 1,
            'prefix' => 'mdl_app_',
            'compressor' => 'gzip',
        ),
    ),
);
```

---

## 🔒 Security Configuration

### Firewall Rules

```bash
#!/bin/bash
# scripts/firewall-setup.sh

echo "🔥 Configuring firewall rules..."

# Reset UFW
sudo ufw --force reset

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# SSH (Port 22)
sudo ufw allow 22/tcp

# HTTP/HTTPS (Port 80, 443)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Moodle development port (local network only)
sudo ufw allow from 192.168.0.0/16 to any port 8080

# BigBlueButton ports (optional)
sudo ufw allow 1935/tcp
sudo ufw allow 7443/tcp

# Rate limiting (DDoS protection)
sudo ufw limit ssh
sudo ufw limit 80/tcp
sudo ufw limit 443/tcp

# Enable UFW
sudo ufw --force enable

echo "✅ Firewall rules activated!"
```

### Fail2ban Configuration

```bash
# Install Fail2ban
sudo apt install -y fail2ban

# Create custom filter for Moodle
sudo tee /etc/fail2ban/filter.d/moodle.conf << 'EOF'
[Definition]
failregex = ^<HOST> - .* "POST .*login.*" (4|5)\d\d
            ^<HOST> .* "POST .*login.*HTTP.*" (4|5)\d\d
ignoreregex =
EOF

# Jail configuration
sudo tee /etc/fail2ban/jail.d/moodle.conf << 'EOF'
[moodle]
enabled = true
port = http,https,8080
filter = moodle
logpath = /var/log/nginx/access.log
maxretry = 5
findtime = 600
bantime = 3600
action = iptables-multiport[name=moodle, port="http,https,8080"]
EOF

# Restart Fail2ban
sudo systemctl restart fail2ban
```

### SSL/TLS Security Settings

```nginx
# /etc/nginx/sites-available/moodle-lms
server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;
    
    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    
    # SSL Security
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Security Headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";
    
    # CSP Header (customized for Moodle)
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https:; style-src 'self' 'unsafe-inline' https:; img-src 'self' data: https:; font-src 'self' https:; connect-src 'self' https:; media-src 'self' https:; object-src 'none'; frame-src 'self' https:;";
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Upload size
        client_max_body_size 100M;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}

# HTTP to HTTPS redirect
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

---

## 🌍 Multi-language Settings

### Language Pack Installation

```bash
# Install language packs inside container
docker exec -it moodle-lms-moodle bash

# Install additional language packs
cd /opt/bitnami/moodle
php admin/cli/uninstall_language.php --lang=tr --confirm
php admin/cli/install_language.php --lang=tr

# German language pack
php admin/cli/install_language.php --lang=de

# English (installed by default)
php admin/cli/install_language.php --lang=en

# List available languages
php admin/cli/list_languages.php

exit
```

### Moodle Language Settings

```php
// Add to config.php
$CFG->lang = 'en';                    // Default language
$CFG->langmenu = true;                // Show language menu
$CFG->langlist = 'en,de,tr';          // Available languages
$CFG->langcache = true;               // Enable language cache
$CFG->langstringcache = true;         // Enable string cache
```

### Custom Language Strings

```bash
# Create custom language file
mkdir -p /opt/bitnami/moodle/lang/en_local

# Custom terms file
cat > /opt/bitnami/moodle/lang/en_local/moodle.php << 'EOF'
<?php
// Custom terms for Moodle LMS

$string['sitename'] = 'Moodle LMS';
$string['welcome'] = 'Welcome to Moodle Learning Management System';
$string['supportemail'] = 'For support: info@example.com';
$string['company'] = 'Educational Institution - Digital Learning Solutions';
?>
EOF
```

---

## 📧 Email Configuration

### SMTP Settings

```bash
# Add SMTP settings to .env file
cat >> .env << 'EOF'

# SMTP Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=tls
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# Email Settings
MOODLE_NOREPLY_EMAIL=noreply@example.com
MOODLE_SUPPORT_EMAIL=info@example.com
EOF
```

### Moodle Email Configuration

```php
// Add email settings to config.php
$CFG->smtphosts = getenv('SMTP_HOST') ?: 'localhost';
$CFG->smtpport = getenv('SMTP_PORT') ?: '587';
$CFG->smtpsecure = getenv('SMTP_SECURE') ?: 'tls';
$CFG->smtpuser = getenv('SMTP_USER') ?: '';
$CFG->smtppass = getenv('SMTP_PASS') ?: '';
$CFG->smtpmaxbulk = 1;

// Email addresses
$CFG->noreplyaddress = getenv('MOODLE_NOREPLY_EMAIL') ?: 'noreply@example.com';
$CFG->supportemail = getenv('MOODLE_SUPPORT_EMAIL') ?: 'info@example.com';

// Email settings
$CFG->allowedemaildomains = 'example.com,gmail.com,outlook.com,yahoo.com';
$CFG->emailchangeconfirmation = true;
$CFG->emaildisable = false;
```

### Email Test Script

```bash
#!/bin/bash
# scripts/test-email.sh

echo "📧 Testing email configuration..."

# Send test email via Moodle CLI
docker exec moodle-lms-moodle php /opt/bitnami/moodle/admin/cli/test_outgoing_mail.php \
    --to=test@example.com \
    --subject="Moodle LMS Test Email" \
    --message="This is a test email."

echo "✅ Test email sent! Please check your inbox."
```

---

## 💾 Backup Configuration

### Automated Backup System

```bash
#!/bin/bash
# scripts/automated-backup.sh

# Configuration
BACKUP_DIR="/opt/backups/moodle-lms"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RETENTION_DAYS=30
S3_BUCKET="your-backup-bucket"

# Slack webhook (optional)
SLACK_WEBHOOK="https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

send_slack_notification() {
    if [ -n "$SLACK_WEBHOOK" ]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"$1\"}" \
            "$SLACK_WEBHOOK"
    fi
}

# Create backup directory
mkdir -p "$BACKUP_DIR"

log "🔄 Moodle LMS automated backup starting..."
send_slack_notification "🔄 Moodle LMS backup started"

# 1. Database backup
log "📊 Creating database backup..."
docker exec moodle-lms-mariadb mysqldump \
    --single-transaction \
    --routines \
    --triggers \
    -u bn_moodle -psecure_password_2025 bitnami_moodle \
    | gzip > "$BACKUP_DIR/database_$TIMESTAMP.sql.gz"

if [ $? -eq 0 ]; then
    log "✅ Database backup completed"
else
    log "❌ Database backup failed!"
    send_slack_notification "❌ Moodle LMS database backup failed!"
    exit 1
fi

# 2. Moodle data backup
log "📁 Creating Moodle data backup..."
docker run --rm \
    -v moodle-lms_moodledata_data:/data:ro \
    -v "$BACKUP_DIR":/backup \
    alpine tar czf "/backup/moodledata_$TIMESTAMP.tar.gz" -C /data .

# 3. Configuration backup
log "⚙️ Creating configuration backup..."
tar czf "$BACKUP_DIR/config_$TIMESTAMP.tar.gz" \
    -C /opt/moodle-lms \
    docker-compose.yml \
    .env \
    config/ \
    scripts/

# 4. Upload to AWS S3 (optional)
if command -v aws &> /dev/null && [ -n "$S3_BUCKET" ]; then
    log "☁️ Uploading to S3..."
    aws s3 sync "$BACKUP_DIR" "s3://$S3_BUCKET/moodle-lms/" --delete
    
    if [ $? -eq 0 ]; then
        log "✅ S3 upload completed"
    else
        log "❌ S3 upload failed!"
    fi
fi

# 5. Clean old backups
log "🧹 Cleaning old backups..."
find "$BACKUP_DIR" -type f -mtime +$RETENTION_DAYS -delete

# 6. Calculate backup size
BACKUP_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)

log "✅ Backup completed! Total size: $BACKUP_SIZE"
send_slack_notification "✅ Moodle LMS backup completed! Size: $BACKUP_SIZE"

# 7. Backup verification
log "🔍 Verifying backup..."
if [ -f "$BACKUP_DIR/database_$TIMESTAMP.sql.gz" ] && \
   [ -f "$BACKUP_DIR/moodledata_$TIMESTAMP.tar.gz" ] && \
   [ -f "$BACKUP_DIR/config_$TIMESTAMP.tar.gz" ]; then
    log "✅ All backup files created successfully"
else
    log "❌ Some backup files are missing!"
    send_slack_notification "❌ Moodle LMS backup verification failed!"
    exit 1
fi
```

### Crontab Configuration

```bash
# Install backup crontab
cat > /tmp/backup-crontab << 'EOF'
# Moodle LMS Backup Schedule

# Daily database backup (every night at 02:00)
0 2 * * * /opt/moodle-lms/scripts/automated-backup.sh >> /var/log/moodle-lms-backup.log 2>&1

# Weekly full backup (Sunday at 03:00)
0 3 * * 0 /opt/moodle-lms/scripts/automated-backup.sh --full >> /var/log/moodle-lms-backup.log 2>&1

# Monthly backup cleanup (1st of each month at 04:00)
0 4 1 * * find /opt/backups/moodle-lms -type f -mtime +90 -delete >> /var/log/moodle-lms-cleanup.log 2>&1
EOF

# Load crontab
crontab /tmp/backup-crontab
rm /tmp/backup-crontab

echo "✅ Backup crontab configured"
```

---

## 📞 Support

For questions about this configuration guide:

- 🐛 **GitHub Issues**: [Issues page](https://github.com/umur957/moodle-lms/issues)
- 📚 **Documentation**: [docs/](../README.md)

---

*This configuration guide is continuously updated. You can share your suggestions through GitHub Issues.*