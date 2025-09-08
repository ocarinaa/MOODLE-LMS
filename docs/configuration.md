# ⚙️ TurfaLearn Konfigürasyon Rehberi

TurfaLearn sisteminin detaylı yapılandırma seçenekleri ve optimizasyon ayarları.

## 📋 İçindekiler

1. [Docker Compose Konfigürasyonu](#docker-compose-konfigürasyonu)
2. [Moodle Konfigürasyonu](#moodle-konfigürasyonu)
3. [Veritabanı Optimizasyonu](#veritabanı-optimizasyonu)
4. [Performance Tuning](#performance-tuning)
5. [Güvenlik Yapılandırması](#güvenlik-yapılandırması)
6. [Çoklu Dil Ayarları](#çoklu-dil-ayarları)
7. [Email Konfigürasyonu](#email-konfigürasyonu)
8. [Backup Yapılandırması](#backup-yapılandırması)

---

## 🐳 Docker Compose Konfigürasyonu

### Temel Yapılandırma

```yaml
version: '3'

services:
  mariadb:
    image: bitnami/mariadb:latest
    container_name: turfalearn-mariadb
    environment:
      # Temel Veritabanı Ayarları
      - MARIADB_USER=bn_moodle
      - MARIADB_PASSWORD=secure_password_2025
      - MARIADB_DATABASE=bitnami_moodle
      - MARIADB_ROOT_PASSWORD=root_secure_password_2025
      - ALLOW_EMPTY_PASSWORD=no
      
      # Performans Optimizasyonu
      - MARIADB_INNODB_BUFFER_POOL_SIZE=512M
      - MARIADB_QUERY_CACHE_SIZE=128M
      - MARIADB_QUERY_CACHE_TYPE=1
      - MARIADB_MAX_CONNECTIONS=200
      - MARIADB_THREAD_CACHE_SIZE=16
      
      # Karakter Seti (Türkçe ve Emoji desteği)
      - MARIADB_CHARACTER_SET=utf8mb4
      - MARIADB_COLLATE=utf8mb4_unicode_ci
      
    volumes:
      - mariadb_data:/bitnami/mariadb
      - ./config/mariadb/my.cnf:/opt/bitnami/mariadb/conf/my.cnf:ro
    restart: always
    networks:
      - turfalearn_network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 5s
      retries: 10

  moodle:
    image: bitnami/moodle:latest
    container_name: turfalearn-moodle
    environment:
      # Veritabanı Bağlantı Ayarları
      - MARIADB_HOST=mariadb
      - MARIADB_PORT_NUMBER=3306
      - MOODLE_DATABASE_USER=bn_moodle
      - MOODLE_DATABASE_PASSWORD=secure_password_2025
      - MOODLE_DATABASE_NAME=bitnami_moodle
      
      # Site Temel Ayarları
      - MOODLE_SITE_NAME=TurfaLearn
      - MOODLE_USERNAME=admin
      - MOODLE_PASSWORD=Admin_Secure_2025!
      - MOODLE_EMAIL=admin@tuerfa.de
      - MOODLE_SKIP_BOOTSTRAP=no
      
      # Dil ve Lokalizasyon
      - MOODLE_LANG=tr
      - TZ=Europe/Istanbul
      
      # PHP Optimizasyon
      - PHP_MEMORY_LIMIT=512M
      - PHP_MAX_EXECUTION_TIME=300
      - PHP_UPLOAD_MAX_FILESIZE=100M
      - PHP_POST_MAX_SIZE=100M
      - PHP_MAX_INPUT_VARS=5000
      
      # Apache Ayarları
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
      - turfalearn_network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/login/index.php"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Redis Cache (Performance için)
  redis:
    image: bitnami/redis:latest
    container_name: turfalearn-redis
    environment:
      - REDIS_PASSWORD=redis_secure_password_2025
      - REDIS_DISABLE_COMMANDS=FLUSHDB,FLUSHALL,CONFIG
      - REDIS_MAXMEMORY=256mb
      - REDIS_MAXMEMORY_POLICY=allkeys-lru
    volumes:
      - redis_data:/bitnami/redis
    restart: always
    networks:
      - turfalearn_network

networks:
  turfalearn_network:
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

### Environment Dosyası (.env)

```bash
# .env dosyası oluştur
cat > .env << 'EOF'
# TurfaLearn Environment Configuration

# Site Configuration
MOODLE_SITE_NAME=TurfaLearn
MOODLE_URL=https://your-domain.com
MOODLE_ADMIN_EMAIL=admin@tuerfa.de

# Admin Account
MOODLE_USERNAME=admin
MOODLE_PASSWORD=Generate_Strong_Password_Here!
MOODLE_EMAIL=admin@tuerfa.de

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
MOODLE_LANG=tr

# Performance
PHP_MEMORY_LIMIT=512M
PHP_MAX_EXECUTION_TIME=300

# BigBlueButton (Opsiyonel)
BBB_SERVER_URL=https://your-bbb-server.com/bigbluebutton/api/
BBB_SHARED_SECRET=your_bbb_shared_secret

# Examus (Opsiyonel)
EXAMUS_API_TOKEN=your_examus_api_token
EXAMUS_API_URL=https://your-domain.com/webservice/rest/server.php
EOF

# .env dosyasını güvenli hale getir
chmod 600 .env
```

---

## 📚 Moodle Konfigürasyonu

### config.php Detaylı Ayarları

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
$CFG->lang = getenv('MOODLE_LANG') ?: 'tr';
$CFG->langmenu = true;
$CFG->langlist = 'tr,de,en';

//=========================================================================
// 6. PERFORMANCE SETTINGS
//=========================================================================
// Caching
$CFG->cachejs = true;
$CFG->cachetemplates = true;
$CFG->cachetext = 60;

// Session handling
$CFG->sessiontimeout = 7200;
$CFG->sessioncookie = 'TurfaLMS';
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

// IP Restriction (opsiyonel)
// $CFG->allowedips = '192.168.1.0/24,10.0.0.0/8';

//=========================================================================
// 8. EMAIL SETTINGS
//=========================================================================
$CFG->smtphosts = getenv('SMTP_HOST') ?: 'localhost';
$CFG->smtpsecure = 'tls';
$CFG->smtpuser = getenv('SMTP_USER') ?: '';
$CFG->smtppass = getenv('SMTP_PASS') ?: '';
$CFG->smtpmaxbulk = 1;
$CFG->noreplyaddress = getenv('MOODLE_ADMIN_EMAIL') ?: 'noreply@tuerfa.de';
$CFG->supportemail = getenv('MOODLE_ADMIN_EMAIL') ?: 'info@tuerfa.de';

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
// 12. DEBUG SETTINGS (Production'da disable edilmeli)
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
$CFG->maintenance_message = 'Site bakımda. Lütfen daha sonra tekrar deneyin.';

require_once(__DIR__ . '/lib/setup.php');
?>
```

### PHP Konfigürasyonu

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

## 🗄️ Veritabanı Optimizasyonu

### MariaDB Konfigürasyonu

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

# Binary Logging (Replication için)
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

### Veritabanı Bakım Scriptleri

```bash
#!/bin/bash
# scripts/db-maintenance.sh

# Veritabanı optimizasyon scripti
DB_CONTAINER="turfalearn-mariadb"
DB_USER="bn_moodle"
DB_PASS="secure_password_2025"
DB_NAME="bitnami_moodle"

echo "🔧 Veritabanı bakımı başlıyor..."

# 1. Tablo optimizasyonu
echo "📊 Tabloları optimize ediliyor..."
docker exec $DB_CONTAINER mysqlcheck \
    --optimize --all-databases \
    -u $DB_USER -p$DB_PASS

# 2. Tablo onarımı
echo "🔨 Tablolar onarılıyor..."
docker exec $DB_CONTAINER mysqlcheck \
    --repair --all-databases \
    -u $DB_USER -p$DB_PASS

# 3. Log temizliği
echo "🧹 Eski loglar temizleniyor..."
docker exec $DB_CONTAINER mysql \
    -u root -p$MARIADB_ROOT_PASSWORD \
    -e "PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 7 DAY);"

# 4. İstatistik güncelleme
echo "📈 İstatistikler güncelleniyor..."
docker exec $DB_CONTAINER mysql \
    -u $DB_USER -p$DB_PASS \
    -e "USE $DB_NAME; ANALYZE TABLE mdl_course, mdl_user, mdl_quiz, mdl_question;"

echo "✅ Veritabanı bakımı tamamlandı!"
```

---

## ⚡ Performance Tuning

### Sistem Düzeyinde Optimizasyonlar

```bash
# /etc/sysctl.conf optimizasyonları
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

# Değişiklikleri uygula
sysctl -p
```

### Docker Container Limits

```yaml
# docker-compose.yml'ye resource limits ekle
services:
  mariadb:
    # ... diğer ayarlar ...
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '2.0'
        reservations:
          memory: 512M
          cpus: '1.0'

  moodle:
    # ... diğer ayarlar ...
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '4.0'
        reservations:
          memory: 1G
          cpus: '2.0'
          
  redis:
    # ... diğer ayarlar ...
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1.0'
        reservations:
          memory: 256M
          cpus: '0.5'
```

### Moodle Cache Yapılandırması

Moodle admin panelinden **Site Administration > Plugins > Caching > Configuration**:

```php
// Cache store tanımları
'default_application_store' => 'redis',
'default_session_store' => 'redis',
'default_request_store' => 'static',

// Özel cache definitions
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

## 🔒 Güvenlik Yapılandırması

### Firewall Kuralları

```bash
#!/bin/bash
# scripts/firewall-setup.sh

echo "🔥 Firewall kuralları yapılandırılıyor..."

# UFW'yi sıfırla
sudo ufw --force reset

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# SSH (Port 22)
sudo ufw allow 22/tcp

# HTTP/HTTPS (Port 80, 443)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Moodle development port (sadece local network)
sudo ufw allow from 192.168.0.0/16 to any port 8080

# BigBlueButton portları (opsiyonel)
sudo ufw allow 1935/tcp
sudo ufw allow 7443/tcp

# Rate limiting (DDoS protection)
sudo ufw limit ssh
sudo ufw limit 80/tcp
sudo ufw limit 443/tcp

# UFW'yi aktifleştir
sudo ufw --force enable

echo "✅ Firewall kuralları aktifleştirildi!"
```

### Fail2ban Yapılandırması

```bash
# Fail2ban kur
sudo apt install -y fail2ban

# Moodle için özel filter
sudo tee /etc/fail2ban/filter.d/moodle.conf << 'EOF'
[Definition]
failregex = ^<HOST> - .* "POST .*login.*" (4|5)\d\d
            ^<HOST> .* "POST .*login.*HTTP.*" (4|5)\d\d
ignoreregex =
EOF

# Jail konfigürasyonu
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

# Fail2ban'ı yeniden başlat
sudo systemctl restart fail2ban
```

### SSL/TLS Güvenlik Ayarları

```nginx
# /etc/nginx/sites-available/turfalearn
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
    
    # CSP Header (Moodle için özelleştirilmiş)
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

## 🌍 Çoklu Dil Ayarları

### Dil Paketi Kurulumu

```bash
# Container içinde dil paketlerini kur
docker exec -it turfalearn-moodle bash

# Türkçe dil paketi
cd /opt/bitnami/moodle
php admin/cli/uninstall_language.php --lang=tr --confirm
php admin/cli/install_language.php --lang=tr

# Almanca dil paketi
php admin/cli/install_language.php --lang=de

# İngilizce (varsayılan olarak yüklü)
php admin/cli/install_language.php --lang=en

# Mevcut dilleri listele
php admin/cli/list_languages.php

exit
```

### Moodle Dil Ayarları

```php
// config.php'ye ekle
$CFG->lang = 'tr';                    // Varsayılan dil
$CFG->langmenu = true;                // Dil menüsünü göster
$CFG->langlist = 'tr,de,en';          // Mevcut diller
$CFG->langcache = true;               // Dil cache'ini aktifleştir
$CFG->langstringcache = true;         // String cache'ini aktifleştir
```

### Özel Dil Dizgeleri

```bash
# Özel dil dosyası oluştur
mkdir -p /opt/bitnami/moodle/lang/tr_local

# Özel terimler için dosya
cat > /opt/bitnami/moodle/lang/tr_local/moodle.php << 'EOF'
<?php
// TurfaLearn özel terimleri

$string['sitename'] = 'TurfaLearn';
$string['welcome'] = 'TurfaLearn Öğrenme Yönetim Sistemine Hoş Geldiniz';
$string['supportemail'] = 'Destek için: info@tuerfa.de';
$string['company'] = 'Turfa GbR - Dijital Eğitim Çözümleri';
?>
EOF
```

---

## 📧 Email Konfigürasyonu

### SMTP Ayarları

```bash
# .env dosyasına SMTP ayarları ekle
cat >> .env << 'EOF'

# SMTP Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=tls
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# Email Settings
MOODLE_NOREPLY_EMAIL=noreply@tuerfa.de
MOODLE_SUPPORT_EMAIL=info@tuerfa.de
EOF
```

### Moodle Email Yapılandırması

```php
// config.php'ye email ayarları
$CFG->smtphosts = getenv('SMTP_HOST') ?: 'localhost';
$CFG->smtpport = getenv('SMTP_PORT') ?: '587';
$CFG->smtpsecure = getenv('SMTP_SECURE') ?: 'tls';
$CFG->smtpuser = getenv('SMTP_USER') ?: '';
$CFG->smtppass = getenv('SMTP_PASS') ?: '';
$CFG->smtpmaxbulk = 1;

// Email adresleri
$CFG->noreplyaddress = getenv('MOODLE_NOREPLY_EMAIL') ?: 'noreply@tuerfa.de';
$CFG->supportemail = getenv('MOODLE_SUPPORT_EMAIL') ?: 'info@tuerfa.de';

// Email ayarları
$CFG->allowedemaildomains = 'tuerfa.de,gmail.com,outlook.com,yahoo.com';
$CFG->emailchangeconfirmation = true;
$CFG->emaildisable = false;
```

### Email Test Scripti

```bash
#!/bin/bash
# scripts/test-email.sh

echo "📧 Email yapılandırması test ediliyor..."

# Moodle CLI ile test emaili gönder
docker exec turfalearn-moodle php /opt/bitnami/moodle/admin/cli/test_outgoing_mail.php \
    --to=test@tuerfa.de \
    --subject="TurfaLearn Test Email" \
    --message="Bu bir test emailidir."

echo "✅ Test emaili gönderildi! Gelen kutusunu kontrol edin."
```

---

## 💾 Backup Yapılandırması

### Otomatik Backup Sistemi

```bash
#!/bin/bash
# scripts/automated-backup.sh

# Yapılandırma
BACKUP_DIR="/opt/backups/turfalearn"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RETENTION_DAYS=30
S3_BUCKET="your-backup-bucket"

# Slack webhook (opsiyonel)
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

# Backup dizinini oluştur
mkdir -p "$BACKUP_DIR"

log "🔄 TurfaLearn otomatik backup başlıyor..."
send_slack_notification "🔄 TurfaLearn backup başladı"

# 1. Database backup
log "📊 Veritabanı yedeği alınıyor..."
docker exec turfalearn-mariadb mysqldump \
    --single-transaction \
    --routines \
    --triggers \
    -u bn_moodle -psecure_password_2025 bitnami_moodle \
    | gzip > "$BACKUP_DIR/database_$TIMESTAMP.sql.gz"

if [ $? -eq 0 ]; then
    log "✅ Veritabanı yedeği tamamlandı"
else
    log "❌ Veritabanı yedeği başarısız!"
    send_slack_notification "❌ TurfaLearn veritabanı backup başarısız!"
    exit 1
fi

# 2. Moodle data backup
log "📁 Moodle veri yedeği alınıyor..."
docker run --rm \
    -v turfalearn_moodledata_data:/data:ro \
    -v "$BACKUP_DIR":/backup \
    alpine tar czf "/backup/moodledata_$TIMESTAMP.tar.gz" -C /data .

# 3. Configuration backup
log "⚙️ Konfigürasyon yedeği alınıyor..."
tar czf "$BACKUP_DIR/config_$TIMESTAMP.tar.gz" \
    -C /opt/turfalearn \
    docker-compose.yml \
    .env \
    config/ \
    scripts/

# 4. AWS S3'e yükle (opsiyonel)
if command -v aws &> /dev/null && [ -n "$S3_BUCKET" ]; then
    log "☁️ S3'e yükleniyor..."
    aws s3 sync "$BACKUP_DIR" "s3://$S3_BUCKET/turfalearn/" --delete
    
    if [ $? -eq 0 ]; then
        log "✅ S3 yükleme tamamlandı"
    else
        log "❌ S3 yükleme başarısız!"
    fi
fi

# 5. Eski backupları temizle
log "🧹 Eski backuplar temizleniyor..."
find "$BACKUP_DIR" -type f -mtime +$RETENTION_DAYS -delete

# 6. Backup boyutunu hesapla
BACKUP_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)

log "✅ Backup tamamlandı! Toplam boyut: $BACKUP_SIZE"
send_slack_notification "✅ TurfaLearn backup tamamlandı! Boyut: $BACKUP_SIZE"

# 7. Backup doğrulama
log "🔍 Backup doğrulaması..."
if [ -f "$BACKUP_DIR/database_$TIMESTAMP.sql.gz" ] && \
   [ -f "$BACKUP_DIR/moodledata_$TIMESTAMP.tar.gz" ] && \
   [ -f "$BACKUP_DIR/config_$TIMESTAMP.tar.gz" ]; then
    log "✅ Tüm backup dosyları başarıyla oluşturuldu"
else
    log "❌ Bazı backup dosyları eksik!"
    send_slack_notification "❌ TurfaLearn backup doğrulaması başarısız!"
    exit 1
fi
```

### Crontab Yapılandırması

```bash
# Backup crontab'ını kur
cat > /tmp/backup-crontab << 'EOF'
# TurfaLearn Backup Schedule

# Günlük database backup (her gece 02:00)
0 2 * * * /opt/turfalearn/scripts/automated-backup.sh >> /var/log/turfalearn-backup.log 2>&1

# Haftalık full backup (Pazar 03:00)
0 3 * * 0 /opt/turfalearn/scripts/automated-backup.sh --full >> /var/log/turfalearn-backup.log 2>&1

# Aylık backup temizliği (her ayın 1'i 04:00)
0 4 1 * * find /opt/backups/turfalearn -type f -mtime +90 -delete >> /var/log/turfalearn-cleanup.log 2>&1
EOF

# Crontab'ı yükle
crontab /tmp/backup-crontab
rm /tmp/backup-crontab

echo "✅ Backup crontab yapılandırıldı"
```

---

## 📞 Destek

Bu konfigürasyon rehberi ile ilgili sorularınız için:

- 🐛 **GitHub Issues**: [Issues sayfası](https://github.com/umur957/moodle-render/issues)
- 📧 **Email**: info@tuerfa.de
- 📱 **Telefon**: +90 0533 924 3850
- 📚 **Dokümantasyon**: [docs/](../README.md)

---

*Bu konfigürasyon rehberi sürekli güncellenmektedir. Önerilerinizi GitHub Issues üzerinden paylaşabilirsiniz.*

*© 2025 Turfa GbR. Tüm hakları saklıdır.*