FROM bitnami/moodle:latest

# Render.com için gerekli ayarlamalar
ENV PORT=8080
ENV RENDER=true

# Veritabanı ayarlarını environment değişkenlerinden al
ENV MOODLE_DATABASE_TYPE=pgsql
ENV MOODLE_DATABASE_HOST=$DATABASE_HOST
ENV MOODLE_DATABASE_PORT_NUMBER=5432
ENV MOODLE_DATABASE_USER=$DATABASE_USER
ENV MOODLE_DATABASE_PASSWORD=$DATABASE_PASSWORD
ENV MOODLE_DATABASE_NAME=$DATABASE_NAME

# Moodle admin bilgileri
ENV MOODLE_USERNAME=admin
ENV MOODLE_PASSWORD=password
ENV MOODLE_EMAIL=admin@example.com
ENV MOODLE_SITE_NAME="My Moodle Site"

# Çalıştırma komutu
CMD ["/opt/bitnami/scripts/moodle/entrypoint.sh", "/opt/bitnami/scripts/apache/run.sh"]
