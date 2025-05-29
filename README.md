# 🚀 Inception

[![42](https://img.shields.io/badge/42-Tokyo-000000?style=flat-square&logo=42&logoColor=white)](https://42tokyo.jp/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white)](https://www.docker.com/)
[![NGINX](https://img.shields.io/badge/NGINX-009639?style=flat-square&logo=nginx&logoColor=white)](https://nginx.org/)
[![WordPress](https://img.shields.io/badge/WordPress-21759B?style=flat-square&logo=wordpress&logoColor=white)](https://wordpress.org/)
[![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=flat-square&logo=mariadb&logoColor=white)](https://mariadb.org/)

> 🎯 **System Administration Project**: Build a complete web infrastructure using Docker containers with custom services.

## 📋 Table of Contents

- [🎯 Project Overview](#-project-overview)
- [🏗️ Architecture](#️-architecture)
- [📦 Services](#-services)
- [⚙️ Installation](#️-installation)
- [🚀 Usage](#-usage)
- [📁 Project Structure](#-project-structure)
- [🔧 Configuration](#-configuration)
- [🐛 Troubleshooting](#-troubleshooting)
- [📚 Resources](#-resources)

## 🎯 Project Overview

**Inception** is a system administration project where you set up a complete web infrastructure using **Docker**. The goal is to create a multi-service environment with:

- 🔒 **TLS encryption** for secure connections
- 🐳 **Custom Docker containers** (no pre-built images)
- 🌐 **Complete web stack** with reverse proxy, application server, and database
- 📁 **Persistent data storage** with Docker volumes

### 🎓 Learning Objectives

- ✅ Master Docker containerization
- ✅ Understand service orchestration with docker-compose
- ✅ Configure NGINX as a reverse proxy
- ✅ Set up WordPress with PHP-FPM
- ✅ Manage databases with MariaDB
- ✅ Implement SSL/TLS security
- ✅ Handle persistent data with volumes

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    🌐 Internet                              │
└─────────────────────┬───────────────────────────────────────┘
                      │ HTTPS (443)
                      │
┌─────────────────────▼───────────────────────────────────────┐
│             🔒 NGINX (Reverse Proxy)                        │
│                  - TLS Termination                          │
│                  - SSL Certificates                         │
└─────────────────────┬───────────────────────────────────────┘
                      │ FastCGI
                      │
┌─────────────────────▼───────────────────────────────────────┐
│             🐘 WordPress + PHP-FPM                          │
│                  - Content Management                       │
│                  - Application Logic                        │
└─────────────────────┬───────────────────────────────────────┘
                      │ MySQL Protocol
                      │
┌─────────────────────▼───────────────────────────────────────┐
│             🗄️ MariaDB                                       │
│                  - Database Storage                         │
│                  - Data Persistence                         │
└─────────────────────────────────────────────────────────────┘
```

## 📦 Services

### 🔒 NGINX Container
- **Purpose**: Reverse proxy and TLS termination
- **Features**:
  - ✅ Custom SSL/TLS certificates
  - ✅ HTTP to HTTPS redirect
  - ✅ FastCGI proxy to WordPress
  - ✅ Security headers configuration

### 🐘 WordPress Container
- **Purpose**: Content management system
- **Features**:
  - ✅ PHP-FPM for better performance
  - ✅ WordPress installation and configuration
  - ✅ Custom themes and plugins support
  - ✅ Environment-based configuration

### 🗄️ MariaDB Container
- **Purpose**: Database server
- **Features**:
  - ✅ Persistent data storage
  - ✅ Custom database and user creation
  - ✅ Optimized configuration
  - ✅ Backup and restore capabilities

## ⚙️ Installation

### 📋 Prerequisites

- 🐳 **Docker** (v20.10+)
- 🔧 **Docker Compose** (v2.0+)
- 💻 **Linux/macOS** environment
- 🌐 **Domain name** or hosts file configuration

### 🛠️ Setup Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Inception
   ```

2. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Set up domain resolution**
   ```bash
   # Add to /etc/hosts
   echo "127.0.0.1 yourdomain.42.fr" | sudo tee -a /etc/hosts
   ```

4. **Build and start services**
   ```bash
   make
   # or
   docker-compose up --build
   ```

## 🚀 Usage

### 🌟 Quick Start

```bash
# Start all services
make up

# Stop all services
make down

# View logs
make logs

# Clean everything
make clean
```

### 🌐 Access Points

- **🏠 WordPress Site**: `https://yourdomain.42.fr`
- **🔧 WordPress Admin**: `https://yourdomain.42.fr/wp-admin`
- **📊 Database**: `localhost:3306` (internal network only)

### 👤 Default Credentials

| Service | Username | Password |
|---------|----------|----------|
| 🔧 WordPress Admin | `admin` | `admin_password` |
| 👤 WordPress User | `user` | `user_password` |
| 🗄️ MariaDB Root | `root` | `root_password` |
| 🗄️ MariaDB User | `wordpress_user` | `wp_password` |

## 📁 Project Structure

```
Inception/
├── 📄 Makefile                 # Build automation
├── 📄 docker-compose.yml       # Service orchestration
├── 📁 requirements/
│   ├── 🔒 nginx/
│   │   ├── 📄 Dockerfile
│   │   ├── 📁 conf/
│   │   └── 📁 tools/
│   ├── 🐘 wordpress/
│   │   ├── 📄 Dockerfile
│   │   ├── 📁 conf/
│   │   └── 📁 tools/
│   └── 🗄️ mariadb/
│       ├── 📄 Dockerfile
│       ├── 📁 conf/
│       └── 📁 tools/
├── 📁 secrets/                 # Environment variables
└── 📁 srcs/                    # Source configurations
```

## 🔧 Configuration

### 🌍 Environment Variables

```bash
# Domain Configuration
DOMAIN_NAME=yourdomain.42.fr

# Database Configuration
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=wp_password

# WordPress Configuration
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=admin_password
WP_ADMIN_EMAIL=admin@example.com
WP_USER=user
WP_USER_PASSWORD=user_password
WP_USER_EMAIL=user@example.com
```

### 🔒 SSL/TLS Configuration

- 📜 **Self-signed certificates** for development
- 🔐 **TLS 1.2/1.3** support
- 🛡️ **Security headers** implementation
- 🔄 **HTTP to HTTPS** redirection

## 🐛 Troubleshooting

### 🚨 Common Issues

| Issue | Solution |
|-------|----------|
| 🔌 **Port conflicts** | Check if ports 80/443 are in use |
| 🗄️ **Database connection** | Verify MariaDB container is running |
| 🔒 **SSL certificate** | Regenerate certificates if expired |
| 📁 **Permission errors** | Check volume mount permissions |
| 🌐 **Domain resolution** | Verify /etc/hosts configuration |

### 📊 Health Checks

```bash
# Check container status
docker ps

# View service logs
docker-compose logs nginx
docker-compose logs wordpress
docker-compose logs mariadb

# Test database connection
docker exec -it mariadb mysql -u root -p
```

## 📚 Resources

### 📖 Documentation

- 🐳 [Docker Documentation](https://docs.docker.com/)
- 🔧 [Docker Compose Guide](https://docs.docker.com/compose/)
- 🔒 [NGINX Configuration](https://nginx.org/en/docs/)
- 🐘 [WordPress Developer Resources](https://developer.wordpress.org/)
- 🗄️ [MariaDB Documentation](https://mariadb.org/documentation/)

### 🎯 42 School Resources

- 📋 [Inception Subject](https://github.com/42School/42-Subjects/tree/master/inception)
- 🏫 [42 Cursus Guide](https://42.fr/)
- 👥 [42 Community](https://stackoverflow.com/questions/tagged/42school)

---

<div align="center">

### 🎉 Made with ❤️ for 42 Tokyo

[![42](https://img.shields.io/badge/42-Success-00babc?style=flat-square&logo=42&logoColor=white)](https://42tokyo.jp/)

</div>