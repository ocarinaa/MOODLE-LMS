#!/bin/bash
# MariaDB servisini başlat
service mariadb start

# Moodle başlat
/opt/bitnami/scripts/moodle/entrypoint.sh /opt/bitnami/scripts/apache/run.sh
