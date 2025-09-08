#  Moodle LMS - Complete E-Learning Platform

<div align="center">
  
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Moodle](https://img.shields.io/badge/Moodle-FF6600?style=for-the-badge&logo=moodle&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

###  Production-Ready Moodle LMS Deployment
**Secure  Scalable  Easy to Deploy**

</div>

---

##  Table of Contents

- [ Features](#-features)
- [ Prerequisites](#-prerequisites)
- [ Quick Start](#-quick-start)
- [ Configuration](#-configuration)
- [ Accessing Moodle](#-accessing-moodle)
- [ Container Management](#-container-management)
- [ Security Notes](#-security-notes)
- [ Production Deployment](#-production-deployment)
- [ Troubleshooting](#-troubleshooting)
- [ Contributing](#-contributing)
- [ License](#-license)

---

##  Features

 **Complete Moodle LMS** - Latest Bitnami Moodle with all features  
 **MariaDB Database** - Optimized with UTF8MB4 character set  
 **Docker Compose** - One-command deployment  
 **Persistent Storage** - Data preserved across restarts  
 **SSL Support** - HTTPS ready with certificates  
 **Multi-language** - Full international character support  
 **Production Ready** - Scalable and secure configuration  

---

##  Prerequisites

Before getting started, ensure you have:

- **Docker** (v20.10+) - [Install Docker](https://docs.docker.com/get-docker/)
- **Docker Compose** (v2.0+) - [Install Compose](https://docs.docker.com/compose/install/)
- **8GB RAM** minimum (16GB recommended for production)
- **10GB free disk space** minimum

### System Requirements
- **Ports 8080 and 8443** must be available
- **Internet connection** for initial image download

---

##  Quick Start

### 1. Clone the Repository
`ash
git clone https://github.com/umur957/moodle-lms.git
cd moodle-lms
`

### 2. Start the Platform
`ash
# Start all services
docker-compose up -d
`

### 3. Wait for Initialization
 **First startup takes 5-10 minutes** - Moodle needs time to:
- Initialize the database
- Install core components
- Configure the system

### 4. Access Your Moodle
 Open your browser and go to: **http://localhost:8080**

---

##  Configuration

### Environment Variables

Copy and customize the environment file:
`ash
cp .env.example .env
`

Key settings in .env:
`env
# Database Configuration
MARIADB_USER=bn_moodle
MARIADB_DATABASE=bitnami_moodle
ALLOW_EMPTY_PASSWORD=yes  #  DEVELOPMENT ONLY

# Moodle Configuration  
MOODLE_DATABASE_USER=bn_moodle
MOODLE_DATABASE_NAME=bitnami_moodle
`

### Custom Domain Setup
For production use, update docker-compose.yml:
`yaml
environment:
  - MOODLE_HOST=your-domain.com
  - MOODLE_REVERSEPROXY=yes
`

---

##  Accessing Moodle

### Development URLs
- **HTTP:** http://localhost:8080
- **HTTPS:** https://localhost:8443 (self-signed certificate)

### First Time Setup
1. Open http://localhost:8080
2. Follow the Moodle installation wizard
3. Create your admin account
4. Configure your site settings

### Default Credentials
The system will prompt you to create admin credentials on first access.

---

##  Container Management

### Check Status
`ash
# View running containers
docker-compose ps

# View logs
docker-compose logs -f moodle
docker-compose logs -f mariadb
`

### Stop/Start Services
`ash
# Stop all services
docker-compose stop

# Start services
docker-compose start

# Restart services
docker-compose restart
`

### Clean Installation
`ash
# Remove everything ( DATA LOSS)
docker-compose down -v
docker-compose up -d
`

---

##  Security Notes

###  Development vs Production

**Development (Current Setup):**
- Empty passwords allowed
- Default ports exposed
- Self-signed certificates

**Production Requirements:**
1. **Set strong passwords:**
   `env
   ALLOW_EMPTY_PASSWORD=no
   MARIADB_PASSWORD=your-secure-password
   MOODLE_DATABASE_PASSWORD=your-secure-password
   `

2. **Use reverse proxy (Nginx/Apache)**
3. **Configure SSL certificates**
4. **Restrict database access**
5. **Regular backups**

---

##  Production Deployment

### 1. Security Configuration
`ash
# Edit environment variables
nano .env

# Set production passwords
ALLOW_EMPTY_PASSWORD=no
MARIADB_PASSWORD=SuperSecurePassword123!
MOODLE_DATABASE_PASSWORD=SuperSecurePassword123!
`

### 2. Reverse Proxy Setup
Example Nginx configuration:
`
ginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \System.Management.Automation.Internal.Host.InternalHost;
        proxy_set_header X-Real-IP \;
    }
}
`

### 3. SSL Certificate
`ash
# Using Let's Encrypt
certbot --nginx -d your-domain.com
`

---

##  Troubleshooting

### Common Issues

####  Containers not starting
`ash
# Check logs
docker-compose logs

# Restart with fresh data
docker-compose down -v
docker-compose up -d
`

####  Cannot access Moodle
1. Wait 5-10 minutes for initialization
2. Check if ports are available: 
etstat -an | findstr :8080
3. Verify containers are running: docker-compose ps

####  Database connection issues
`ash
# Reset database
docker-compose stop mariadb
docker volume rm moodle-lms_mariadb_data
docker-compose up -d mariadb
`

####  Performance issues
- Increase Docker memory allocation (8GB+)
- Use SSD storage for volumes
- Monitor with: docker stats

---

##  Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup
`ash
git clone https://github.com/umur957/moodle-lms.git
cd moodle-lms
docker-compose up -d
`

---

##  License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

###  Developed by UMUR KIZILDAS

**Made with  for the Education Community**

[ Star this repo](https://github.com/umur957/moodle-lms)  [ Report Bug](https://github.com/umur957/moodle-lms/issues)  [ Request Feature](https://github.com/umur957/moodle-lms/issues)

</div>
