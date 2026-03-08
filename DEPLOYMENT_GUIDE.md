# AdaptEd - Complete Deployment Guide

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        User Browser                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    Root Frontend (Port 5173)                 │
│                  Main AdaptEd Application                    │
│  - Dashboard, Learning Path, Viva, etc.                     │
│  - Code Sandbox page embeds MCP-IDE via iframe              │
└─────────────────────────────────────────────────────────────┘
         │                                    │
         │ API Calls                          │ iframe embed
         ↓                                    ↓
┌──────────────────────┐         ┌──────────────────────────┐
│  Root Backend        │         │  MCP-IDE Frontend        │
│  (Port 8001)         │         │  (Port 5174)             │
│  - Learning API      │         │  - Code Editor UI        │
│  - Viva Engine       │         │  - Terminal UI           │
│  - Content Gen       │         │  - File Explorer         │
└──────────────────────┘         └──────────────────────────┘
                                              │
                                              │ API Calls
                                              ↓
                                 ┌──────────────────────────┐
                                 │  MCP-IDE Backend         │
                                 │  (Port 8000)             │
                                 │  - Code Execution        │
                                 │  - File Management       │
                                 │  - AI Tutor              │
                                 └──────────────────────────┘
```

## 📦 Components

### 1. Root Frontend (Main AdaptEd UI)
- **Location:** `frontend/`
- **Port:** 5173 (dev), 80 (production)
- **Purpose:** Main application UI
- **Connects to:** Root Backend (Port 8001)
- **Embeds:** MCP-IDE Frontend via iframe on Code Sandbox page

### 2. Root Backend (Main AdaptEd API)
- **Location:** `backend/`
- **Port:** 8001
- **Purpose:** Learning paths, viva voice, content generation
- **Tech:** FastAPI, Python 3.11

### 3. MCP-IDE Frontend (Code Editor UI)
- **Location:** `mcp-ide/frontend/`
- **Port:** 5174
- **Purpose:** Code editor interface (embedded in root frontend)
- **Connects to:** MCP-IDE Backend (Port 8000)
- **Accessed via:** iframe in root frontend's Code Sandbox page

### 4. MCP-IDE Backend (Code Editor API)
- **Location:** `mcp-ide/backend/`
- **Port:** 8000
- **Purpose:** Code execution, file management, AI tutor
- **Tech:** FastAPI, Python 3.11, Supabase

---

## 🚀 Local Development Setup

### Prerequisites
- Python 3.11+
- Node.js 20+
- Git

### Step 1: Clone Repository
```bash
git clone <your-repo-url>
cd adapted
```

### Step 2: Setup Environment Files
```bash
# Create all .env files from templates
bash setup-env.sh

# Edit each file with your API keys:
# 1. backend/.env - Root backend API keys
# 2. frontend/.env - Root frontend config
# 3. mcp-ide/backend/.env - MCP-IDE backend API keys
```

### Step 3: Setup Dyslexia Fonts
```bash
bash setup-fonts.sh
```

### Step 4: Start Root Backend (Terminal 1)
```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python main.py
```
✅ Root Backend running on http://localhost:8001

### Step 5: Start Root Frontend (Terminal 2)
```bash
cd frontend
npm install
npm run dev
```
✅ Root Frontend running on http://localhost:5173

### Step 6: Start MCP-IDE Backend (Terminal 3)
```bash
cd mcp-ide/backend
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python main.py
```
✅ MCP-IDE Backend running on http://localhost:8000

### Step 7: Start MCP-IDE Frontend (Terminal 4)
```bash
cd mcp-ide/frontend
npm install
npm run dev
```
✅ MCP-IDE Frontend running on http://localhost:5174

### Step 8: Test the Application
1. Open http://localhost:5173 (Root Frontend)
2. Login/Signup
3. Navigate to "Code Sandbox" page
4. You should see MCP-IDE embedded (loaded from http://localhost:5174)
5. Test dyslexia mode toggle (bottom-right corner)

### Step 9: Test Production Builds (Before Deployment)
```bash
# Run comprehensive build test
bash test-build.sh
```

This script will:
- ✅ Check all .env files exist
- ✅ Verify dyslexia fonts are present
- ✅ Test both backend dependencies
- ✅ Build both frontends for production
- ✅ Verify build outputs (dist/ folders)
- ✅ Check for common issues

**Important:** Fix any errors before deploying to AWS!

---

## 📋 Pre-Deployment Checklist

Before deploying to AWS, run through this checklist:

### Local Testing
- [ ] Run `bash setup-env.sh` and fill in all .env files
- [ ] Run `bash setup-fonts.sh` to copy dyslexia fonts
- [ ] Run `bash test-build.sh` - all tests pass
- [ ] Test root backend: `cd backend && python main.py`
- [ ] Test root frontend: `cd frontend && npm run dev`
- [ ] Test MCP-IDE backend: `cd mcp-ide/backend && python main.py`
- [ ] Test MCP-IDE frontend: `cd mcp-ide/frontend && npm run dev`
- [ ] Verify all 4 services work together locally
- [ ] Test dyslexia mode toggle
- [ ] Test Code Sandbox page (MCP-IDE iframe loads)

### Build Verification
- [ ] Root frontend builds: `cd frontend && npm run build`
- [ ] MCP-IDE frontend builds: `cd mcp-ide/frontend && npm run build`
- [ ] Check `frontend/dist/` folder exists
- [ ] Check `frontend/dist/fonts/` folder exists (dyslexia fonts)
- [ ] Check `mcp-ide/frontend/dist/` folder exists
- [ ] No TypeScript errors
- [ ] No build warnings (or acceptable warnings only)

### Environment Files
- [ ] `backend/.env` has real API keys (not template values)
- [ ] `frontend/.env.production` created with production API URL
- [ ] `mcp-ide/backend/.env` has real API keys
- [ ] Firebase config is correct
- [ ] Supabase config is correct
- [ ] All required API keys present

### AWS Preparation
- [ ] EC2 instance launched (t3.medium, Ubuntu 22.04)
- [ ] Security groups configured (ports 22, 80, 443, 8000, 8001, 5174)
- [ ] SSH key downloaded and secured
- [ ] Can connect via SSH
- [ ] Domain name configured (optional)

---

## ☁️ AWS EC2 Production Deployment

### Recommended Instance
- **Type:** t3.medium (2 vCPU, 4 GB RAM)
- **OS:** Ubuntu 22.04 LTS
- **Storage:** 30 GB gp3
- **Cost:** ~$40-45/month

### Security Group Configuration
```
Inbound Rules:
- SSH (22) - Your IP only
- HTTP (80) - 0.0.0.0/0
- HTTPS (443) - 0.0.0.0/0
- Custom TCP (8000) - 0.0.0.0/0  # MCP-IDE Backend
- Custom TCP (8001) - 0.0.0.0/0  # Root Backend
- Custom TCP (5174) - 0.0.0.0/0  # MCP-IDE Frontend (for iframe)
```

### Production Architecture
```
Internet → Nginx (Port 80/443)
           ├─→ / → Root Frontend (static files)
           ├─→ /api/ → Root Backend (Port 8001)
           └─→ /mcp-ide/ → MCP-IDE Frontend (static files)

MCP-IDE Frontend (in browser) → http://your-ip:8000 → MCP-IDE Backend
```

---

## 📝 Production Deployment Steps

### 1. Connect to EC2
```bash
ssh -i your-key.pem ubuntu@your-ec2-public-ip
```

### 2. Install Dependencies
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 20
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

### 3. Clone Repository
```bash
cd /home/ubuntu
git clone <your-repo-url> adapted
cd adapted
```

### 4. Setup Root Backend
```bash
cd /home/ubuntu/adapted/backend

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Create .env file (upload or create manually)
nano .env
# Add your API keys

# Create logs directory
mkdir -p logs

# Test
python main.py
# Press Ctrl+C after verification
```

### 5. Setup Root Frontend
```bash
cd /home/ubuntu/adapted/frontend

# Install dependencies
npm install

# Create .env.production
nano .env.production
# Add:
# VITE_API_BASE_URL=http://your-ec2-ip/api
# VITE_FIREBASE_API_KEY=...
# (all Firebase config)

# Build
npm run build
# Output will be in dist/
```

### 6. Setup MCP-IDE Backend
```bash
cd /home/ubuntu/adapted/mcp-ide/backend

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Create .env file
nano .env
# Add your API keys (Gemini, Supabase)

# Create logs directory
mkdir -p logs

# Test
python main.py
# Press Ctrl+C after verification
```

### 7. Setup MCP-IDE Frontend
```bash
cd /home/ubuntu/adapted/mcp-ide/frontend

# Install dependencies
npm install

# Build
npm run build
# Output will be in dist/
```

### 8. Configure PM2 for Backends

**Root Backend PM2 Config:**
```bash
cd /home/ubuntu/adapted/backend

cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'adapted-backend',
    script: 'venv/bin/uvicorn',
    args: 'main:app --host 0.0.0.0 --port 8001',
    cwd: '/home/ubuntu/adapted/backend',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PYTHONUNBUFFERED: '1'
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log'
  }]
};
EOF

pm2 start ecosystem.config.js
```

**MCP-IDE Backend PM2 Config:**
```bash
cd /home/ubuntu/adapted/mcp-ide/backend

cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'mcp-ide-backend',
    script: 'venv/bin/uvicorn',
    args: 'main:app --host 0.0.0.0 --port 8000',
    cwd: '/home/ubuntu/adapted/mcp-ide/backend',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PYTHONUNBUFFERED: '1'
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log'
  }]
};
EOF

pm2 start ecosystem.config.js
```

**Save PM2 Configuration:**
```bash
pm2 save
pm2 startup
# Run the command that PM2 outputs
```

### 9. Configure Nginx
```bash
sudo tee /etc/nginx/sites-available/adapted << 'EOF'
server {
    listen 80;
    server_name _;
    
    client_max_body_size 50M;

    # Root Frontend (Main AdaptEd App)
    location / {
        root /home/ubuntu/adapted/frontend/dist;
        try_files $uri $uri/ /index.html;
        
        gzip on;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    }

    # Root Backend API
    location /api/ {
        proxy_pass http://localhost:8001/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
    }

    # MCP-IDE Frontend (Code Editor)
    location /mcp-ide/ {
        alias /home/ubuntu/adapted/mcp-ide/frontend/dist/;
        try_files $uri $uri/ /mcp-ide/index.html;
        
        gzip on;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    }

    # Health checks
    location /health {
        proxy_pass http://localhost:8001/health;
        access_log off;
    }
}
EOF

# Enable site
sudo ln -s /etc/nginx/sites-available/adapted /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

### 10. Update MCP-IDE Frontend URL

The root frontend's Code Sandbox page needs to point to the MCP-IDE frontend.

Check `frontend/src/pages/CodeSandbox.tsx`:
```typescript
const MCP_IDE_URL = "http://localhost:5174"; // Development
// For production, update to:
// const MCP_IDE_URL = "http://your-ec2-ip:5174";
// OR serve via Nginx:
// const MCP_IDE_URL = "/mcp-ide/";
```

**Option 1: Direct Access (Simpler)**
- MCP-IDE Frontend accessible at `http://your-ec2-ip:5174`
- Update CodeSandbox.tsx to use this URL
- Requires port 5174 open in security group

**Option 2: Via Nginx (Recommended)**
- Serve MCP-IDE Frontend through Nginx at `/mcp-ide/`
- Update CodeSandbox.tsx to use relative URL
- More secure, no additional ports needed

### 11. Verify Deployment
```bash
# Check PM2 status
pm2 status

# Check logs
pm2 logs adapted-backend --lines 50
pm2 logs mcp-ide-backend --lines 50

# Check Nginx
sudo systemctl status nginx

# Test endpoints
curl http://localhost:8001/health  # Root backend
curl http://localhost:8000/health  # MCP-IDE backend (if exists)
```

### 12. Access Application
- Open: `http://your-ec2-public-ip`
- Login/Signup
- Navigate to Code Sandbox
- Verify MCP-IDE loads in iframe
- Test dyslexia mode toggle

---

## 🔄 Updating the Application

```bash
cd /home/ubuntu/adapted

# Pull latest changes
git pull

# Update root backend
cd backend
source venv/bin/activate
pip install -r requirements.txt
pm2 restart adapted-backend

# Update root frontend
cd ../frontend
npm install
npm run build
sudo systemctl restart nginx

# Update MCP-IDE backend
cd ../mcp-ide/backend
source venv/bin/activate
pip install -r requirements.txt
pm2 restart mcp-ide-backend

# Update MCP-IDE frontend
cd ../frontend
npm install
npm run build
sudo systemctl restart nginx
```

---

## 🔍 Testing Checklist

### Root Application
- [ ] Root frontend loads at http://your-ip
- [ ] Login/Signup works
- [ ] Dashboard displays
- [ ] Learning path works
- [ ] Viva voice works
- [ ] API calls to root backend succeed

### MCP-IDE Integration
- [ ] Code Sandbox page loads
- [ ] MCP-IDE iframe loads successfully
- [ ] Can create/edit files in MCP-IDE
- [ ] Code execution works
- [ ] AI tutor responds
- [ ] Files save to Supabase

### Dyslexia Mode
- [ ] Toggle button appears (bottom-right)
- [ ] Font changes when toggled
- [ ] Reading ruler appears
- [ ] Works across all pages

---

## 🆘 Troubleshooting

### Root Backend Issues
```bash
pm2 logs adapted-backend
curl http://localhost:8001/health
```

### Root Frontend Issues
```bash
sudo nginx -t
sudo tail -f /var/log/nginx/error.log
ls -la /home/ubuntu/adapted/frontend/dist
```

### MCP-IDE Backend Issues
```bash
pm2 logs mcp-ide-backend
curl http://localhost:8000/health
```

### MCP-IDE Frontend Not Loading in iframe
- Check browser console for CORS errors
- Verify MCP-IDE frontend is accessible
- Check iframe URL in CodeSandbox.tsx
- Verify security group allows port 5174 (if using direct access)

---

## 📊 Port Summary

| Component | Port | Access |
|-----------|------|--------|
| Root Frontend | 80 (prod) | Public |
| Root Backend | 8001 | Via Nginx /api/ |
| MCP-IDE Frontend | 5174 | Via iframe or Nginx /mcp-ide/ |
| MCP-IDE Backend | 8000 | Direct from MCP-IDE Frontend |

---

## 💰 Cost Estimate

**t3.medium EC2 Instance:**
- Instance: ~$30/month
- Storage: ~$3/month
- Data Transfer: ~$5-10/month
- **Total: ~$40-45/month**

---

## 🔒 Security Recommendations

1. Use SSH keys only (disable password auth)
2. Configure UFW firewall
3. Setup SSL with Let's Encrypt
4. Use environment-specific API keys
5. Regular security updates
6. Monitor logs for suspicious activity
7. Implement rate limiting
8. Use strong passwords for all services

---

## 📞 Support

- Check logs: `pm2 logs`
- Check Nginx: `sudo tail -f /var/log/nginx/error.log`
- Verify services: `pm2 status`
- Test endpoints: `curl http://localhost:PORT/health`
