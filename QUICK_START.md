# AdaptEd - Quick Start Guide

## 🏗️ Architecture

```
Root Frontend (Port 5173) → Root Backend (Port 8001)
     └─ embeds via iframe ─→ MCP-IDE Frontend (Port 5174) → MCP-IDE Backend (Port 8000)
```

## 🎯 What You Need

**API Keys:**
- Gemini API - **REQUIRED** (for both backends)
- OpenAI API - **REQUIRED** (for Viva Voice)
- Groq API - **REQUIRED** (for Viva Voice)
- Firebase - **REQUIRED** (for authentication)
- Supabase - **REQUIRED** (for MCP-IDE file storage)
- YouTube API - Optional
- Hugging Face API - Optional

📚 **See `ENV_SETUP_GUIDE.md` for getting API keys**

## 🚀 Local Development (4 Services)

### Step 1: Setup Environment Files
```bash
bash setup-env.sh
# Edit: backend/.env, frontend/.env, mcp-ide/backend/.env
```

### Step 2: Copy Dyslexia Fonts
```bash
bash setup-fonts.sh
```

### Step 3: Start Root Backend (Terminal 1)
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python main.py
```
✅ Running on http://localhost:8001

### Step 4: Start Root Frontend (Terminal 2)
```bash
cd frontend
npm install
npm run dev
```
✅ Running on http://localhost:5173

### Step 5: Start MCP-IDE Backend (Terminal 3)
```bash
cd mcp-ide/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python main.py
```
✅ Running on http://localhost:8000

### Step 6: Start MCP-IDE Frontend (Terminal 4)
```bash
cd mcp-ide/frontend
npm install
npm run dev
```
✅ Running on http://localhost:5174

### Step 7: Test
1. Open http://localhost:5173 (Root Frontend)
2. Login/Signup
3. Go to "Code Sandbox" page
4. MCP-IDE should load in iframe
5. Test dyslexia toggle (bottom-right)

### Step 8: Test Production Builds
```bash
# Before deploying, test that everything builds
bash test-build.sh
```

This will:
- Check all .env files
- Verify fonts are present
- Build both frontends
- Report any errors

✅ **All tests pass?** You're ready to deploy!

## ☁️ AWS EC2 Deployment

### Instance Requirements
- Type: t3.medium (2 vCPU, 4 GB RAM)
- OS: Ubuntu 22.04 LTS
- Storage: 30 GB
- Ports: 22, 80, 443, 8000, 8001, 5174

### Quick Deploy
```bash
# On EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# Install dependencies
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt update && sudo apt install -y nodejs python3.11 python3.11-venv python3-pip nginx git build-essential
sudo npm install -g pm2

# Clone and setup
cd /home/ubuntu
git clone <your-repo> adapted
cd adapted
bash setup-env.sh  # Then edit .env files
bash setup-fonts.sh

# Build and start root backend
cd backend
python3.11 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
pm2 start ecosystem.config.js

# Build root frontend
cd ../frontend
npm install && npm run build

# Build and start MCP-IDE backend
cd ../mcp-ide/backend
python3.11 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
pm2 start ecosystem.config.js

# Build MCP-IDE frontend
cd ../frontend
npm install && npm run build

# Configure Nginx (see DEPLOYMENT_GUIDE.md)
pm2 save && pm2 startup
```

## 🔍 Service Status

```bash
# Check all services
pm2 status

# View logs
pm2 logs adapted-backend
pm2 logs mcp-ide-backend

# Test endpoints
curl http://localhost:8001/health  # Root backend
curl http://localhost:8000/health  # MCP-IDE backend
```

## 🎨 Dyslexia Mode

- Purple button in bottom-right corner
- Click to toggle OpenDyslexic font
- Reading ruler follows mouse
- Works across all pages

## 📚 Full Documentation

- **DEPLOYMENT_GUIDE.md** - Complete deployment instructions
- **ENV_SETUP_GUIDE.md** - Environment variables guide
- **COMPLETE_SETUP_SUMMARY.md** - Full overview

## 💰 Cost

**t3.medium:** ~$40-45/month

## 🆘 Troubleshooting

### Services not starting?
```bash
pm2 logs <service-name>
```

### Frontend not loading?
```bash
sudo nginx -t
sudo tail -f /var/log/nginx/error.log
```

### MCP-IDE not loading in iframe?
- Check browser console
- Verify port 5174 is accessible
- Check CodeSandbox.tsx iframe URL

---

**Need Help?** Check `DEPLOYMENT_GUIDE.md` for detailed instructions!
