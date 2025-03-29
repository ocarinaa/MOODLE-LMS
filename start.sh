#!/bin/bash

# MySQL'i başlat
service mysql start

# Moodle veritabanı oluştur
mysql -u root -e "CREATE DATABASE IF NOT EXISTS moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -e "CREATE USER IF NOT EXISTS 'moodle'@'localhost' IDENTIFIED BY 'moodle123';"
mysql -u root -e "GRANT ALL ON moodle.* TO 'moodle'@'localhost';"

# Config.php dosyasını oluştur
cat > /var/www/html/moodle/config.php << EOF
<?php
\$CFG = new stdClass();
\$CFG->dbtype    = 'mysqli';
\$CFG->dblibrary = 'native';
\$CFG->dbhost    = 'localhost';
\$CFG->dbname    = 'moodle';
\$CFG->dbuser    = 'moodle';
\$CFG->dbpass    = 'moodle123';
\$CFG->prefix    = 'mdl_';
\$CFG->dboptions = array('dbpersist' => false, 'dbsocket' => false);
\$CFG->wwwroot   = 'https://'.\$_SERVER['HTTP_HOST'];
\$CFG->dataroot  = '/var/www/moodledata';
\$CFG->directorypermissions = 0777;
\$CFG->admin = 'admin';
require_once(__DIR__ . '/lib/setup.php');
EOF

# Apache'yi başlat
apache2-foreground
