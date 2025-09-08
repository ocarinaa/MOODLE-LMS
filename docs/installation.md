# 🚀 TurfaLearn Kurulum Rehberi

Bu rehber, TurfaLearn Moodle LMS sisteminin detaylı kurulum sürecini açıklamaktadır.

## 📋 İçindekiler

1. [Sistem Gereksinimleri](#sistem-gereksinimleri)
2. [Sunucu Hazırlığı](#sunucu-hazırlığı)
3. [Docker Kurulumu](#docker-kurulumu)
4. [TurfaLearn Kurulumu](#turfalearn-kurulumu)
5. [İlk Yapılandırma](#ilk-yapılandırma)
6. [SSL Sertifikası](#ssl-sertifikası)
7. [Production Optimizasyonu](#production-optimizasyonu)
8. [Sorun Giderme](#sorun-giderme)

---

## 💻 Sistem Gereksinimleri

### Minimum Gereksinimler

| Bileşen | Minimum | Önerilen | Enterprise |
|---------|---------|----------|------------|
| **CPU** | 2 vCPU | 4 vCPU | 8+ vCPU |
| **RAM** | 4GB | 8GB | 16GB+ |
| **Disk** | 20GB SSD | 50GB SSD | 100GB+ NVMe |
| **Ağ** | 100Mbps | 1Gbps | 10Gbps |
| **Eşzamanlı Kullanıcı** | 50 | 500 | 5000+ |

### Desteklenen İşletim Sistemleri

#### ✅ Tam Destek
- **Ubuntu** 24.04 LTS (Önerilen)
- **Ubuntu** 22.04 LTS  
- **Ubuntu** 20.04 LTS
- **Debian** 12 (Bookworm)
- **Debian** 11 (Bullseye)

#### ⚠️ Kısmi Destek
- **CentOS** 8 Stream
- **RHEL** 8+
- **Rocky Linux** 8+
- **Amazon Linux** 2

#### ❌ Desteklenmeyen
- Ubuntu < 20.04
- CentOS < 8
- Windows Server (WSL2 ile test aşamasında)

### Ağ Gereksinimleri

#### Açılması Gereken Portlar:
```bash
# HTTP/HTTPS
80/tcp    # HTTP
443/tcp   # HTTPS

# SSH (Yönetim için)
22/tcp    # SSH

# Database (İç ağ)
3306/tcp  # MariaDB (sadece container network)

# BigBlueButton (Opsiyonel)
80/tcp, 443/tcp, 1935/tcp, 7443/tcp
```

---

## 🔧 Sunucu Hazırlığı

### 1. Sistem Güncellemesi

```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade -y

# CentOS/RHEL
sudo yum update -y
# veya (yeni sürümler)
sudo dnf update -y
```

### 2. Gerekli Paketlerin Kurulumu

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

### 3. Zaman Dilimi Ayarlama

```bash
# Mevcut zaman dilimini kontrol et
timedatectl

# Türkiye zaman dilimi
sudo timedatectl set-timezone Europe/Istanbul

# Almanya zaman dilimi (alternatif)
sudo timedatectl set-timezone Europe/Berlin

# Zaman senkronizasyonu
sudo timedatectl set-ntp true
```

### 4. Firewall Yapılandırması

#### Ubuntu UFW:
```bash
# UFW'yi etkinleştir
sudo ufw enable

# Temel kurallar
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS

# Durum kontrolü
sudo ufw status verbose
```

#### CentOS/RHEL Firewalld:
```bash
# Firewalld'yi başlat
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Portları aç
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https

# Kuralları yükle
sudo firewall-cmd --reload

# Durum kontrolü
sudo firewall-cmd --list-all
```

### 5. Swap Alanı Oluşturma

```bash
# 4GB swap alanı oluştur
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Kalıcı hale getir
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Swap kullanımını kontrol et
free -h
```

---

## 🐳 Docker Kurulumu

### Ubuntu/Debian için Docker Kurulumu

```bash
# Docker'ın eski sürümlerini kaldır
sudo apt remove -y docker docker-engine docker.io containerd runc

# Docker GPG key ekle
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Docker repository ekle
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Repository güncelle ve Docker kur
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Docker servisini başlat
sudo systemctl start docker
sudo systemctl enable docker

# Kullanıcıyı docker grubuna ekle
sudo usermod -aG docker $USER

# Oturumu yenile (veya logout/login)
newgrp docker
```

### CentOS/RHEL için Docker Kurulumu

```bash
# Eski sürümleri kaldır
sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

# Docker repository ekle
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Docker kur
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Docker servisini başlat
sudo systemctl start docker
sudo systemctl enable docker

# Kullanıcıyı docker grubuna ekle
sudo usermod -aG docker $USER
newgrp docker
```

### Docker Compose Kurulumu (Eski Sistemler İçin)

```bash
# En son sürümü kontrol et: https://github.com/docker/compose/releases
DOCKER_COMPOSE_VERSION="v2.24.0"

# Docker Compose indir
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Çalıştırılabilir yap
sudo chmod +x /usr/local/bin/docker-compose

# Versiyon kontrol
docker-compose --version
```

### Docker Kurulum Doğrulaması

```bash
# Docker servis durumu
sudo systemctl status docker

# Docker sürüm bilgisi
docker --version
docker compose version

# Test container çalıştır
docker run hello-world

# Docker sistem bilgisi
docker system info
```

---

## 📦 TurfaLearn Kurulumu

### 1. Repository Klonlama

```bash
# Ana dizine git
cd /opt

# Repository'yi klon et
sudo git clone https://github.com/umur957/moodle-render.git turfalearn

# Dizin sahipliğini değiştir
sudo chown -R $USER:$USER /opt/turfalearn

# Çalışma dizinine git
cd /opt/turfalearn
```

### 2. Konfigürasyon Dosyalarını İnceleme

```bash
# Docker Compose dosyasını incele
cat docker-compose.yml

# Gitpod yapılandırmasını incele
cat gitpod.yaml

# Başlatma scriptini incele
cat start.sh
```

### 3. Environment Dosyası Oluşturma (Opsiyonel)

```bash
# .env dosyası oluştur
cat > .env << EOF
# Moodle Configuration
MOODLE_SITE_NAME=TurfaLearn
MOODLE_USERNAME=admin
MOODLE_PASSWORD=Secure_Password_2025!
MOODLE_EMAIL=admin@tuerfa.de

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

# .env dosyasını güvenli hale getir
chmod 600 .env
```

### 4. Docker Compose ile Başlatma

```bash
# Servisleri arka planda başlat
docker compose up -d

# Başlatma durumunu kontrol et
docker compose ps

# Logları takip et
docker compose logs -f
```

### 5. Kurulum İlerlemesini Takip Etme

```bash
# Moodle container loglarını izle
docker compose logs -f moodle

# MariaDB container loglarını izle
docker compose logs -f mariadb

# Tüm servislerin durumunu kontrol et
docker compose ps

# Container'ların kaynak kullanımını izle
docker stats
```

---

## ⚙️ İlk Yapılandırma

### 1. Web Arayüzüne Erişim

Kurulum tamamlandıktan sonra (yaklaşık 3-5 dakika):

```bash
# Local erişim
http://localhost:8080

# Uzak sunucu erişimi
http://YOUR_SERVER_IP:8080

# HTTPS (SSL yapılandırılmışsa)
https://YOUR_DOMAIN:8443
```

### 2. İlk Giriş Bilgileri

| Alan | Değer |
|------|--------|
| **URL** | `http://your-server:8080` |
| **Kullanıcı Adı** | `admin` |
| **Şifre** | `Admin@12345` (değiştirin!) |
| **Email** | `admin@example.com` |

### 3. Yönetici Hesabı Güvenlik Ayarları

```bash
# Container'a gir
docker exec -it moodle-render-moodle-1 bash

# Moodle CLI'ye git
cd /opt/bitnami/moodle

# Admin şifresini değiştir
php admin/cli/reset_password.php --username=admin

# Yeni kullanıcı oluştur
php admin/cli/create_user.php --username=yeni_admin --password=GuvenlıSıfre123! --email=admin@tuerfa.de --firstname=Admin --lastname=User

# Container'dan çık
exit
```

### 4. Temel Site Yapılandırması

#### Site Ayarları:
1. **Site Administration** > **Server** > **System information**
2. **Site Administration** > **Appearance** > **Themes**
3. **Site Administration** > **Language** > **Language packs**

#### Güvenlik Ayarları:
1. **Site Administration** > **Security** > **Site security settings**
2. **Site Administration** > **Users** > **Permissions** > **User policies**

---

## 🔒 SSL Sertifikası Kurulumu

### Let's Encrypt ile Otomatik SSL

#### 1. Certbot Kurulumu

```bash
# Ubuntu/Debian
sudo apt install -y certbot python3-certbot-nginx

# CentOS/RHEL
sudo yum install -y certbot python3-certbot-nginx
```

#### 2. Nginx Reverse Proxy Yapılandırması

```bash
# Nginx kur
sudo apt install -y nginx

# Nginx config dosyası oluştur
sudo tee /etc/nginx/sites-available/turfalearn << EOF
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

# Site'ı aktif et
sudo ln -s /etc/nginx/sites-available/turfalearn /etc/nginx/sites-enabled/

# Nginx'i test et ve başlat
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx
```

#### 3. SSL Sertifikası Alma

```bash
# SSL sertifikası al
sudo certbot --nginx -d your-domain.com -d www.your-domain.com --email admin@tuerfa.de --agree-tos --no-eff-email

# Otomatik yenileme test et
sudo certbot renew --dry-run

# Otomatik yenileme için crontab ekle
echo "0 3 * * 1 certbot renew --quiet" | sudo crontab -
```

### Manuel SSL Sertifikası

```bash
# SSL dizinini oluştur
sudo mkdir -p /opt/turfalearn/ssl

# Kendi imzalı sertifika oluştur (sadece test için)
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /opt/turfalearn/ssl/turfalearn.key \
    -out /opt/turfalearn/ssl/turfalearn.crt \
    -subj "/C=DE/ST=NRW/L=Düsseldorf/O=Turfa GbR/CN=turfalearn.local"

# Docker Compose'a SSL ekle
# docker-compose.yml dosyasına volume ekle:
# volumes:
#   - ./ssl/turfalearn.crt:/opt/bitnami/apache/conf/ssl/server.crt:ro
#   - ./ssl/turfalearn.key:/opt/bitnami/apache/conf/ssl/server.key:ro
```

---

## ⚡ Production Optimizasyonu

### 1. Performance Tuning

```bash
# docker-compose.yml'ye ekleyeceğiniz environment variables
cat >> docker-compose.yml << EOF
    environment:
      # ... mevcut environment variables ...
      
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

### 2. Redis Cache Ekleme

```yaml
# docker-compose.yml'ye Redis servisi ekle
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
      - turfalearn_network

volumes:
  redis_data:
    driver: local
```

### 3. Monitoring Ekleme

```yaml
# Prometheus ve Grafana için monitoring stack
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro
    ports:
      - "9090:9090"
    networks:
      - turfalearn_network
      
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
      - turfalearn_network
```

### 4. Backup Sistemi

```bash
# Backup scripti oluştur
sudo tee /opt/turfalearn/scripts/backup.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/opt/backups/turfalearn"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RETENTION_DAYS=30

# Backup dizinini oluştur
mkdir -p $BACKUP_DIR

echo "🔄 TurfaLearn backup başlıyor..."

# Database backup
echo "📊 Veritabanı yedeği alınıyor..."
docker exec moodle-render-mariadb-1 mysqldump \
    -u bn_moodle -pbitnami123 bitnami_moodle \
    > $BACKUP_DIR/database_$TIMESTAMP.sql

# Moodledata backup
echo "📁 Moodle veri yedeği alınıyor..."
docker run --rm \
    -v moodle-render_moodledata_data:/data:ro \
    -v $BACKUP_DIR:/backup \
    alpine tar czf /backup/moodledata_$TIMESTAMP.tar.gz -C /data .

# Configuration backup
echo "⚙️ Konfigürasyon yedeği alınıyor..."
cp -r /opt/turfalearn $BACKUP_DIR/config_$TIMESTAMP

# Eski backupları sil (30 gün)
find $BACKUP_DIR -type f -mtime +$RETENTION_DAYS -delete

echo "✅ Backup tamamlandı: $BACKUP_DIR"
EOF

# Script'i çalıştırılabilir yap
chmod +x /opt/turfalearn/scripts/backup.sh

# Crontab'a günlük backup ekle
echo "0 2 * * * /opt/turfalearn/scripts/backup.sh >> /var/log/turfalearn-backup.log 2>&1" | crontab -
```

---

## 🐛 Sorun Giderme

### Yaygın Sorunlar ve Çözümleri

#### 1. Container Başlatma Sorunları

```bash
# Container durumunu kontrol et
docker compose ps

# Container loglarını incele
docker compose logs moodle
docker compose logs mariadb

# Container'ları yeniden başlat
docker compose restart

# Container'ları tamamen yeniden oluştur
docker compose down
docker compose up -d --force-recreate
```

#### 2. Port Çakışması Sorunları

```bash
# Port kullanımını kontrol et
sudo netstat -tulpn | grep :8080
sudo ss -tulpn | grep :8080

# Çakışan proceesi durdur
sudo fuser -k 8080/tcp

# Alternatif port kullan (docker-compose.yml'de değiştir)
ports:
  - "8081:8080"  # 8081 portunu kullan
```

#### 3. Veritabanı Bağlantı Sorunları

```bash
# MariaDB container'a bağlan
docker exec -it moodle-render-mariadb-1 mysql -u bn_moodle -pbitnami123

# Veritabanı durumunu kontrol et
SHOW DATABASES;
USE bitnami_moodle;
SHOW TABLES;

# Container'dan çık
exit
```

#### 4. Bellek/Performans Sorunları

```bash
# Container kaynak kullanımını kontrol et
docker stats

# Sistem kaynaklarını kontrol et
free -h
df -h
htop

# Moodle cache temizle
docker exec moodle-render-moodle-1 php /opt/bitnami/moodle/admin/cli/purge_caches.php
```

#### 5. SSL/HTTPS Sorunları

```bash
# Nginx durumunu kontrol et
sudo systemctl status nginx

# Nginx configuration test et
sudo nginx -t

# SSL sertifika durumunu kontrol et
sudo certbot certificates

# SSL sertifika yenile
sudo certbot renew --force-renewal
```

### Log Analizi

```bash
# Tüm container loglarını izle
docker compose logs -f --tail=100

# Belirli bir servisin loglarını izle
docker compose logs -f moodle

# Sistem loglarını kontrol et
sudo journalctl -u docker
sudo tail -f /var/log/syslog

# Nginx access logları
sudo tail -f /var/log/nginx/access.log

# Nginx error logları  
sudo tail -f /var/log/nginx/error.log
```

### Diagnostic Script

```bash
# Tanı scripti oluştur
cat > diagnostic.sh << 'EOF'
#!/bin/bash

echo "🔍 TurfaLearn Sistem Tanılaması"
echo "================================"

echo "📊 Sistem Bilgileri:"
echo "OS: $(lsb_release -d | cut -f2)"
echo "Çekirdek: $(uname -r)"
echo "Çalışma süresi: $(uptime -p)"

echo -e "\n🐳 Docker Bilgileri:"
echo "Docker Version: $(docker --version)"
echo "Docker Compose Version: $(docker compose version --short)"

echo -e "\n📦 Container Durumu:"
docker compose ps

echo -e "\n💾 Disk Kullanımı:"
df -h | grep -E "(Filesystem|/dev/)"

echo -e "\n🧠 Bellek Kullanımı:"
free -h

echo -e "\n🌐 Ağ Durumu:"
ss -tulpn | grep -E ":80|:443|:8080|:8443|:3306"

echo -e "\n🔗 Moodle Erişim Testi:"
curl -f -s -I http://localhost:8080/login/index.php && echo "✅ Moodle erişilebilir" || echo "❌ Moodle erişilemez"

echo -e "\n📋 Son 10 Moodle Log:"
docker compose logs moodle --tail=10

EOF

chmod +x diagnostic.sh
./diagnostic.sh
```

---

## 📞 Destek

Bu kurulum rehberi ile ilgili sorun yaşıyor musunuz?

- 🐛 **Bug Report**: [GitHub Issues](https://github.com/umur957/moodle-render/issues)
- 📧 **Email Destek**: info@tuerfa.de
- 📱 **Acil Destek**: +90 0533 924 3850
- 📚 **Dokümantasyon**: [docs/](../README.md)

---

*Bu kurulum rehberi sürekli güncellenmektedir. Önerilerinizi [GitHub Issues](https://github.com/umur957/moodle-render/issues) üzerinden paylaşabilirsiniz.*

*© 2025 Turfa GbR. Tüm hakları saklıdır.*