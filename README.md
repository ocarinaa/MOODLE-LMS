# 🎓 Moodle LMS Docker Deployment

Dockerize edilmiş Moodle LMS kurulumu. MariaDB veritabanı ile hazır, hızlı ve güvenilir bir e-learning platformu.

## 🚀 Özellikler

- ✅ Tek komutla kurulum
- ✅ MariaDB veritabanı entegrasyonu
- ✅ Bitnami optimizasyonlu image
- ✅ Persistent veri depolama
- ✅ SSL/HTTPS desteği (8443 portu)
- ✅ Gitpod desteği

## 📋 Gereksinimler

- Docker Engine (20.10+)
- Docker Compose (v2.0+)
- Min 2GB RAM
- 10GB boş disk alanı

## ⚡ Hızlı Kurulum

### Docker Compose ile Kurulum (Önerilen)

1. **Repoyu klonlayın:**
```bash
git clone https://github.com/umur957/moodle-render.git
cd moodle-render
```

2. **Servisleri başlatın:**
```bash
docker-compose up -d
```

3. **Kurulum tamamlandığında:**
- **URL:** http://localhost:8080
- **Admin Kullanıcı:** admin
- **Admin Şifre:** Admin@12345
- **Admin Email:** admin@example.com

### Gitpod ile Kurulum

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/umur957/moodle-render)

## 🔧 Konfigürasyon

### Ortam Değişkenleri

| Değişken | Varsayılan | Açıklama |
|----------|------------|----------|
| MOODLE_USERNAME | admin | Admin kullanıcı adı |
| MOODLE_PASSWORD | Admin@12345 | Admin şifresi |
| MOODLE_EMAIL | admin@example.com | Admin e-posta |
| MOODLE_SITE_NAME | Turfa Learn | Site adı |
| MOODLE_DATABASE_NAME | bitnami_moodle | Veritabanı adı |

### Portlar

- **8080:** HTTP erişimi
- **8443:** HTTPS erişimi

## 📂 Proje Yapısı

```
moodle-render/
├── docker-compose.yml  # Docker orchestration
├── gitpod.yaml        # Gitpod konfigürasyonu
├── start.sh           # Gitpod başlatma scripti
└── README.md          # Dokümantasyon
```

## 🛠️ Yönetim Komutları

```bash
# Servisleri durdur
docker-compose down

# Logları görüntüle
docker-compose logs -f moodle

# Veritabanına bağlan
docker exec -it moodle-render_mariadb_1 mysql -u bn_moodle -pbitnami123

# Moodle container'ına gir
docker exec -it moodle-render_moodle_1 bash

# Temizlik (veriler dahil)
docker-compose down -v
```

## 🔒 Güvenlik Notları

⚠️ **Production kullanımı için:**

- Tüm şifreleri değiştirin
- SSL sertifikası ekleyin
- Firewall kurallarını yapılandırın
- Regular backup alın

## 🤝 Katkıda Bulunma

Pull request'ler kabul edilir. Büyük değişiklikler için önce issue açınız.

## 📄 Lisans

MIT

## 🆘 Destek

Sorunlar için [Issues](https://github.com/umur957/moodle-render/issues) sayfasını kullanın.

**Geliştirici:** [@umur957](https://github.com/umur957)