FROM bitnami/moodle:latest

# Render.com için gerekli ayarlamalar
ENV PORT=8080
ENV RENDER=true

# PostgreSQL için PHP eklentilerini ekleyin
RUN apt-get update && apt-get install -y postgresql-client php-pgsql

# Moodle'ı PostgreSQL ile çalışacak şekilde ayarlayın
COPY config.php /bitnami/moodle/config.php

# Render tarafından belirtilen portta çalışacak şekilde ayarlayın
CMD ["sh", "-c", "apache2-foreground"]
