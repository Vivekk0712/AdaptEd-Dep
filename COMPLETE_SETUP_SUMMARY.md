# 🎯 Complete Setup Summary - AdaptEd Application

## 📦 What's Included

Your AdaptEd application consists of **4 components**:

### 1. Main Backend (Port 8001)
- **Location:** `backend/`
- **Purpose:** AdaptEd API - handles learning paths, viva voice, AI content generation
- **Tech:** FastAPI, Python 3.11
- **Env File:** `backend/.env`

### 2. Main Frontend (Port 5173 dev / Port 80 prod)
- **Location:** `frontend/`
- **Purpose:** AdaptEd UI - dashboard, learning paths, viva interface
- **Tech:** React, TypeScript, Vite
- **Env Files:** `frontend/.env` (dev), `frontend/.env.production` (prod)
- **New Feature:** ✨ Dyslexia Mode (embedded)

### 3. MCP-IDE Backend (Port 8000)
- **Location:** `mcp-ide/backend/`
- **Purpose:** Code Editor API - file management, code execution, AI tutor
- **Tech:** FastAPI, Python 3.11, Supabase
- **Env File:** `mcp-ide/backend/.env`

### 4. MCP-IDE Frontend (Port 5174)
- **Location:** `mcp-ide/frontend/`
- **Purpose:** Code Editor UI - embedded in main app's Code Sandbox page
- **Tech:** React, TypeScript, Vite
- **Env File:** None (hardcoded URLs)

---

## 🔧 Environment Variables Required

### Quick Setup (Recommended)
```bash
# 1. Create all .env files from templates
bash setup-env.sh

# 2. Edit each file with your API keys
nano backend/.env
nano frontend/.env
nano frontend/.env.production
nano mcp-ide/backend/.env
```

### API Keys You Need

| Service | Required For | Get From | Used In |
|---------|-------------|----------|---------|
| **Gemini API** | AI content generation, AI tutor | [Google AI Studio](https://makersuite.google.com/app/apikey) | Main Backend, MCP-IDE Backend |
| **OpenAI API** | Viva Voice (GPT-4) | [OpenAI Platform](https://platform.openai.com/api-keys) | Main Backend |
| **Groq API** | Viva Voice (Whisper) | [Groq Console](https://console.groq.com/keys) | Main Backend |
| **Firebase** | User authentication | [Firebase Console](https://console.firebase.google.com/) | Main Frontend |
| **Supabase** | File storage for IDE | [Supabase Dashboard](https://supabase.com/dashboard) | MCP-IDE Backend |
| YouTube API | Video search (optional) | [Google Cloud Console](https://console.cloud.google.com/) | Main Backend |
| Hugging Face | Alternative AI (optional) | [HF Settings](https://huggingface.co/settings/tokens) | Main Backend |

📚 **Detailed instructions:** See `ENV_SETUP_GUIDE.md`

---

## 🚀 Local Development Setup

### Step 1: Setup Environment Files
```bash
bash setup-env.sh
# Then edit each .env file with your API keys
```

### Step 2: Setup Dyslexia Fonts
```bash
bash setup-fonts.sh
```

### Step 3: Start Main Backend
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python main.py
# Should start on http://localhost:8001
```

### Step 4: Start Main Frontend (New Terminal)
```bash
cd frontend
npm install
npm run dev
# Should start on http://localhost:5173
```

### Step 5: Start MCP-IDE Backend (New Terminal)
```bash
cd mcp-ide/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python main.py
# Should start on http://localhost:8000
```

### Step 6: Start MCP-IDE Frontend (New Terminal)
```bash
cd mcp-ide/frontend
npm install
npm run dev
# Should start on http://localhost:5174
```

### Step 7: Test Everything
- Main App: http://localhost:5173
- MCP-IDE: http://localhost:5174
- Dyslexia Toggle: Look for purple button (bottom-right)

---

## ☁️ AWS EC2 Production Deployment

### Architecture
```
Internet
   ↓
Nginx (Port 80/443)
   ├─→ Main Frontend (Static files)
   ├─→ /api/* → Main Backend (Port 8001)
   └─→ /mcp-api/* → MCP-IDE Backend (Port 8000)
        └─→ MCP-IDE Frontend (Static files)
```

### Quick Deployment
```bash
# On EC2 instance
cd /home/ubuntu
git clone <your-repo> adapted
cd adapted

# Setup environment files
bash setup-env.sh
# Edit each .env file with production values

# Setup fonts
bash setup-fonts.sh

# Deploy everything
bash deploy.sh
```

### Detailed Steps
See `AWS_DEPLOYMENT_GUIDE.md` for complete instructions.

---

## 🎨 Dyslexia Mode Feature

### What It Does
- ✅ OpenDyslexic font (designed for dyslexic readers)
- ✅ 2x line spacing
- ✅ Increased letter spacing (0.15em)
- ✅ Increased word spacing (0.3em)
- ✅ Yellow reading ruler that follows mouse
- ✅ Persistent state (saved in localStorage)
- ✅ Works across all pages

### How to Use
1. Look for purple gradient button in bottom-right corner
2. Click "Dyslexia Mode" toggle
3. Font changes, ruler appears
4. Toggle off to return to normal

### Files Added
- `frontend/src/contexts/DyslexiaContext.tsx`
- `frontend/src/components/DyslexiaToggle.tsx`
- `frontend/src/components/ReadingRuler.tsx`
- `frontend/src/styles/dyslexia.css`
- `frontend/public/fonts/` (OpenDyslexic fonts)

---

## 📁 Project Structure

```
adapted/
├── backend/                          # Main Backend (Port 8001)
│   ├── main.py
│   ├── requirements.txt
│   ├── .env                         # ← CREATE THIS
│   ├── .env.template                # ← COPY FROM THIS
│   └── ecosystem.config.js          # PM2 config
│
├── frontend/                         # Main Frontend
│   ├── src/
│   │   ├── App.tsx                  # ← Updated with dyslexia
│   │   ├── contexts/
│   │   │   ├── AuthContext.tsx
│   │   │   └── DyslexiaContext.tsx  # ← NEW
│   │   ├── components/
│   │   │   ├── DyslexiaToggle.tsx   # ← NEW
│   │   │   └── ReadingRuler.tsx     # ← NEW
│   │   └── styles/
│   │       └── dyslexia.css         # ← NEW
│   ├── public/
│   │   └── fonts/                   # ← Copy fonts here
│   ├── .env                         # ← CREATE THIS (dev)
│   ├── .env.production              # ← CREATE THIS (prod)
│   ├── .env.template                # ← COPY FROM THIS
│   └── package.json
│
├── mcp-ide/
│   ├── backend/                     # MCP-IDE Backend (Port 8000)
│   │   ├── main.py
│   │   ├── requirements.txt
│   │   ├── .env                     # ← CREATE THIS
│   │   └── .env.template            # ← COPY FROM THIS
│   │
│   └── frontend/                    # MCP-IDE Frontend (Port 5174)
│       ├── src/
│       └── package.json
│
├── dyslexia mode/                   # Original Chrome extension
│   └── fonts/                       # ← Source fonts
│
├── nginx.conf                       # Nginx configuration
├── deploy.sh                        # Deployment script
├── setup-env.sh                     # Environment setup script
├── setup-fonts.sh                   # Font setup script
│
├── ENV_SETUP_GUIDE.md              # ← Detailed env guide
├── AWS_DEPLOYMENT_GUIDE.md         # ← Deployment guide
├── DEPLOYMENT_CHECKLIST.md         # ← Deployment checklist
├── DEPLOYMENT_SUMMARY.md           # ← Feature summary
├── QUICK_START.md                  # ← Quick start guide
└── COMPLETE_SETUP_SUMMARY.md       # ← This file
```

---

## ✅ Pre-Deployment Checklist

### Local Development
- [ ] Run `bash setup-env.sh`
- [ ] Edit `backend/.env` with API keys
- [ ] Edit `frontend/.env` with Firebase config
- [ ] Edit `mcp-ide/backend/.env` with Gemini + Supabase
- [ ] Run `bash setup-fonts.sh`
- [ ] Test main backend: `cd backend && python main.py`
- [ ] Test main frontend: `cd frontend && npm run dev`
- [ ] Test MCP-IDE backend: `cd mcp-ide/backend && python main.py`
- [ ] Test MCP-IDE frontend: `cd mcp-ide/frontend && npm run dev`
- [ ] Test dyslexia mode toggle

### Production Deployment
- [ ] Create `frontend/.env.production` with production API URL
- [ ] Update CORS_ORIGINS in `mcp-ide/backend/.env`
- [ ] Launch EC2 instance (t3.medium, Ubuntu 22.04)
- [ ] Configure security groups (ports 22, 80, 443, 8000, 8001)
- [ ] Clone repository to EC2
- [ ] Copy .env files to EC2
- [ ] Run `bash setup-fonts.sh` on EC2
- [ ] Build frontend: `npm run build`
- [ ] Build MCP-IDE frontend: `npm run build`
- [ ] Configure PM2 for both backends
- [ ] Configure Nginx
- [ ] Test all endpoints
- [ ] Test dyslexia mode in production
- [ ] Setup SSL (optional)

---

## 🔍 Testing Checklist

### Main Application
- [ ] Login/Signup works
- [ ] Dashboard loads
- [ ] Learning path displays
- [ ] Can click on modules
- [ ] Viva voice works
- [ ] API calls succeed

### MCP-IDE
- [ ] Code editor loads
- [ ] Can create files
- [ ] Can edit code
- [ ] Code execution works
- [ ] AI tutor responds
- [ ] Files save to Supabase

### Dyslexia Mode
- [ ] Toggle button appears (bottom-right)
- [ ] Clicking toggle changes font
- [ ] Line spacing increases
- [ ] Reading ruler appears
- [ ] Ruler follows mouse
- [ ] Toggle off returns to normal
- [ ] State persists on page reload

---

## 📊 Port Reference

| Component | Port | URL (Dev) | URL (Prod) |
|-----------|------|-----------|------------|
| Main Backend | 8001 | http://localhost:8001 | http://your-ip/api |
| Main Frontend | 5173 | http://localhost:5173 | http://your-ip |
| MCP-IDE Backend | 8000 | http://localhost:8000 | http://your-ip:8000 |
| MCP-IDE Frontend | 5174 | http://localhost:5174 | Embedded in main app |

---

## 💰 Cost Estimation

**AWS EC2 t3.medium (monthly):**
- EC2 Instance: ~$30
- Storage (30 GB): ~$3
- Data Transfer: ~$5-10
- **Total: ~$40-45/month**

---

## 🆘 Quick Troubleshooting

### Backend not starting?
```bash
# Check logs
pm2 logs adapted-backend
pm2 logs mcp-ide-backend

# Check if ports are in use
sudo lsof -i :8000
sudo lsof -i :8001
```

### Frontend not loading?
```bash
# Check Nginx
sudo nginx -t
sudo tail -f /var/log/nginx/error.log

# Check if build exists
ls -la frontend/dist
ls -la mcp-ide/frontend/dist
```

### Dyslexia mode not working?
```bash
# Check if fonts exist
ls -la frontend/dist/fonts/

# If missing, run:
bash setup-fonts.sh
cd frontend && npm run build
```

### API calls failing?
```bash
# Test backends directly
curl http://localhost:8001/health
curl http://localhost:8000/health

# Check environment variables
cd backend && source venv/bin/activate
python -c "import os; from dotenv import load_dotenv; load_dotenv(); print('Keys loaded:', bool(os.getenv('GEMINI_API_KEY')))"
```

---

## 📚 Documentation Index

1. **ENV_SETUP_GUIDE.md** - Complete guide to setting up all environment variables
2. **QUICK_START.md** - 5-minute quick start for local development
3. **AWS_DEPLOYMENT_GUIDE.md** - Step-by-step AWS EC2 deployment
4. **DEPLOYMENT_CHECKLIST.md** - Interactive deployment checklist
5. **DEPLOYMENT_SUMMARY.md** - Overview of deployment features
6. **COMPLETE_SETUP_SUMMARY.md** - This file (complete overview)

---

## 🎉 You're Ready!

Your AdaptEd application is now fully configured with:
- ✅ AI-powered learning platform
- ✅ Voice-based viva examinations
- ✅ Integrated code editor (MCP-IDE)
- ✅ Dyslexia mode (embedded)
- ✅ Production-ready deployment configuration
- ✅ Comprehensive documentation

**Next Steps:**
1. Run `bash setup-env.sh` to create environment files
2. Fill in your API keys
3. Run `bash setup-fonts.sh` to copy dyslexia fonts
4. Start local development or deploy to AWS

**Need Help?**
- Check the documentation files listed above
- Review the troubleshooting sections
- Verify all environment variables are set correctly

---

**Status:** ✅ Ready for Development and Deployment

**Last Updated:** 2026-03-08
