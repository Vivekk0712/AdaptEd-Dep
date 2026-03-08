# AWS EC2 Deployment Guide for AdaptEd

This guide will help you deploy the AdaptEd application (frontend + backend) on an AWS EC2 instance.

## Prerequisites

- AWS Account
- EC2 instance (recommended: t3.medium or larger)
- Domain name (optional, for HTTPS)
- SSH key pair for EC2 access

## Architecture Overview

```
┌─────────────────────────────────────────┐
│         AWS EC2 Instance                │
│                                         │
│  ┌──────────────┐  ┌─────────────────┐ │
│  │   Nginx      │  │   Backend       │ │
│  │   (Port 80)  │──│   (Port 8000)   │ │
│  │              │  │   FastAPI       │ │
│  └──────────────┘  └─────────────────┘ │
│         │                               │
│  ┌──────────────┐                      │
│  │   Frontend   │                      │
│  │   (Static)   │                      │
│  └──────────────┘                      │
└─────────────────────────────────────────┘
```

## Step 1: Launch EC2 Instance

### Recommended Instance Type
- **Instance Type**: t3.medium (2 vCPU, 4 GB RAM)
- **OS**: Ubuntu 22.04 LTS
- **Storage**: 30 GB gp3

### Security Group Rules
```
Inbound Rules:
- SSH (22) - Your IP
- HTTP (80) - 0.0.0.0/0
- HTTPS (443) - 0.0.0.0/0
- Custom TCP (8000) - 0.0.0.0/0 (for backend API)
```

## Step 2: Connect to EC2 Instance

```bash
ssh -i your-key.pem ubuntu@your-ec2-public-ip
```

## Step 3: Install Dependencies

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install Python 3.11
sudo apt install -y python3.11 python3.11-venv python3-pip

# Install Nginx
sudo apt install -y nginx

# Install Git
sudo apt install -y git

# Install PM2 (process manager)
sudo npm install -g pm2

# Install build essentials
sudo apt install -y build-essential
```

## Step 4: Clone Repository

```bash
cd /home/ubuntu
git clone <your-repo-url> adapted
cd adapted
```

## Step 5: Setup Backend

```bash
cd /home/ubuntu/adapted/backend

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Create .env file
cat > .env << EOF
GEMINI_API_KEY=your_gemini_api_key_here
YOUTUBE_API_KEY=your_youtube_api_key_here
OPENAI_API_KEY=your_openai_api_key_here
GROQ_API_KEY=your_groq_api_key_here
HUGGINGFACE_API_KEY=your_huggingface_api_key_here
EOF

# Test backend
python main.py
# Press Ctrl+C after verifying it starts
```

## Step 6: Setup Frontend

```bash
cd /home/ubuntu/adapted/frontend

# Install dependencies
npm install

# Create production .env file
cat > .env.production << EOF
VITE_API_URL=http://your-ec2-public-ip:8000
VITE_FIREBASE_API_KEY=your_firebase_api_key
VITE_FIREBASE_AUTH_DOMAIN=your_firebase_auth_domain
VITE_FIREBASE_PROJECT_ID=your_firebase_project_id
VITE_FIREBASE_STORAGE_BUCKET=your_firebase_storage_bucket
VITE_FIREBASE_MESSAGING_SENDER_ID=your_firebase_messaging_sender_id
VITE_FIREBASE_APP_ID=your_firebase_app_id
EOF

# Build for production
npm run build

# The build output will be in /home/ubuntu/adapted/frontend/dist
```

## Step 7: Configure PM2 for Backend

```bash
cd /home/ubuntu/adapted/backend

# Create PM2 ecosystem file
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: 'adapted-backend',
    script: 'venv/bin/uvicorn',
    args: 'main:app --host 0.0.0.0 --port 8000',
    cwd: '/home/ubuntu/adapted/backend',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production'
    }
  }]
};
EOF

# Start backend with PM2
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup
# Run the command that PM2 outputs
```

## Step 8: Configure Nginx

```bash
# Create Nginx configuration
sudo tee /etc/nginx/sites-available/adapted << EOF
server {
    listen 80;
    server_name your-domain.com;  # Replace with your domain or EC2 public IP

    # Frontend (React app)
    location / {
        root /home/ubuntu/adapted/frontend/dist;
        try_files \$uri \$uri/ /index.html;
        
        # Enable gzip compression
        gzip on;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:8000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Increase timeouts for AI operations
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
    }

    # Direct backend access (for development)
    location /docs {
        proxy_pass http://localhost:8000/docs;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    # Health check endpoint
    location /health {
        proxy_pass http://localhost:8000/health;
    }
}
EOF

# Enable the site
sudo ln -s /etc/nginx/sites-available/adapted /etc/nginx/sites-enabled/

# Remove default site
sudo rm /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

## Step 9: Update Frontend API URL

After deployment, update the frontend to use the correct API URL:

```bash
cd /home/ubuntu/adapted/frontend

# Update .env.production with your EC2 public IP or domain
nano .env.production
# Change VITE_API_URL to: http://your-ec2-public-ip/api

# Rebuild
npm run build

# Restart Nginx
sudo systemctl restart nginx
```

## Step 10: Setup SSL (Optional but Recommended)

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get SSL certificate (replace with your domain)
sudo certbot --nginx -d your-domain.com

# Certbot will automatically configure Nginx for HTTPS
# Certificates will auto-renew
```

## Step 11: Monitoring and Logs

```bash
# View backend logs
pm2 logs adapted-backend

# View Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Check PM2 status
pm2 status

# Check Nginx status
sudo systemctl status nginx
```

## Step 12: Firewall Configuration (Optional)

```bash
# Enable UFW firewall
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable
```

## Deployment Checklist

- [ ] EC2 instance launched with correct security groups
- [ ] All dependencies installed
- [ ] Repository cloned
- [ ] Backend .env file configured with API keys
- [ ] Frontend .env.production configured
- [ ] Backend running with PM2
- [ ] Frontend built and deployed
- [ ] Nginx configured and running
- [ ] SSL certificate installed (if using domain)
- [ ] Firewall configured
- [ ] Application accessible via browser

## Updating the Application

```bash
# Pull latest changes
cd /home/ubuntu/adapted
git pull

# Update backend
cd backend
source venv/bin/activate
pip install -r requirements.txt
pm2 restart adapted-backend

# Update frontend
cd ../frontend
npm install
npm run build
sudo systemctl restart nginx
```

## Troubleshooting

### Backend not starting
```bash
# Check logs
pm2 logs adapted-backend

# Check if port 8000 is in use
sudo lsof -i :8000

# Restart backend
pm2 restart adapted-backend
```

### Frontend not loading
```bash
# Check Nginx configuration
sudo nginx -t

# Check Nginx logs
sudo tail -f /var/log/nginx/error.log

# Verify build files exist
ls -la /home/ubuntu/adapted/frontend/dist
```

### API calls failing
```bash
# Check if backend is running
pm2 status

# Test backend directly
curl http://localhost:8000/health

# Check Nginx proxy configuration
sudo nginx -t
```

## Cost Estimation

**Monthly costs for t3.medium instance:**
- EC2 Instance: ~$30/month
- Storage (30 GB): ~$3/month
- Data Transfer: ~$5-10/month
- **Total: ~$40-45/month**

## Performance Optimization

1. **Enable Nginx caching** for static assets
2. **Use CloudFront CDN** for global distribution
3. **Implement Redis** for session management
4. **Use RDS** for production database
5. **Enable auto-scaling** for high traffic

## Security Best Practices

1. Keep all software updated
2. Use strong passwords and SSH keys
3. Enable SSL/TLS
4. Configure firewall rules
5. Regular backups
6. Monitor logs for suspicious activity
7. Use environment variables for secrets
8. Implement rate limiting

## Support

For issues or questions, refer to:
- Backend logs: `pm2 logs adapted-backend`
- Nginx logs: `/var/log/nginx/`
- Application logs: Check console in browser DevTools
