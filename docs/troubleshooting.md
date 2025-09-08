# 🔧 TurfaLearn - Sorun Giderme Kılavuzu

<div align="center">
  <img src="https://via.placeholder.com/150x100.png?text=Troubleshooting" alt="Troubleshooting" width="150"/>
  <h3>Sorunları Çözelim!</h3>
  <p><em>Adım adım çözüm rehberi</em></p>
</div>

---

## 📋 İçindekiler

1. [Hızlı Tanı](#hızlı-tanı)
2. [Kurulum Sorunları](#kurulum-sorunları)
3. [Docker Sorunları](#docker-sorunları)
4. [Moodle Sorunları](#moodle-sorunları)
5. [Veritabanı Sorunları](#veritabanı-sorunları)
6. [Entegrasyon Sorunları](#entegrasyon-sorunları)
7. [Performans Sorunları](#performans-sorunları)
8. [Güvenlik Sorunları](#güvenlik-sorunları)
9. [Log Analizi](#log-analizi)
10. [Acil Durum Kurtarma](#acil-durum-kurtarma)

---

## 🩺 Hızlı Tanı

### ⚡ **Sistem Durumu Kontrolü**

```bash
# Temel sistem kontrolü
./quick-diagnose.sh

# Veya manuel kontrol
echo "=== TurfaLearn System Check ==="
echo "Docker Status: $(docker --version 2>/dev/null || echo 'NOT INSTALLED')"
echo "Docker Compose: $(docker-compose --version 2>/dev/null || echo 'NOT INSTALLED')"
echo "Services Status:"
docker-compose ps 2>/dev/null || echo "Docker Compose not running"
echo "Disk Space: $(df -h . | tail -1 | awk '{print $4}')"
echo "Memory Usage: $(free -h | grep Mem | awk '{print $3"/"$2}')"
```

### 🚦 **Servis Durum Kontrolleri**

| Servis | Kontrol Komutu | Beklenen Durum |
|--------|----------------|----------------|
| **Moodle** | `curl -f http://localhost:8080` | HTTP 200 |
| **MariaDB** | `docker exec mariadb mysqladmin ping` | `mysqld is alive` |
| **Docker** | `docker info` | Çalışır durumda |

---

## 🏗️ Kurulum Sorunları

### ❌ **Problem: "Docker bulunamadı"**

**Belirti:**
```
bash: docker: command not found
```

**Çözüm:**
```bash
# Ubuntu/Debian için Docker kurulumu
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Kullanıcıyı docker grubuna ekle
sudo usermod -aG docker $USER

# Yeniden giriş yapın veya:
newgrp docker

# Docker servisini başlat
sudo systemctl start docker
sudo systemctl enable docker
```

### ❌ **Problem: "İzin reddedildi (Permission denied)"**

**Belirti:**
```
docker: permission denied while trying to connect to the Docker daemon socket
```

**Çözüm:**
```bash
# Mevcut kullanıcıyı docker grubuna ekle
sudo usermod -aG docker $USER

# Grup değişikliğini aktifleştir
newgrp docker

# Veya sistemi yeniden başlatın
sudo reboot
```

### ❌ **Problem: "Port zaten kullanımda"**

**Belirti:**
```
ERROR: for moodle  Cannot start service moodle: driver failed programming external connectivity on endpoint
```

**Çözüm:**
```bash
# Port 8080'i kullanan süreci bul
sudo lsof -i :8080

# Süreci sonlandır (PID ile)
sudo kill -9 <PID>

# Veya farklı port kullan (docker-compose.yml)
ports:
  - "8081:8080"  # 8081 portunu kullan
```

---

## 🐳 Docker Sorunları

### ❌ **Problem: Konteyner sürekli yeniden başlıyor**

**Belirti:**
```bash
docker-compose ps
# Status: Restarting
```

**Tanı ve Çözüm:**
```bash
# Logları kontrol et
docker-compose logs moodle

# Detaylı log
docker logs --details moodle-container-name

# Konteyner içine gir ve manuel test et
docker exec -it moodle-container-name bash

# Memory sorununu kontrol et
docker stats
```

**Olası çözümler:**
```yaml
# docker-compose.yml memory limit arttır
services:
  moodle:
    # ... diğer ayarlar
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 1G
```

### ❌ **Problem: Volume mount sorunları**

**Belirti:**
```
Error response from daemon: invalid mount config
```

**Çözüm:**
```bash
# Volume'leri temizle (DİKKAT: Veri kaybolur!)
docker-compose down -v

# Volume'leri yeniden oluştur
docker volume create moodle-render_moodle_data
docker volume create moodle-render_moodledata_data
docker volume create moodle-render_mariadb_data

# Yeniden başlat
docker-compose up -d
```

### ❌ **Problem: Network bağlantı sorunları**

**Belirti:**
```
moodle    | mysqli::real_connect(): (HY000/2002): Connection refused
```

**Çözüm:**
```bash
# Network durumunu kontrol et
docker network ls
docker network inspect moodle-render_default

# Network yeniden oluştur
docker-compose down
docker network prune -f
docker-compose up -d
```

---

## 🎓 Moodle Sorunları

### ❌ **Problem: "Site under maintenance" mesajı**

**Belirti:**
- Ana sayfa maintenance mode gösteriyor
- Admin paneline erişilemyor

**Çözüm:**
```bash
# Konteyner içine gir
docker exec -it moodle-render_moodle_1 bash

# Maintenance mode kapat
php admin/cli/maintenance.php --disable

# Veya config.php dosyasını düzenle
vi /opt/bitnami/moodle/config.php
# Bu satırı kaldır veya comment'le:
# $CFG->maintenance_enabled = true;
```

### ❌ **Problem: "Invalid login credentials"**

**Belirti:**
- admin / Admin@12345 ile giriş yapılamıyor

**Çözüm:**
```bash
# Konteyner içine gir
docker exec -it moodle-render_moodle_1 bash

# Admin şifresini sıfırla
php admin/cli/reset_password.php --username=admin --password=NewPassword123!

# Veya yeni admin kullanıcı oluştur
php admin/cli/install_database.php --adminuser=newadmin --adminpass=NewPass123! --adminemail=admin@example.com
```

### ❌ **Problem: Türkçe karakterler bozuk görünüyor**

**Belirti:**
- Türkçe karakterler ? veya garip simgeler olarak görünüyor

**Çözüm:**
```bash
# Veritabanı karakter setini kontrol et
docker exec -it moodle-render_mariadb_1 mysql -u bn_moodle -pbitnami123 -e "
SELECT DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME 
FROM information_schema.SCHEMATA 
WHERE SCHEMA_NAME='bitnami_moodle';"

# UTF-8 character set ayarla
docker exec -it moodle-render_mariadb_1 mysql -u bn_moodle -pbitnami123 -e "
ALTER DATABASE bitnami_moodle CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

### ❌ **Problem: File upload çalışmıyor**

**Belirti:**
- Dosya yükleme işlemleri başarısız oluyor

**Çözüm:**
```bash
# Upload limitleri kontrol et
docker exec moodle-render_moodle_1 php -i | grep -E "(upload_max_filesize|post_max_size|max_execution_time)"

# Moodle data dizin izinlerini kontrol et
docker exec moodle-render_moodle_1 ls -la /bitnami/moodledata/

# İzinleri düzelt
docker exec moodle-render_moodle_1 chown -R bitnami:bitnami /bitnami/moodledata/
docker exec moodle-render_moodle_1 chmod -R 755 /bitnami/moodledata/
```

---

## 💾 Veritabanı Sorunları

### ❌ **Problem: "Database connection failed"**

**Belirti:**
```
Error: Database connection failed.
It is possible that the database is overloaded or otherwise not running properly.
```

**Çözüm:**
```bash
# MariaDB konteyner durumunu kontrol et
docker-compose ps mariadb

# MariaDB loglarını kontrol et
docker-compose logs mariadb

# Database bağlantısını test et
docker exec -it moodle-render_mariadb_1 mysql -u bn_moodle -pbitnami123 -e "SELECT 1;"

# MariaDB yeniden başlat
docker-compose restart mariadb
```

### ❌ **Problem: "Table doesn't exist" hataları**

**Belirti:**
```
ERROR 1146 (42S02): Table 'bitnami_moodle.mdl_config' doesn't exist
```

**Çözüm:**
```bash
# Database restore işlemi
docker exec -it moodle-render_mariadb_1 mysql -u root -proot_password

# Database durumunu kontrol et
SHOW DATABASES;
USE bitnami_moodle;
SHOW TABLES;

# Eğer tablolar yoksa, restore işlemi yap
# Backup dosyanız varsa:
cat backup.sql | docker exec -i moodle-render_mariadb_1 mysql -u bn_moodle -pbitnami123 bitnami_moodle
```

### ❌ **Problem: Database corrupt hatası**

**Belirti:**
```
MySQL server has gone away
Error reading from database
```

**Çözüm:**
```bash
# Database repair
docker exec -it moodle-render_mariadb_1 mysqlcheck --repair --all-databases -u root -proot_password

# Tablo bazlı repair
docker exec -it moodle-render_mariadb_1 mysql -u root -proot_password bitnami_moodle -e "
REPAIR TABLE mdl_sessions;
REPAIR TABLE mdl_log;
REPAIR TABLE mdl_config;
"

# İnnoDB recovery mode
# my.cnf dosyasına ekle: innodb_force_recovery = 1
```

---

## 🔌 Entegrasyon Sorunları

### 📹 **BigBlueButton Sorunları**

**❌ Problem: "Unable to join meeting"**

```bash
# BBB sunucu durumunu kontrol et
curl -f "https://your-bbb-server.com/bigbluebutton/api"

# Moodle config kontrolü
docker exec moodle-render_moodle_1 grep -r "bigbluebutton" /opt/bitnami/moodle/config.php

# API secret doğrulaması
# config.php'deki secret ile BBB sunucusu secret'ının eşleşmesi gerekir
```

**Çözüm:**
```php
// config.php güncellemesi
$CFG->bigbluebuttonbn_server_url = 'https://correct-bbb-server.com/bigbluebutton/api/';
$CFG->bigbluebuttonbn_shared_secret = 'correct_secret_key';
```

### 🔍 **Examus Gözetim Sistemi Sorunları**

**❌ Problem: "Unable to start proctoring session"**

```bash
# Web service token kontrolü
docker exec moodle-render_moodle_1 php -r "
require_once('/opt/bitnami/moodle/config.php');
echo 'Token: ' . get_config('examus', 'token') . \"\n\";
"

# API endpoint test
curl -X POST "http://your-domain.com/webservice/rest/server.php" \
  -d "wstoken=87b5bfe408e6dbe60c21f1630202c02d" \
  -d "wsfunction=core_user_get_users" \
  -d "moodlewsrestformat=json"
```

### 🛡️ **Safe Exam Browser Sorunları**

**❌ Problem: "SEB not detected"**

```bash
# SEB konfigürasyonu kontrol et
docker exec moodle-render_moodle_1 find /opt/bitnami/moodle -name "*seb*" -type f

# Config dosyası oluştur
docker exec moodle-render_moodle_1 php admin/cli/cfg.php --name=seb_enabled --set=1
```

---

## ⚡ Performans Sorunları

### ❌ **Problem: Yavaş sayfa yüklenme**

**Tanı:**
```bash
# Sistem kaynak kullanımı
docker stats

# Disk I/O kontrol
iostat -x 1

# Memory leak kontrolü
docker exec moodle-render_moodle_1 php admin/cli/check_database_schema.php
```

**Çözümler:**

1. **Cache temizliği:**
```bash
# Moodle cache temizle
docker exec moodle-render_moodle_1 php admin/cli/purge_caches.php

# Browser cache temizle
# Tarayıcıda Ctrl+Shift+R
```

2. **Database optimizasyonu:**
```bash
# Database optimize et
docker exec -it moodle-render_mariadb_1 mysqlcheck --optimize --all-databases -u root -proot_password

# Slow query log etkinleştir
docker exec -it moodle-render_mariadb_1 mysql -u root -proot_password -e "
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL slow_query_log_file = '/var/log/mysql/slow.log';
SET GLOBAL long_query_time = 2;
"
```

3. **Resource limits artır:**
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

### ❌ **Problem: Yüksek CPU kullanımı**

**Tanı:**
```bash
# Top processes
docker exec moodle-render_moodle_1 top

# PHP processes
docker exec moodle-render_moodle_1 ps aux | grep php
```

**Çözüm:**
```bash
# PHP-FPM ayarları optimize et
docker exec moodle-render_moodle_1 vi /opt/bitnami/php/etc/php-fpm.d/www.conf

# Cron job sıklığını azalt
docker exec moodle-render_moodle_1 crontab -e
# */15 yerine */30 dakika yap
```

---

## 🔒 Güvenlik Sorunları

### ❌ **Problem: "Unauthorized access" uyarıları**

**Belirti:**
- Log dosyalarında şüpheli aktivite
- Bilinmeyen IP adreslerinden erişim

**Çözüm:**
```bash
# IP whitelist ayarla
docker exec moodle-render_moodle_1 php admin/cli/cfg.php --name=allowedips --set="192.168.1.0/24"

# Security headers ekle
# Apache config dosyasına:
Header always set X-Frame-Options DENY
Header always set X-Content-Type-Options nosniff
Header always set X-XSS-Protection "1; mode=block"
```

### ❌ **Problem: SSL sertifikası sorunları**

**Belirti:**
- "Not secure" uyarısı
- Mixed content hataları

**Çözüm:**
```bash
# Let's Encrypt sertifikası yenile
certbot renew --dry-run

# Sertifika durumunu kontrol et
openssl x509 -in /etc/ssl/certs/certificate.crt -text -noout

# Forced HTTPS aktifleştir
docker exec moodle-render_moodle_1 php admin/cli/cfg.php --name=httpswwwroot --set="https://your-domain.com"
```

---

## 📊 Log Analizi

### 🔍 **Log Dosyası Konumları**

| Servis | Log Dosyası | Konum |
|--------|-------------|--------|
| **Moodle** | Error Log | `/opt/bitnami/moodle/error.log` |
| **Apache** | Access Log | `/opt/bitnami/apache/logs/access_log` |
| **MariaDB** | Error Log | `/opt/bitnami/mariadb/logs/mysqld.log` |
| **Docker** | Container Log | `docker logs container-name` |

### 📋 **Log Analiz Komutları**

```bash
# Son 100 satır error log
docker exec moodle-render_moodle_1 tail -n 100 /opt/bitnami/moodle/error.log

# Kritik hatalar filtrele
docker logs moodle-render_moodle_1 2>&1 | grep -i "error\|fatal\|critical"

# Belirli tarih aralığı
docker logs --since="2025-01-01T00:00:00" --until="2025-01-02T00:00:00" moodle-render_moodle_1

# Log boyutunu kontrol et
docker exec moodle-render_moodle_1 du -h /opt/bitnami/moodle/error.log
```

### 🔍 **Sık Görülen Log Hataları**

| Hata | Anlamı | Çözüm |
|------|--------|-------|
| `Fatal error: Maximum execution time` | Script timeout | PHP max_execution_time artır |
| `mysqli_connect(): Connection refused` | DB bağlantı sorunu | MariaDB konteyner kontrol et |
| `File not found` | Eksik dosya | File permissions kontrol et |
| `Out of memory` | Bellek yetersiz | Memory limit artır |

---

## 🚨 Acil Durum Kurtarma

### 💾 **Hızlı Backup**

```bash
# Tam sistem yedeği
./scripts/emergency-backup.sh

# Manuel backup
docker exec moodle-render_mariadb_1 mysqldump -u bn_moodle -pbitnami123 bitnami_moodle > emergency-backup.sql
docker cp moodle-render_moodle_1:/bitnami/moodledata ./moodledata-backup
```

### 🔄 **Sistem Restore**

```bash
# Konteynerları durdur
docker-compose down

# Volume'leri temizle
docker volume rm moodle-render_mariadb_data moodle-render_moodledata_data

# Yeniden başlat
docker-compose up -d

# Database restore
cat emergency-backup.sql | docker exec -i moodle-render_mariadb_1 mysql -u bn_moodle -pbitnami123 bitnami_moodle

# Moodle data restore
docker cp ./moodledata-backup/. moodle-render_moodle_1:/bitnami/moodledata/
```

### 🆘 **Son Çare Komutları**

```bash
# Tüm Docker verilerini temizle (DİKKAT!)
docker system prune -a --volumes

# Tüm konteynerleri sil
docker stop $(docker ps -aq) && docker rm $(docker ps -aq)

# Baştan kurulum
git pull origin main
docker-compose up -d --build --force-recreate
```

---

## 🛟 Destek Alma

### 📞 **İletişim Kanalları**

| Acil Seviye | Kanal | Yanıt Süresi |
|-------------|-------|--------------|
| **🚨 Kritik** | Phone: +90 533 924 3850 | < 2 saat |
| **⚠️ Yüksek** | Email: info@tuerfa.de | < 4 saat |
| **🔵 Normal** | GitHub Issues | < 1 gün |

### 📋 **Destek Talep Template**

```markdown
## 🚨 Sorun Açıklaması
[Sorunu detaylı açıklayın]

## 🔄 Reproduksiyon Adımları
1. [Adım 1]
2. [Adım 2]
3. [Hata oluşur]

## 💻 Sistem Bilgileri
- OS: [Ubuntu 20.04]
- Docker Version: [20.10.12]
- TurfaLearn Version: [2.1.0]

## 📊 Log Çıktıları
```bash
[Log çıktıları buraya]
```

## 🔍 Denenen Çözümler
[Şimdiye kadar denediğiniz çözümler]
```

---

## 🧰 Yararlı Scriptler

### 🔍 **System Health Check**

```bash
#!/bin/bash
# health-check.sh

echo "=== TurfaLearn Health Check ==="
echo "Date: $(date)"
echo ""

# Docker kontrolleri
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
docker exec moodle-render_mariadb_1 mysqladmin ping >/dev/null 2>&1 && echo "  - Database: ✅ OK" || echo "  - Database: ❌ FAIL"

echo ""
echo "=== Health Check Complete ==="
```

### 🧹 **Cleanup Script**

```bash
#!/bin/bash
# cleanup.sh

echo "🧹 TurfaLearn Cleanup Starting..."

# Log dosyası temizliği
echo "📄 Cleaning logs..."
docker exec moodle-render_moodle_1 find /opt/bitnami/apache/logs -name "*.log" -type f -mtime +7 -delete
docker exec moodle-render_moodle_1 truncate -s 0 /opt/bitnami/moodle/error.log

# Cache temizliği
echo "🗂️ Cleaning cache..."
docker exec moodle-render_moodle_1 php admin/cli/purge_caches.php

# Temporary files
echo "🗑️ Cleaning temp files..."
docker exec moodle-render_moodle_1 find /tmp -type f -mtime +3 -delete

# Docker cleanup
echo "🐳 Docker cleanup..."
docker system prune -f

echo "✅ Cleanup complete!"
```

---

<div align="center">

## 🎯 Hala Sorun Çözemediyseniz?

**Endişelenmeyin! Bizimle iletişime geçin:**

📧 **Email:** info@tuerfa.de  
📱 **Telefon:** +90 0533 924 3850  
🐛 **GitHub:** [Issues sayfası](https://github.com/umur957/moodle-render/issues)

---

*Bu rehber düzenli olarak güncellenmektedir. Yeni sorunlar keşfettiğinizde lütfen bize bildirin!*

**© 2025 Turfa GbR • Made with ❤️ for the community**

</div>