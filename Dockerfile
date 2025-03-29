FROM bitnami/moodle:latest

# Render.com için gerekli ayarlar
ENV PORT=8080
ENV MOODLE_USERNAME=admin
ENV MOODLE_PASSWORD=Admin@12345
ENV MOODLE_EMAIL=admin@example.com
ENV MOODLE_SITE_NAME="Turfa Learn"

# Bu imaj zaten entrypoint içeriyor, özel bir komut belirtmemize gerek yok
