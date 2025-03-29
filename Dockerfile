FROM bitnami/moodle:latest

# Render.com için çevre değişkenleri
ENV PORT=8080
ENV RENDER=true

# Moodle admin kullanıcı ayarları
ENV MOODLE_USERNAME=admin
ENV MOODLE_PASSWORD=Admin@12345
ENV MOODLE_EMAIL=admin@example.com
ENV MOODLE_SITE_NAME="Turfa Learn"

# Çalıştırma komutu
CMD ["bash", "-c", "/opt/bitnami/scripts/moodle/entrypoint.sh /opt/bitnami/scripts/apache/run.sh"]
