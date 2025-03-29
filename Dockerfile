FROM bitnami/moodle:latest

# Moodle için gerekli çevre değişkenleri
ENV MOODLE_USERNAME=admin
ENV MOODLE_PASSWORD=Admin@12345
ENV MOODLE_EMAIL=admin@example.com
ENV MOODLE_SITE_NAME="Turfa Learn"
ENV MOODLE_DATABASE_TYPE=mariadb
ENV MOODLE_DATABASE_HOST=mariadb
ENV MOODLE_DATABASE_PORT_NUMBER=3306
ENV MOODLE_DATABASE_NAME=bitnami_moodle
ENV MOODLE_DATABASE_USER=bn_moodle
ENV MOODLE_DATABASE_PASSWORD=bitnami123
ENV ALLOW_EMPTY_PASSWORD=yes

# Port 8080'i açığa çıkar
EXPOSE 8080

# Bu imajın varsayılan entrypoint'i kullanılacak
