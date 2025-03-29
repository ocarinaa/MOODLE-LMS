FROM mattrayner/lamp:latest-1804

# Moodle'ı indir ve kur
RUN apt-get update && apt-get install -y wget unzip
WORKDIR /var/www/html
RUN wget https://download.moodle.org/download.php/direct/stable401/moodle-latest-401.zip && \
    unzip moodle-latest-401.zip && \
    rm moodle-latest-401.zip && \
    chown -R www-data:www-data /var/www/html/moodle && \
    chmod -R 755 /var/www/html/moodle

# Moodle veri dizini oluştur
RUN mkdir -p /var/www/moodledata && \
    chown -R www-data:www-data /var/www/moodledata && \
    chmod 777 /var/www/moodledata

# Veritabanı oluştur
RUN service mysql start && \
    mysql -u root -e "CREATE DATABASE moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" && \
    mysql -u root -e "CREATE USER 'moodle'@'localhost' IDENTIFIED BY 'moodle_password';" && \
    mysql -u root -e "GRANT ALL ON moodle.* TO 'moodle'@'localhost';" && \
    mysql -u root -e "FLUSH PRIVILEGES;"

# config.php oluştur
RUN echo "<?php \n\
\$CFG = new stdClass(); \n\
\$CFG->dbtype    = 'mysqli'; \n\
\$CFG->dblibrary = 'native'; \n\
\$CFG->dbhost    = 'localhost'; \n\
\$CFG->dbname    = 'moodle'; \n\
\$CFG->dbuser    = 'moodle'; \n\
\$CFG->dbpass    = 'moodle_password'; \n\
\$CFG->prefix    = 'mdl_'; \n\
\$CFG->dboptions = array( \n\
    'dbpersist' => false, \n\
    'dbsocket'  => false, \n\
); \n\
\$CFG->wwwroot   = 'https://\$_SERVER[\"HTTP_HOST\"]'; \n\
\$CFG->dataroot  = '/var/www/moodledata'; \n\
\$CFG->directorypermissions = 0777; \n\
\$CFG->admin = 'admin'; \n\
require_once(__DIR__ . '/lib/setup.php'); \n\
" > /var/www/html/moodle/config.php

# Başlangıç betiği
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Port yapılandırması
EXPOSE 80

# Çalıştırma komutu
CMD ["/start.sh"]
