#!/bin/bash

# Start Docker Compose services
docker-compose up -d

# Wait for services to be ready
echo "⏳ Starting Moodle..."
sleep 30

# Status check
docker-compose ps

echo "✅ Moodle is ready!"
echo "🌐 Access URL: http://localhost:8080"
echo "👤 Username: admin"
echo "🔑 Password: Admin@12345"