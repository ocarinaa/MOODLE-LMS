#!/bin/bash

# Docker Compose servisleri başlat
docker-compose up -d

# Servislerin hazır olmasını bekle
echo "⏳ Moodle başlatılıyor..."
sleep 30

# Status kontrolü
docker-compose ps

echo "✅ Moodle hazır!"
echo "🌐 Erişim adresi: http://localhost:8080"
echo "👤 Kullanıcı: admin"
echo "🔑 Şifre: Admin@12345"