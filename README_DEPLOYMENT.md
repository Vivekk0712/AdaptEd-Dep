# AdaptEd - Deployment README

## 🎯 Quick Overview

AdaptEd is an AI-powered learning platform with 4 independent services:

```
┌─────────────────────────────────────────────────────────┐
│  Root Frontend (Port 5173/80)                           │
│  ├─ Dashboard, Learning Path, Viva                      │
│  └─ Code Sandbox page embeds MCP-IDE via iframe         │
└─────────────────────────────────────────────────────────┘
         │                                    │
         ↓                                    ↓
┌──────────────────┐              ┌──────────────────────┐
│  Root Backend    │              │  MCP-IDE Frontend    │
│  (Port 8001)     │              │  (Port 5174)         │
└──────────────────┘              └──────────────────────┘
                                           │
                                           ↓
                                  ┌──────────────────────┐
                                  │  MCP-IDE Backend     │
                                  │  (Port 8000)         │
                                  └──────────────────────┘
```

## 🚀 Quick Start (Local Development)

```bash
# 1. Setup
bash setup-env.sh      # Create .env files
bash setup-fonts.sh    # Copy dyslexia fonts

# 2. Start all services (4 terminals)
cd backend && python main.py                    # Terminal 1: Root Backend
cd frontend && npm run dev                      # Terminal 2: Root Frontend
cd mcp-ide/backend && python main.py           # Terminal 3: MCP-IDE Backend
cd mcp-ide/frontend && npm run dev             # Terminal 4: MCP-IDE Frontend

# 3. Test
# Open http://localhost:5173
# Go to Code Sandbox page
# Verify MCP-IDE loads in iframe

# 4. Test builds before deployment
bash test-build.sh
```

## ✅ Pre-Deployment Checklist

**Must do before deploying:**

1. ✅ Run `bash test-build.sh` - all tests pass
2. ✅ Both frontends build successfully
3. ✅ All .env files have real API keys (not templates)
4. ✅ Dyslexia fonts copied to `frontend/public/fonts/`
5. ✅ Test all 4 services locally
6. ✅ Verify MCP-IDE loads in Code Sandbox page

## 📦 What Gets Built

### Root Frontend (`frontend/`)
```bash
cd frontend
npm run build
# Output: frontend/dist/
# ├── index.html
# ├── assets/
# └── fonts/  ← Dyslexia fonts (MUST exist)
```

### MCP-IDE Frontend (`mcp-ide/frontend/`)
```bash
cd mcp-ide/frontend
npm run build
# Output: mcp-ide/frontend/dist/
# ├── index.html
# └── assets/
```

## 🔑 Required API Keys

| Service | Required | Get From |
|---------|----------|----------|
| Gemini API | ✅ Yes | https://makersuite.google.com/app/apikey |
| OpenAI API | ✅ Yes | https://platform.openai.com/api-keys |
| Groq API | ✅ Yes | https://console.groq.com/keys |
| Firebase | ✅ Yes | https://console.firebase.google.com/ |
| Supabase | ✅ Yes | https://supabase.com/dashboard |
| YouTube API | ⚪ Optional | https://console.cloud.google.com/ |
| Hugging Face | ⚪ Optional | https://huggingface.co/settings/tokens |

## 📝 Environment Files Needed

```
backend/.env                    ← Root backend API keys
frontend/.env                   ← Root frontend (dev)
frontend/.env.production        ← Root frontend (prod)
mcp-ide/backend/.env           ← MCP-IDE backend API keys
```

## ☁️ AWS Deployment

### Instance Requirements
- **Type:** t3.medium (2 vCPU, 4 GB RAM)
- **OS:** Ubuntu 22.04 LTS
- **Storage:** 30 GB
- **Ports:** 22, 80, 443, 8000, 8001, 5174
- **Cost:** ~$40-45/month

### Quick Deploy
```bash
# On EC2
git clone <repo> adapted
cd adapted
bash setup-env.sh  # Then edit .env files
bash setup-fonts.sh
bash test-build.sh  # Verify builds work

# Deploy (see DEPLOYMENT_GUIDE.md for details)
# - Start both backends with PM2
# - Build both frontends
# - Configure Nginx
```

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| **QUICK_START.md** | 5-minute quick start guide |
| **DEPLOYMENT_GUIDE.md** | Complete deployment instructions |
| **ENV_SETUP_GUIDE.md** | Environment variables guide |
| **test-build.sh** | Pre-deployment build test |
| **setup-env.sh** | Create .env files from templates |
| **setup-fonts.sh** | Copy dyslexia fonts |

## 🎨 Features

- ✅ AI-powered learning paths
- ✅ Voice-based viva examinations
- ✅ Integrated code editor (MCP-IDE)
- ✅ **Dyslexia mode** (OpenDyslexic font + reading ruler)
- ✅ Real-time code execution
- ✅ AI tutor for coding help
- ✅ Progress tracking

## 🧪 Testing

### Test Builds
```bash
bash test-build.sh
```

### Test Individual Services
```bash
# Root backend
cd backend && python main.py

# Root frontend
cd frontend && npm run dev

# MCP-IDE backend
cd mcp-ide/backend && python main.py

# MCP-IDE frontend
cd mcp-ide/frontend && npm run dev
```

### Test Production Builds
```bash
# Root frontend
cd frontend && npm run build
ls -la dist/  # Check output
ls -la dist/fonts/  # Check dyslexia fonts

# MCP-IDE frontend
cd mcp-ide/frontend && npm run build
ls -la dist/  # Check output
```

## 🆘 Common Issues

### Build fails
```bash
# Check for errors
bash test-build.sh

# Check logs
cat /tmp/frontend-build.log
cat /tmp/mcp-ide-build.log
```

### Dyslexia mode not working
```bash
# Verify fonts exist
ls -la frontend/public/fonts/
ls -la frontend/dist/fonts/

# If missing, run:
bash setup-fonts.sh
cd frontend && npm run build
```

### MCP-IDE not loading in iframe
- Check browser console for errors
- Verify MCP-IDE frontend is running (port 5174)
- Check CORS settings
- Verify iframe URL in CodeSandbox.tsx

## 📊 Port Reference

| Service | Dev Port | Prod Port | Access |
|---------|----------|-----------|--------|
| Root Frontend | 5173 | 80 | Public |
| Root Backend | 8001 | 8001 | Via Nginx /api/ |
| MCP-IDE Frontend | 5174 | 5174 | Via iframe |
| MCP-IDE Backend | 8000 | 8000 | From MCP-IDE Frontend |

## 🎯 Deployment Flow

```
1. Local Development
   ├─ bash setup-env.sh
   ├─ bash setup-fonts.sh
   ├─ Start all 4 services
   └─ Test everything works

2. Pre-Deployment Testing
   ├─ bash test-build.sh
   ├─ Fix any errors
   └─ Verify all builds succeed

3. AWS Deployment
   ├─ Launch EC2 instance
   ├─ Install dependencies
   ├─ Clone repository
   ├─ Copy .env files
   ├─ Build frontends
   ├─ Start backends with PM2
   └─ Configure Nginx

4. Post-Deployment
   ├─ Test all endpoints
   ├─ Verify MCP-IDE loads
   ├─ Test dyslexia mode
   └─ Monitor logs
```

## 💡 Pro Tips

1. **Always run `bash test-build.sh` before deploying**
2. **Check that dyslexia fonts exist in `frontend/dist/fonts/`**
3. **Test MCP-IDE iframe loading locally first**
4. **Keep .env files secure (never commit to git)**
5. **Monitor PM2 logs after deployment**
6. **Use different API keys for dev/prod**

## 🔗 Quick Links

- **Start Here:** QUICK_START.md
- **Full Guide:** DEPLOYMENT_GUIDE.md
- **Environment Setup:** ENV_SETUP_GUIDE.md
- **Test Builds:** `bash test-build.sh`

---

**Ready to deploy?** Start with `QUICK_START.md` → Test with `bash test-build.sh` → Deploy with `DEPLOYMENT_GUIDE.md`
