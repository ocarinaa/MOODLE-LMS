FROM mattrayner/lamp:latest-1804

WORKDIR /app

RUN apt-get update && \
    apt-get install -y wget unzip git

RUN cd /var/www/html && \
    wget https://download.moodle.org/download.php/direct/stable401/moodle-latest-401.zip && \
    unzip moodle-latest-401.zip && \
    rm moodle-latest-401.zip && \
    mkdir -p /var/www/moodledata && \
    chmod 777 /var/www/moodledata && \
    chown -R www-data:www-data /var/www/html/moodle /var/www/moodledata

COPY start.sh /start.sh
RUN chmod +x /start.sh

# Port 8080'de çalıştır (Koyeb tarafından desteklenir)
RUN sed -i 's/80/8080/g' /etc/apache2/ports.conf
RUN sed -i 's/80/8080/g' /etc/apache2/sites-available/000-default.conf

EXPOSE 8080

CMD ["/start.sh"]
