# AdaptEd AWS Deployment Checklist

## Pre-Deployment Setup

### 1. Copy Dyslexia Fonts
```bash
# Run this script to copy fonts to frontend
bash setup-fonts.sh
```

### 2. Prepare Environment Variables

#### Backend (.env)
Create `backend/.env` with:
```env
GEMINI_API_KEY=your_gemini_api_key
YOUTUBE_API_KEY=your_youtube_api_key
OPENAI_API_KEY=your_openai_api_key
GROQ_API_KEY=your_groq_api_key
HUGGINGFACE_API_KEY=your_huggingface_api_key
```

#### Frontend (.env.production)
Create `frontend/.env.production` with:
```env
VITE_API_URL=http://your-ec2-ip/api
VITE_FIREBASE_API_KEY=your_firebase_api_key
VITE_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your_project_id
VITE_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
VITE_FIREBASE_APP_ID=your_app_id
```

### 3. Test Locally

#### Backend
```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python main.py
# Should start on http://localhost:8000
```

#### Frontend
```bash
cd frontend
npm install
npm run dev
# Should start on http://localhost:5173
```

## AWS EC2 Setup

### 1. Launch EC2 Instance
- [ ] Instance Type: t3.medium (minimum)
- [ ] OS: Ubuntu 22.04 LTS
- [ ] Storage: 30 GB gp3
- [ ] Security Group configured (ports 22, 80, 443, 8000)
- [ ] SSH key pair downloaded

### 2. Connect to Instance
```bash
ssh -i your-key.pem ubuntu@your-ec2-public-ip
```

### 3. Install System Dependencies
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

# Install PM2
sudo npm install -g pm2

# Install build tools
sudo apt install -y build-essential
```

### 4. Clone Repository
```bash
cd /home/ubuntu
git clone <your-repo-url> adapted
cd adapted
```

### 5. Setup Backend
```bash
cd /home/ubuntu/adapted/backend

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Copy .env file (upload via SCP or create manually)
nano .env
# Paste your environment variables

# Create logs directory
mkdir -p logs

# Test backend
python main.py
# Press Ctrl+C after verification
```

### 6. Setup Frontend
```bash
cd /home/ubuntu/adapted/frontend

# Install dependencies
npm install

# Copy .env.production (upload via SCP or create manually)
nano .env.production
# Paste your environment variables

# Build for production
npm run build
```

### 7. Configure PM2
```bash
cd /home/ubuntu/adapted/backend

# Start backend with PM2
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup
# Run the command that PM2 outputs
```

### 8. Configure Nginx
```bash
# Copy nginx configuration
sudo cp /home/ubuntu/adapted/nginx.conf /etc/nginx/sites-available/adapted

# Enable the site
sudo ln -s /etc/nginx/sites-available/adapted /etc/nginx/sites-enabled/

# Remove default site
sudo rm /etc/nginx/sites-enabled/default

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

### 9. Update Frontend API URL
```bash
cd /home/ubuntu/adapted/frontend

# Edit .env.production with your EC2 IP
nano .env.production
# Update VITE_API_URL to: http://your-ec2-public-ip/api

# Rebuild
npm run build

# Restart Nginx
sudo systemctl restart nginx
```

## Post-Deployment Verification

### 1. Check Services
```bash
# Check PM2 status
pm2 status

# Check Nginx status
sudo systemctl status nginx

# Check backend logs
pm2 logs adapted-backend

# Check Nginx logs
sudo tail -f /var/log/nginx/error.log
```

### 2. Test Application
- [ ] Open browser: `http://your-ec2-public-ip`
- [ ] Login page loads
- [ ] Can create account / login
- [ ] Dashboard loads
- [ ] API calls work
- [ ] Dyslexia toggle appears (bottom-right)
- [ ] Dyslexia mode works when toggled
- [ ] Reading ruler follows mouse

### 3. Test Dyslexia Mode
- [ ] Click dyslexia toggle button (bottom-right)
- [ ] Font changes to OpenDyslexic
- [ ] Line spacing increases
- [ ] Letter spacing increases
- [ ] Reading ruler appears and follows mouse
- [ ] Toggle off returns to normal

## Optional: SSL Setup

### Install SSL Certificate
```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get certificate (replace with your domain)
sudo certbot --nginx -d your-domain.com

# Certificates will auto-renew
```

## Maintenance

### Update Application
```bash
cd /home/ubuntu/adapted
bash deploy.sh
```

### View Logs
```bash
# Backend logs
pm2 logs adapted-backend

# Nginx access logs
sudo tail -f /var/log/nginx/access.log

# Nginx error logs
sudo tail -f /var/log/nginx/error.log
```

### Restart Services
```bash
# Restart backend
pm2 restart adapted-backend

# Restart Nginx
sudo systemctl restart nginx

# Restart both
pm2 restart all && sudo systemctl restart nginx
```

## Troubleshooting

### Backend not starting
```bash
# Check logs
pm2 logs adapted-backend --lines 100

# Check if port is in use
sudo lsof -i :8000

# Manually test
cd /home/ubuntu/adapted/backend
source venv/bin/activate
python main.py
```

### Frontend not loading
```bash
# Check Nginx config
sudo nginx -t

# Check if files exist
ls -la /home/ubuntu/adapted/frontend/dist

# Check Nginx error logs
sudo tail -f /var/log/nginx/error.log
```

### Dyslexia mode not working
```bash
# Check if fonts exist
ls -la /home/ubuntu/adapted/frontend/dist/fonts/

# If fonts missing, copy them
cd /home/ubuntu/adapted
bash setup-fonts.sh
npm run build
sudo systemctl restart nginx
```

### API calls failing
```bash
# Test backend directly
curl http://localhost:8000/health

# Test through Nginx
curl http://localhost/api/health

# Check Nginx proxy config
sudo cat /etc/nginx/sites-enabled/adapted
```

## Security Checklist

- [ ] SSH key-based authentication only
- [ ] Firewall configured (UFW)
- [ ] SSL certificate installed
- [ ] Environment variables secured
- [ ] Regular system updates scheduled
- [ ] Backup strategy in place
- [ ] Monitoring configured

## Performance Optimization

- [ ] Nginx gzip compression enabled
- [ ] Static assets cached
- [ ] PM2 cluster mode (if needed)
- [ ] Database connection pooling
- [ ] CDN for static assets (optional)

## Monitoring

### Setup Basic Monitoring
```bash
# Install htop for system monitoring
sudo apt install -y htop

# Monitor system resources
htop

# Monitor disk usage
df -h

# Monitor memory
free -h
```

## Cost Estimation

**t3.medium instance (monthly):**
- EC2 Instance: ~$30
- Storage (30 GB): ~$3
- Data Transfer: ~$5-10
- **Total: ~$40-45/month**

## Support Contacts

- AWS Support: https://console.aws.amazon.com/support/
- Backend Issues: Check PM2 logs
- Frontend Issues: Check browser console
- Nginx Issues: Check /var/log/nginx/

---

**Deployment Date:** _____________

**Deployed By:** _____________

**EC2 Instance ID:** _____________

**Public IP:** _____________

**Domain (if any):** _____________
