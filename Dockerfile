FROM bitnami/moodle:latest

# Gerekli paketleri yükle
RUN apt-get update && apt-get install -y mariadb-server

# MariaDB servisini başlat ve Moodle veritabanını oluştur
RUN service mariadb start && \
    mysql -e "CREATE DATABASE moodle_db;" && \
    mysql -e "CREATE USER 'moodle_user'@'localhost' IDENTIFIED BY 'moodle_password';" && \
    mysql -e "GRANT ALL PRIVILEGES ON moodle_db.* TO 'moodle_user'@'localhost';" && \
    mysql -e "FLUSH PRIVILEGES;"

# Moodle çevre değişkenlerini ayarla
ENV MOODLE_DATABASE_TYPE=mariadb
ENV MOODLE_DATABASE_HOST=127.0.0.1
ENV MOODLE_DATABASE_PORT_NUMBER=3306
ENV MOODLE_DATABASE_NAME=moodle_db
ENV MOODLE_DATABASE_USER=moodle_user
ENV MOODLE_DATABASE_PASSWORD=moodle_password
ENV MOODLE_USERNAME=admin
ENV MOODLE_PASSWORD=Admin@12345
ENV MOODLE_EMAIL=admin@example.com
ENV MOODLE_SITE_NAME="Turfa Learn"

# Başlangıç betiği
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Çalıştırma komutu
CMD ["/start.sh"]
