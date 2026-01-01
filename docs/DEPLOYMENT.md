# Deployment Guide

Complete guide for deploying the Medical Clinic application to a VPS (Ubuntu/Debian).

## Target Environment

| Component | Specification                         |
|-----------|---------------------------------------|
| VPS | 2 CPU, 8GB RAM (Hostinger or similar) |
| OS | Ubuntu 22.04 LTS                      |
| Web Server | Nginx (reverse proxy)                 |
| Process Manager | PM2                                   |
| Node.js | v22.10+ LTS                           |
| Database | MySQL 8.0                             |

## Architecture Overview

```
                    Internet
                        │
                        ▼
                ┌───────────────┐
                │   Nginx       │ :80/:443
                │   (SSL/gzip)  │
                └───────┬───────┘
                        │
        ┌───────────────┴───────────────┐
        │                               │
        ▼                               ▼
┌───────────────┐               ┌───────────────┐
│ Static Files  │               │   Node.js     │ :3000
│ /css, /js     │               │   (Express)   │
│ (direct serve)│               │   via PM2     │
└───────────────┘               └───────┬───────┘
                                        │
                                        ▼
                                ┌───────────────┐
                                │    MySQL      │ :3306
                                │   Database    │
                                └───────────────┘
```

## Step 1: VPS Initial Setup

### 1.1 Connect to VPS

```bash
ssh root@your-vps-ip
```

### 1.2 Create Non-Root User

```bash
# Create user
adduser clinic
usermod -aG sudo clinic

# Switch to new user
su - clinic
```

### 1.3 Update System

```bash
sudo apt update && sudo apt upgrade -y
```

### 1.4 Install Essential Tools

```bash
sudo apt install -y curl wget git ufw
```

## Step 2: Install Node.js

```bash
# Install Node.js 18 LTS via NodeSource
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installation
node --version  # v18.x.x
npm --version   # 9.x.x
```

## Step 3: Install MySQL

### 3.1 Install MySQL Server

```bash
sudo apt install -y mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql
```

### 3.2 Secure MySQL

```bash
sudo mysql_secure_installation

# Follow prompts:
# - Set root password
# - Remove anonymous users: Y
# - Disallow root login remotely: Y
# - Remove test database: Y
# - Reload privilege tables: Y
```

### 3.3 Create Database and User

```bash
sudo mysql -u root -p
```

```sql
-- Create database
CREATE DATABASE medical_clinic CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create user
CREATE USER 'clinic_user'@'localhost' IDENTIFIED BY 'your_secure_password_here';

-- Grant privileges
GRANT ALL PRIVILEGES ON medical_clinic.* TO 'clinic_user'@'localhost';
FLUSH PRIVILEGES;

EXIT;
```

## Step 4: Install PM2

```bash
sudo npm install -g pm2
```

## Step 5: Install Nginx

```bash
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

## Step 6: Deploy Application

### 6.1 Create App Directory

```bash
sudo mkdir -p /var/www/clinic
sudo chown -R clinic:clinic /var/www/clinic
```

### 6.2 Clone/Upload Application

**Option A: Git Clone**
```bash
cd /var/www/clinic
git clone https://github.com/your-repo/studio_patients.git .
```

**Option B: SCP Upload**
```bash
# From your local machine
scp -r ./* clinic@your-vps-ip:/var/www/clinic/
```

### 6.3 Install Dependencies

```bash
cd /var/www/clinic
npm install --production
```

### 6.4 Configure Environment

```bash
nano /var/www/clinic/.env
```

```env
# Database Configuration
DB_HOST=localhost
DB_USER=clinic_user
DB_PASSWORD=021....
DB_NAME=medical_clinic
DB_PORT=3306

# Session Configuration
SESSION_SECRET=generate-a-very-long-random-string-here-64-chars-minimum

# Server Configuration
PORT=3000
NODE_ENV=production

# File Upload Configuration
MAX_FILE_SIZE=10485760
UPLOAD_PATH=./public/uploads

# CORS Configuration
ALLOWED_ORIGINS=https://your-domain.com
```

### 6.5 Initialize Database

```bash
mysql -u clinic_user -p medical_clinic < /var/www/clinic/database/init.sql
mysql -u clinic_user -p medical_clinic < /var/www/clinic/database/diet_system.sql
mysql -u clinic_user -p medical_clinic < /var/www/clinic/database/diet_demo_data.sql
mysql -u clinic_user -p medical_clinic < /var/www/clinic/database/product_links.sql
mysql -u clinic_user -p medical_clinic < /var/www/clinic/database/product_inventory.sql
mysql -u clinic_user -p medical_clinic < /var/www/clinic/database/diet_templates_extended.sql
```

### 6.6 Create Upload Directory

```bash
mkdir -p /var/www/clinic/public/uploads
chmod 755 /var/www/clinic/public/uploads
```

## Step 7: Configure PM2

### 7.1 Create Ecosystem File

```bash
nano /var/www/clinic/ecosystem.config.js
```

```javascript
module.exports = {
  apps: [{
    name: 'clinic',
    script: 'index.js',
    cwd: '/var/www/clinic',
    instances: 1,
    exec_mode: 'fork',
    autorestart: true,
    watch: false,
    max_memory_restart: '500M',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: '/var/www/clinic/logs/error.log',
    out_file: '/var/www/clinic/logs/output.log',
    log_file: '/var/www/clinic/logs/combined.log',
    time: true
  }]
};
```

### 7.2 Create Log Directory

```bash
mkdir -p /var/www/clinic/logs
```

### 7.3 Start Application

```bash
cd /var/www/clinic
pm2 start ecosystem.config.js

# Verify running
pm2 status
pm2 logs clinic
```

### 7.4 Configure PM2 Startup

```bash
pm2 startup systemd -u clinic --hp /home/clinic
pm2 save
```

## Step 8: Configure Nginx

### 8.1 Create Nginx Configuration

```bash
sudo vim /etc/nginx/sites-available/clinic
```

```nginx
# Redirect HTTP to HTTPS (uncomment after SSL setup)
# server {
#     listen 80;
#     server_name your-domain.com;
#     return 301 https://$server_name$request_uri;
# }

server {
    listen 80;
    # listen 443 ssl http2;  # Uncomment after SSL setup
    server_name your-domain.com;  # Or VPS IP for testing

    # SSL Configuration (uncomment after certbot)
    # ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    # ssl_protocols TLSv1.2 TLSv1.3;
    # ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    # ssl_prefer_server_ciphers off;

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Gzip Compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/javascript
        application/javascript
        application/json
        application/xml
        image/svg+xml
        font/woff
        font/woff2;

    # Root directory
    root /var/www/clinic/public;

    # Static Files - CSS (cached 30 days)
    location /css/ {
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
        try_files $uri =404;
    }

    # Static Files - JavaScript (cached 30 days)
    location /js/ {
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
        try_files $uri =404;
    }

    # Static Files - Images (cached 30 days)
    location /images/ {
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
        try_files $uri =404;
    }

    # Favicon
    location /favicon.ico {
        expires 30d;
        access_log off;
        try_files $uri =404;
    }

    # Uploaded Files (handled by Node.js for auth)
    location /uploads/ {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # API and Dynamic Routes - Proxy to Node.js
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 90;
    }

    # Block access to sensitive files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    location ~ /(package\.json|package-lock\.json|\.env|ecosystem\.config\.js) {
        deny all;
    }

    # Error pages
    error_page 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
        internal;
    }
}
```

### 8.2 Enable Site

```bash
# Remove default site
sudo rm /etc/nginx/sites-enabled/default

# Enable clinic site
sudo ln -s /etc/nginx/sites-available/clinic /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

## Step 9: Configure Firewall

```bash
# Allow SSH
sudo ufw allow ssh

# Allow HTTP/HTTPS
sudo ufw allow 'Nginx Full'

# Enable firewall
sudo ufw enable

# Verify
sudo ufw status
```

## Step 10: SSL Certificate (Let's Encrypt)

### 10.1 Install Certbot

```bash
sudo apt install -y certbot python3-certbot-nginx
```

### 10.2 Obtain Certificate

```bash
sudo certbot --nginx -d your-domain.com
```

### 10.3 Auto-Renewal Test

```bash
sudo certbot renew --dry-run
```

## Step 11: Final Verification

### 11.1 Check All Services

```bash
# Node.js app
pm2 status

# Nginx
sudo systemctl status nginx

# MySQL
sudo systemctl status mysql

# Firewall
sudo ufw status
```

### 11.2 Test Application

```bash
# Local test
curl http://localhost:3000/api/health

# External test (from browser)
https://your-domain.com
```

## Maintenance Commands

### PM2 Commands

```bash
# View status
pm2 status

# View logs
pm2 logs clinic
pm2 logs clinic --lines 100

# Restart app
pm2 restart clinic

# Reload (zero-downtime)
pm2 reload clinic

# Stop app
pm2 stop clinic

# Monitor resources
pm2 monit
```

### Nginx Commands

```bash
# Test configuration
sudo nginx -t

# Reload (apply changes)
sudo systemctl reload nginx

# Restart
sudo systemctl restart nginx

# View error logs
sudo tail -f /var/log/nginx/error.log
```

### MySQL Commands

```bash
# Connect to database
mysql -u clinic_user -p medical_clinic

# Backup database
mysqldump -u clinic_user -p medical_clinic > backup_$(date +%Y%m%d).sql

# Restore database
mysql -u clinic_user -p medical_clinic < backup.sql
```

### Update Application

```bash
cd /var/www/clinic

# Pull latest code
git pull origin main

# Install dependencies (if package.json changed)
npm install --production

# Reload app
pm2 reload clinic
```

## Performance Tuning

### Nginx Worker Processes

Edit `/etc/nginx/nginx.conf`:

```nginx
# Set to number of CPU cores
worker_processes 2;

events {
    worker_connections 1024;
    multi_accept on;
    use epoll;
}
```

### MySQL Optimization

Edit `/etc/mysql/mysql.conf.d/mysqld.cnf`:

```ini
[mysqld]
# InnoDB Buffer Pool (set to 50-70% of available RAM for DB)
innodb_buffer_pool_size = 1G

# Query Cache (for read-heavy workloads)
query_cache_type = 1
query_cache_size = 64M

# Connection limits
max_connections = 100
```

## Troubleshooting

### App Not Starting

```bash
# Check PM2 logs
pm2 logs clinic --err --lines 50

# Check if port is in use
sudo lsof -i :3000

# Test app directly
cd /var/www/clinic && node index.js
```

### 502 Bad Gateway

```bash
# Check if Node.js is running
pm2 status

# Check Nginx error log
sudo tail -f /var/log/nginx/error.log

# Verify proxy settings
curl http://127.0.0.1:3000
```

### Database Connection Failed

```bash
# Test MySQL connection
mysql -u clinic_user -p -e "SELECT 1"

# Check MySQL is running
sudo systemctl status mysql

# Verify .env credentials
cat /var/www/clinic/.env | grep DB_
```

### Permission Issues

```bash
# Fix ownership
sudo chown -R clinic:clinic /var/www/clinic

# Fix upload directory permissions
chmod 755 /var/www/clinic/public/uploads
```

## Monitoring Setup (Optional)

### PM2 Monitoring

```bash
# Enable PM2 web dashboard
pm2 install pm2-server-monit

# Or use PM2 Plus (cloud monitoring)
pm2 plus
```

### Simple Health Check Script

Create `/var/www/clinic/healthcheck.sh`:

```bash
#!/bin/bash
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health)
if [ $response != "200" ]; then
    pm2 restart clinic
    echo "$(date): App restarted due to health check failure" >> /var/www/clinic/logs/healthcheck.log
fi
```

Add to crontab:
```bash
crontab -e
# Add line:
*/5 * * * * /var/www/clinic/healthcheck.sh
```

## Security Checklist

- [ ] Non-root user created
- [ ] SSH key authentication (disable password login)
- [ ] Firewall enabled (UFW)
- [ ] SSL certificate installed
- [ ] Environment variables secured (.env not in git)
- [ ] MySQL remote access disabled
- [ ] Nginx security headers configured
- [ ] File upload limits set
- [ ] Rate limiting enabled (Express)
- [ ] Regular backups configured

---

## Multi-Project Setup (Subdomains)

Host multiple projects on the same VPS using subdomains:

```
mywebsite.dev           → Portfolio/Landing page
clinic.mywebsite.dev    → This clinic app (Node.js :3000)
api.mywebsite.dev       → API project (Node.js :3001)
blog.mywebsite.dev      → Blog (Node.js :3002)
python.mywebsite.dev    → Python app (Gunicorn :8000)
```

### Architecture Overview

```
                        Internet
                            │
                            ▼
                    ┌───────────────┐
                    │     Nginx     │ :80/:443
                    │ (reverse proxy)
                    └───────┬───────┘
                            │
            ┌───────────────┼───────────────┬───────────────┐
            │               │               │               │
            ▼               ▼               ▼               ▼
    ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
    │  clinic     │ │    api      │ │   blog      │ │   python    │
    │  :3000      │ │   :3001     │ │  :3002      │ │   :8000     │
    └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘
```

### Step 1: DNS Configuration

In your domain registrar (Hostinger, Cloudflare, etc.):

#### Option A: Individual A Records
```
Type    Name      Value           TTL
A       @         YOUR_VPS_IP     3600    → mywebsite.dev
A       clinic    YOUR_VPS_IP     3600    → clinic.mywebsite.dev
A       api       YOUR_VPS_IP     3600    → api.mywebsite.dev
A       blog      YOUR_VPS_IP     3600    → blog.mywebsite.dev
```

#### Option B: Wildcard Record (Recommended)
```
Type    Name      Value           TTL
A       @         YOUR_VPS_IP     3600    → mywebsite.dev
A       *         YOUR_VPS_IP     3600    → *.mywebsite.dev (all subdomains)
```

### Step 2: Directory Structure

```bash
/var/www/
├── clinic/              → clinic.mywebsite.dev (Node.js)
│   ├── index.js
│   ├── package.json
│   └── .env
├── api/                 → api.mywebsite.dev (Node.js)
│   ├── index.js
│   ├── package.json
│   └── .env
├── blog/                → blog.mywebsite.dev (Node.js)
│   ├── index.js
│   └── ...
├── python-app/          → python.mywebsite.dev (Python)
│   ├── app.py
│   ├── requirements.txt
│   └── venv/
└── portfolio/           → mywebsite.dev (static or Node.js)
    └── index.html
```

### Step 3: PM2 Multi-App Configuration

Create `/var/www/ecosystem.config.js` (global config):

```javascript
module.exports = {
  apps: [
    // Clinic App (Node.js)
    {
      name: 'clinic',
      script: 'index.js',
      cwd: '/var/www/clinic',
      instances: 1,
      exec_mode: 'fork',
      autorestart: true,
      max_memory_restart: '400M',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      error_file: '/var/www/clinic/logs/error.log',
      out_file: '/var/www/clinic/logs/output.log'
    },

    // API Project (Node.js)
    {
      name: 'api',
      script: 'index.js',
      cwd: '/var/www/api',
      instances: 1,
      exec_mode: 'fork',
      autorestart: true,
      max_memory_restart: '300M',
      env: {
        NODE_ENV: 'production',
        PORT: 3001
      },
      error_file: '/var/www/api/logs/error.log',
      out_file: '/var/www/api/logs/output.log'
    },

    // Blog (Node.js)
    {
      name: 'blog',
      script: 'index.js',
      cwd: '/var/www/blog',
      instances: 1,
      exec_mode: 'fork',
      autorestart: true,
      max_memory_restart: '300M',
      env: {
        NODE_ENV: 'production',
        PORT: 3002
      }
    }
  ]
};
```

Start all apps:
```bash
pm2 start /var/www/ecosystem.config.js
pm2 save
```

### Step 4: Nginx Configuration for Each Subdomain

#### Main Domain - `/etc/nginx/sites-available/mywebsite`

```nginx
server {
    listen 80;
    server_name mywebsite.dev www.mywebsite.dev;

    root /var/www/portfolio;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

#### Clinic Subdomain - `/etc/nginx/sites-available/clinic`

```nginx
server {
    listen 80;
    server_name clinic.mywebsite.dev;

    # Gzip
    gzip on;
    gzip_types text/plain text/css application/javascript application/json;

    # Static files
    root /var/www/clinic/public;

    location /css/ {
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    location /js/ {
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # Proxy to Node.js
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### API Subdomain - `/etc/nginx/sites-available/api`

```nginx
server {
    listen 80;
    server_name api.mywebsite.dev;

    # CORS headers for API
    add_header Access-Control-Allow-Origin *;
    add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
    add_header Access-Control-Allow-Headers "Authorization, Content-Type";

    location / {
        proxy_pass http://127.0.0.1:3001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### Python App Subdomain - `/etc/nginx/sites-available/python`

```nginx
server {
    listen 80;
    server_name python.mywebsite.dev;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /static/ {
        alias /var/www/python-app/static/;
        expires 30d;
    }
}
```

### Step 5: Enable All Sites

```bash
# Enable each site
sudo ln -s /etc/nginx/sites-available/mywebsite /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/clinic /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/api /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/python /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

### Step 6: SSL for All Subdomains

```bash
# Individual certificates
sudo certbot --nginx -d mywebsite.dev -d www.mywebsite.dev
sudo certbot --nginx -d clinic.mywebsite.dev
sudo certbot --nginx -d api.mywebsite.dev

# OR wildcard certificate (requires DNS challenge)
sudo certbot certonly --manual --preferred-challenges dns \
    -d mywebsite.dev -d *.mywebsite.dev
```

### Step 7: Python App Setup (Gunicorn + PM2)

```bash
# Create virtual environment
cd /var/www/python-app
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip install gunicorn

# Test locally
gunicorn --bind 127.0.0.1:8000 app:app
```

Add Python app to PM2:

```javascript
// In ecosystem.config.js, add:
{
  name: 'python-app',
  script: '/var/www/python-app/venv/bin/gunicorn',
  args: '--workers 2 --bind 127.0.0.1:8000 app:app',
  cwd: '/var/www/python-app',
  interpreter: 'none',
  autorestart: true,
  max_memory_restart: '300M'
}
```

### Resource Planning (2 CPU, 8GB RAM)

| App | Port | Memory | Purpose |
|-----|------|--------|---------|
| clinic | 3000 | ~400MB | Medical clinic |
| api | 3001 | ~300MB | REST API |
| blog | 3002 | ~300MB | Blog/CMS |
| python-app | 8000 | ~300MB | Python project |
| MySQL | 3306 | ~1GB | Database |
| Nginx | 80/443 | ~100MB | Reverse proxy |
| **Reserved** | - | ~5.5GB | Buffer/OS |

### Quick Commands

```bash
# View all PM2 apps
pm2 status

# Restart specific app
pm2 restart clinic
pm2 restart api

# View logs for specific app
pm2 logs clinic
pm2 logs api --lines 50

# Stop all
pm2 stop all

# Start all
pm2 start /var/www/ecosystem.config.js
```

### Port Reference

| Subdomain | App | Port |
|-----------|-----|------|
| mywebsite.dev | static/portfolio | - (Nginx direct) |
| clinic.mywebsite.dev | Node.js | 3000 |
| api.mywebsite.dev | Node.js | 3001 |
| blog.mywebsite.dev | Node.js | 3002 |
| python.mywebsite.dev | Gunicorn | 8000 |
| db.mywebsite.dev | phpMyAdmin (optional) | 8080 |

### Adding a New Project

```bash
# 1. Create directory
sudo mkdir -p /var/www/newproject
sudo chown -R $USER:$USER /var/www/newproject

# 2. Deploy code
cd /var/www/newproject
git clone https://github.com/you/newproject.git .
npm install --production

# 3. Add to PM2 ecosystem.config.js
# (add new app block with unique port)

# 4. Create Nginx config
sudo nano /etc/nginx/sites-available/newproject
# (copy template, change server_name and proxy_pass port)

# 5. Enable site
sudo ln -s /etc/nginx/sites-available/newproject /etc/nginx/sites-enabled/

# 6. Get SSL
sudo certbot --nginx -d newproject.mywebsite.dev

# 7. Restart services
pm2 restart all
sudo systemctl reload nginx
```
