FROM bitnami/moodle:latest

# Render.com için gerekli ayarlar
ENV PORT=8080
ENV MOODLE_DATABASE_TYPE=sqlite
ENV ALLOW_EMPTY_PASSWORD=yes
