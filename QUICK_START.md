# AdaptEd - Quick Start Guide

## 🎯 What You Need

1. **AWS Account** with EC2 access
2. **API Keys:**
   - Gemini API (Google AI) - **REQUIRED**
   - OpenAI API - **REQUIRED** (for Viva Voice)
   - Groq API - **REQUIRED** (for Viva Voice)
   - YouTube API - Optional
   - Hugging Face API - Optional
   - Firebase credentials - **REQUIRED**
   - Supabase credentials - **REQUIRED** (for MCP-IDE)
3. **Domain name** (optional, for HTTPS)

📚 **See `ENV_SETUP_GUIDE.md` for detailed instructions on getting all API keys**

## 🚀 5-Minute Local Setup

### 0. Setup Environment Files (One-Time)
```bash
# Run the setup script to create .env files from templates
bash setup-env.sh

# Then edit each .env file with your API keys:
# - backend/.env
# - frontend/.env
# - mcp-ide/backend/.env
```

### 1. Copy Dyslexia Fonts
```bash
bash setup-fonts.sh
```

### 2. Setup Main Backend
```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Make sure .env file has your API keys (from step 0)
# Start backend
python main.py
```

### 3. Setup Main Frontend (New Terminal)
```bash
cd frontend
npm install

# Make sure .env file has your Firebase config (from step 0)
# Start frontend
npm run dev
```

### 4. Setup MCP-IDE Backend (New Terminal)
```bash
cd mcp-ide/backend
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Make sure .env file has your API keys (from step 0)
# Start backend
python main.py
```

### 5. Setup MCP-IDE Frontend (New Terminal)
```bash
cd mcp-ide/frontend
npm install

# Start frontend
npm run dev
```

### 6. Test Application
- Main App: http://localhost:5173
- MCP-IDE: http://localhost:5174
- Look for dyslexia toggle button (bottom-right)
- Click to test dyslexia mode

## ☁️ AWS EC2 Deployment

### Step 1: Launch EC2
- Instance: t3.medium
- OS: Ubuntu 22.04 LTS
- Storage: 30 GB
- Security Group: Ports 22, 80, 443, 8000

### Step 2: Connect & Install
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip

# Install everything
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt update && sudo apt install -y nodejs python3.11 python3.11-venv python3-pip nginx git build-essential
sudo npm install -g pm2
```

### Step 3: Deploy
```bash
cd /home/ubuntu
git clone <your-repo-url> adapted
cd adapted

# Backend
cd backend
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
# Upload your .env file here
mkdir -p logs
pm2 start ecosystem.config.js
pm2 save
pm2 startup  # Run the command it outputs

# Frontend
cd ../frontend
npm install
# Upload your .env.production file here
npm run build

# Nginx
cd ..
sudo cp nginx.conf /etc/nginx/sites-available/adapted
sudo ln -s /etc/nginx/sites-available/adapted /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
```

### Step 4: Access
Open: `http://your-ec2-public-ip`

## 🎨 Dyslexia Mode

### How to Use:
1. Look for purple button in bottom-right corner
2. Click "Dyslexia Mode" toggle
3. Font changes to OpenDyslexic
4. Reading ruler appears (follows mouse)
5. Toggle off to return to normal

### Features:
- ✅ OpenDyslexic font
- ✅ 2x line spacing
- ✅ Increased letter/word spacing
- ✅ Yellow reading ruler
- ✅ Persistent across sessions

## 📊 Verify Deployment

```bash
# Check services
pm2 status
sudo systemctl status nginx

# Check logs
pm2 logs adapted-backend
sudo tail -f /var/log/nginx/error.log

# Test API
curl http://localhost:8000/health
```

## 🔄 Update Application

```bash
cd /home/ubuntu/adapted
git pull
bash deploy.sh
```

## 🆘 Quick Troubleshooting

### Backend not working?
```bash
pm2 logs adapted-backend --lines 50
```

### Frontend not loading?
```bash
sudo nginx -t
sudo tail -f /var/log/nginx/error.log
```

### Dyslexia mode not working?
```bash
# Check fonts exist
ls -la /home/ubuntu/adapted/frontend/dist/fonts/
# If missing, run setup-fonts.sh and rebuild
```

## 📚 Full Documentation

- **Complete Guide:** `AWS_DEPLOYMENT_GUIDE.md`
- **Checklist:** `DEPLOYMENT_CHECKLIST.md`
- **Summary:** `DEPLOYMENT_SUMMARY.md`

## 💰 Cost

**t3.medium:** ~$40-45/month
- EC2: $30
- Storage: $3
- Transfer: $5-10

## 🎉 You're Done!

Your application is now running with:
- ✅ AI-powered learning platform
- ✅ Dyslexia mode (embedded)
- ✅ Production-ready deployment
- ✅ Auto-restart on reboot
- ✅ Nginx reverse proxy

**Need help?** Check the full documentation files!
