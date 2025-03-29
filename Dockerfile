FROM bitnami/moodle:latest

# Gerekli çevre değişkenleri
ENV ALLOW_EMPTY_PASSWORD=yes
ENV MOODLE_DATABASE_TYPE=sqlite
ENV MOODLE_USERNAME=admin
ENV MOODLE_PASSWORD=Admin@12345
ENV MOODLE_EMAIL=admin@example.com
ENV MOODLE_SITE_NAME="Turfa Learn"
ENV PORT=8080

# SQLite DB için gerekli dizini oluştur
RUN mkdir -p /bitnami/moodle-data

# SQLite kullanımı için gereken ayarlar
RUN apt-get update && apt-get install -y sqlite3

# Gerekli izinleri ayarla
RUN chmod -R 777 /bitnami/moodle-data

# Varsayılan container portu
EXPOSE 8080

# SQLite veritabanı dosyasını oluştur
RUN touch /bitnami/moodle-data/moodle.db && chmod 777 /bitnami/moodle-data/moodle.db
