#!/bin/bash

#  Moodle LMS Quick Start Script
# Developed by UMUR KIZILDAS

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
print_step() {
    echo -e "\==>\ \"
}

print_success() {
    echo -e "\ \\"
}

print_warning() {
    echo -e "\  \\"
}

print_error() {
    echo -e "\ \\"
}

print_info() {
    echo -e "\ℹ  \\"
}

# Banner
echo -e "\"
echo ""
echo "                     MOODLE LMS STARTUP                     "
echo "                                                              "
echo "           Production-Ready E-Learning Platform               "
echo "                                                              "
echo "                  Developed by UMUR KIZILDAS                  "
echo ""
echo -e "\"
echo

# Prerequisites check
print_step "Checking prerequisites..."

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed!"
    echo "Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! docker info &> /dev/null; then
    print_error "Docker is not running!"
    echo "Please start Docker service and try again."
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null; then
    if ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not available!"
        echo "Please install Docker Compose: https://docs.docker.com/compose/install/"
        exit 1
    else
        DOCKER_COMPOSE="docker compose"
    fi
else
    DOCKER_COMPOSE="docker-compose"
fi

print_success "Docker and Docker Compose are available"

# Check for docker-compose.yml
if [ ! -f "docker-compose.yml" ]; then
    print_error "docker-compose.yml not found!"
    echo "Please run this script from the project root directory."
    exit 1
fi

print_success "Configuration files found"

# Check for existing containers
if \ ps | grep -q "Up"; then
    print_warning "Some containers are already running"
    read -p "Do you want to restart the services? (y/N): " -n 1 -r
    echo
    if [[ \ =~ ^[Yy]\$ ]]; then
        print_step "Stopping existing containers..."
        \ down
        print_success "Containers stopped"
    else
        print_info "Keeping existing containers running"
        echo
        print_info "Access your Moodle at: http://localhost:8080"
        exit 0
    fi
fi

# Check available ports
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1; then
    print_warning "Port 8080 is already in use"
    echo "Please stop the service using port 8080 or modify docker-compose.yml"
    exit 1
fi

if lsof -Pi :8443 -sTCP:LISTEN -t >/dev/null 2>&1; then
    print_warning "Port 8443 is already in use"
    echo "This may cause HTTPS access issues"
fi

print_success "Ports are available"

# Environment file check
if [ ! -f ".env" ]; then
    print_warning ".env file not found"
    if [ -f ".env.example" ]; then
        print_step "Creating .env from .env.example..."
        cp .env.example .env
        print_success ".env file created"
        print_info "You can customize .env file for your environment"
    else
        print_error ".env.example not found!"
        echo "Please create environment configuration files."
        exit 1
    fi
fi

# System resources check
available_memory=\
if [ "\" -lt 4096 ]; then
    print_warning "Available memory (\MB) is less than recommended 4GB"
    echo "Moodle may run slowly or fail to start properly."
fi

# Start services
print_step "Starting Moodle LMS services..."
echo

# Pull latest images
print_step "Pulling latest Docker images..."
\ pull

# Start containers
print_step "Starting containers..."
\ up -d

# Wait for services to start
print_step "Waiting for services to initialize..."
sleep 5

# Check container status
print_step "Checking container status..."
if \ ps | grep -q "Up"; then
    print_success "Containers are running"
else
    print_error "Some containers failed to start"
    echo
    echo "Container status:"
    \ ps
    echo
    echo "Logs:"
    \ logs --tail=20
    exit 1
fi

# Installation progress monitoring
echo
print_step "Monitoring Moodle installation progress..."
print_warning " IMPORTANT: First-time setup takes 5-10 minutes!"
echo
print_info "What's happening during initialization:"
echo "   MariaDB is setting up the database"
echo "   Moodle is installing core components"
echo "   System is configuring initial settings"
echo "   Web server is starting up"
echo

# Wait for MariaDB
print_step "Waiting for MariaDB to be ready..."
timeout=300
counter=0
while ! \ exec -T mariadb mysqladmin ping -h localhost --silent 2>/dev/null; do
    if [ \ -ge \ ]; then
        print_error "MariaDB failed to start within 5 minutes"
        \ logs mariadb --tail=20
        exit 1
    fi
    sleep 5
    counter=\
    echo -n "."
done
echo
print_success "MariaDB is ready"

# Wait for Moodle
print_step "Waiting for Moodle to be ready..."
print_info "This may take several minutes for the first run..."
timeout=600
counter=0
while ! curl -f http://localhost:8080 >/dev/null 2>&1; do
    if [ \ -ge \ ]; then
        print_error "Moodle failed to start within 10 minutes"
        echo
        echo "Moodle logs:"
        \ logs moodle --tail=30
        echo
        echo "MariaDB logs:"
        \ logs mariadb --tail=10
        exit 1
    fi
    sleep 10
    counter=\
    printf "."
done
echo
print_success "Moodle is ready!"

# Success message
echo
echo -e "\"
echo ""
echo "                     SUCCESS!                             "
echo "                                                              "
echo "              Moodle LMS is now running!                      "
echo ""
echo -e "\"
echo

print_info " Access URLs:"
echo "   HTTP:  http://localhost:8080"
echo "   HTTPS: https://localhost:8443 (self-signed certificate)"
echo

print_info " Next Steps:"
echo "   1. Open http://localhost:8080 in your browser"
echo "   2. Complete the Moodle installation wizard"
echo "   3. Create your administrator account"
echo "   4. Start building your courses!"
echo

print_info "  Management Commands:"
echo "   View logs:     \ logs -f moodle"
echo "   Stop services: \ stop"
echo "   Start services:\ start"
echo "   Full restart:  \ restart"
echo

print_info " Need Help?"
echo "   Documentation: README.md"
echo "   Issues: https://github.com/umur957/moodle-lms/issues"
echo

print_warning " Security Note:"
echo "   This setup uses default passwords for development."
echo "   For production use, please configure secure passwords in .env file!"
echo

print_success "Happy Learning! "
