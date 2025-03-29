FROM bitnami/moodle:latest

# Render.com için gerekli ayarlamalar
ENV PORT=8080
ENV RENDER=true

# Varsayılan çalıştırma komutu
CMD ["./opt/bitnami/scripts/moodle/entrypoint.sh"]
