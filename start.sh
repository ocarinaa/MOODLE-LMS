#!/bin/bash

echo "🚀 Starting Moodle LMS..."
echo "⏳ This may take 5-10 minutes on first run..."

# Start services
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for Moodle to initialize..."
sleep 30

# Status check
docker-compose ps

echo ""
echo "✅ Moodle LMS is starting up!"
echo "🌐 Access URL: http://localhost:8080"
echo "👤 Username: admin"
echo "🔑 Password: Admin@12345"
echo ""
echo "📝 Note: First initialization takes 5-10 minutes."
echo "   Wait for 'Apache started' in logs before accessing."
echo ""
echo "📊 Monitor startup progress:"
echo "   docker-compose logs -f moodle"