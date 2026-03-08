# Environment Variables Setup Guide

This guide explains how to set up environment variables for all components of the AdaptEd application.

## 📁 Components Overview

The application consists of 3 main components:

1. **Main Backend** (`backend/`) - AdaptEd API (Port 8001)
2. **Main Frontend** (`frontend/`) - AdaptEd UI (Port 5173 dev, Port 80 prod)
3. **MCP-IDE Backend** (`mcp-ide/backend/`) - Code Editor API (Port 8000)
4. **MCP-IDE Frontend** (`mcp-ide/frontend/`) - Code Editor UI (Port 5174)

## 🔧 Environment Files Needed

### 1. Main Backend: `backend/.env`

```env
# ============================================
# MAIN BACKEND ENVIRONMENT VARIABLES
# ============================================

# Google Gemini API Key (REQUIRED)
# Get from: https://makersuite.google.com/app/apikey
GEMINI_API_KEY=your_gemini_api_key_here
GOOGLE_API_KEY=your_gemini_api_key_here

# YouTube API Key (OPTIONAL - for video search)
# Get from: https://console.cloud.google.com/apis/credentials
YOUTUBE_API_KEY=your_youtube_api_key_here

# OpenAI API Key (REQUIRED for Viva Voice)
# Get from: https://platform.openai.com/api-keys
OPENAI_API_KEY=your_openai_api_key_here

# Groq API Key (REQUIRED for Viva Voice - Whisper transcription)
# Get from: https://console.groq.com/keys
GROQ_API_KEY=your_groq_api_key_here

# Hugging Face API Key (OPTIONAL - for alternative Viva models)
# Get from: https://huggingface.co/settings/tokens
HUGGINGFACE_API_KEY=your_huggingface_api_key_here
```

**How to create:**
```bash
cd backend
cp .env.example .env
nano .env  # Edit with your API keys
```

---

### 2. Main Frontend: `frontend/.env` (Development)

```env
# ============================================
# MAIN FRONTEND - DEVELOPMENT
# ============================================

# Firebase Configuration (REQUIRED)
# Get from: Firebase Console > Project Settings > General
VITE_FIREBASE_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
VITE_FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your-project-id
VITE_FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
VITE_FIREBASE_MESSAGING_SENDER_ID=123456789012
VITE_FIREBASE_APP_ID=1:123456789012:web:abcdef123456

# Backend API URL (Development)
VITE_API_BASE_URL=http://localhost:8001
```

**How to create:**
```bash
cd frontend
cp .env.example .env
nano .env  # Edit with your Firebase credentials
```

---

### 3. Main Frontend: `frontend/.env.production` (Production)

```env
# ============================================
# MAIN FRONTEND - PRODUCTION
# ============================================

# Firebase Configuration (REQUIRED)
VITE_FIREBASE_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
VITE_FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your-project-id
VITE_FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
VITE_FIREBASE_MESSAGING_SENDER_ID=123456789012
VITE_FIREBASE_APP_ID=1:123456789012:web:abcdef123456

# Backend API URL (Production - via Nginx proxy)
VITE_API_BASE_URL=http://your-ec2-public-ip/api
# OR with domain:
# VITE_API_BASE_URL=https://your-domain.com/api
```

**How to create:**
```bash
cd frontend
nano .env.production  # Create and edit
```

---

### 4. MCP-IDE Backend: `mcp-ide/backend/.env`

```env
# ============================================
# MCP-IDE BACKEND ENVIRONMENT VARIABLES
# ============================================

# Ollama Configuration (OPTIONAL - for local AI)
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3

# Gemini Configuration (REQUIRED for AI tutor)
# Get from: https://makersuite.google.com/app/apikey
GEMINI_API_KEY=your_gemini_api_key_here
GEMINI_MODEL=gemini-1.5-flash

# Supabase Configuration (REQUIRED for file storage)
# Get from: Supabase Dashboard > Project Settings > API
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_KEY=your_anon_key_here
SUPABASE_SERVICE_KEY=your_service_role_key_here

# API Configuration
API_HOST=0.0.0.0
API_PORT=8000

# CORS Origins (JSON array format)
# Development
CORS_ORIGINS=["http://localhost:5174","http://localhost:3000","http://localhost:5173"]
# Production (add your domain)
# CORS_ORIGINS=["http://your-ec2-ip","https://your-domain.com"]
```

**How to create:**
```bash
cd mcp-ide/backend
cp .env.example .env
nano .env  # Edit with your API keys
```

---

### 5. MCP-IDE Frontend: No .env file needed

The MCP-IDE frontend currently hardcodes the backend URL to `http://localhost:8000`.

**For production deployment**, you need to update the API URLs in the code or use environment variables.

**Option 1: Create environment variable support (Recommended)**

Create `mcp-ide/frontend/.env`:
```env
VITE_MCP_IDE_API_URL=http://localhost:8000
```

Create `mcp-ide/frontend/.env.production`:
```env
VITE_MCP_IDE_API_URL=http://your-ec2-ip:8000
```

Then update the code to use `import.meta.env.VITE_MCP_IDE_API_URL` instead of hardcoded URLs.

**Option 2: Use Nginx proxy (Simpler)**

Keep the code as-is and configure Nginx to proxy `/mcp-api/` to the MCP-IDE backend.

---

## 🔑 Where to Get API Keys

### 1. Google Gemini API Key
1. Go to: https://makersuite.google.com/app/apikey
2. Click "Create API Key"
3. Copy the key
4. Use for both `GEMINI_API_KEY` in main backend and MCP-IDE backend

### 2. YouTube API Key
1. Go to: https://console.cloud.google.com/apis/credentials
2. Create a new project or select existing
3. Enable "YouTube Data API v3"
4. Create credentials > API Key
5. Copy the key

### 3. OpenAI API Key
1. Go to: https://platform.openai.com/api-keys
2. Click "Create new secret key"
3. Copy the key (you won't see it again!)
4. Required for Viva Voice feature

### 4. Groq API Key
1. Go to: https://console.groq.com/keys
2. Sign up/login
3. Create new API key
4. Copy the key
5. Required for Viva Voice (Whisper transcription)

### 5. Hugging Face API Key
1. Go to: https://huggingface.co/settings/tokens
2. Create new token
3. Copy the token
4. Optional - for alternative Viva models

### 6. Firebase Configuration
1. Go to: https://console.firebase.google.com/
2. Create a new project or select existing
3. Go to Project Settings > General
4. Scroll to "Your apps" section
5. Click "Web" icon to add a web app
6. Copy all the configuration values

### 7. Supabase Configuration
1. Go to: https://supabase.com/dashboard
2. Create a new project
3. Go to Project Settings > API
4. Copy:
   - Project URL → `SUPABASE_URL`
   - anon/public key → `SUPABASE_KEY`
   - service_role key → `SUPABASE_SERVICE_KEY`
5. Run the database schema from `mcp-ide/database/complete_schema.sql`

---

## 📋 Quick Setup Checklist

### Development Setup
- [ ] Create `backend/.env` with API keys
- [ ] Create `frontend/.env` with Firebase config
- [ ] Create `mcp-ide/backend/.env` with Gemini + Supabase
- [ ] Test main backend: `cd backend && python main.py`
- [ ] Test main frontend: `cd frontend && npm run dev`
- [ ] Test MCP-IDE backend: `cd mcp-ide/backend && python main.py`
- [ ] Test MCP-IDE frontend: `cd mcp-ide/frontend && npm run dev`

### Production Setup
- [ ] Create `backend/.env` with API keys
- [ ] Create `frontend/.env.production` with production API URL
- [ ] Create `mcp-ide/backend/.env` with API keys
- [ ] Update MCP-IDE frontend API URLs (if needed)
- [ ] Build frontend: `cd frontend && npm run build`
- [ ] Build MCP-IDE frontend: `cd mcp-ide/frontend && npm run build`
- [ ] Configure Nginx to serve both frontends
- [ ] Start backends with PM2

---

## 🚀 Testing Environment Variables

### Test Main Backend
```bash
cd backend
source venv/bin/activate
python -c "import os; from dotenv import load_dotenv; load_dotenv(); print('GEMINI_API_KEY:', 'SET' if os.getenv('GEMINI_API_KEY') else 'NOT SET')"
```

### Test Main Frontend
```bash
cd frontend
npm run dev
# Check browser console for any API URL errors
```

### Test MCP-IDE Backend
```bash
cd mcp-ide/backend
source venv/bin/activate
python -c "import os; from dotenv import load_dotenv; load_dotenv(); print('GEMINI_API_KEY:', 'SET' if os.getenv('GEMINI_API_KEY') else 'NOT SET')"
```

---

## 🔒 Security Best Practices

1. **Never commit .env files to git**
   - Already in `.gitignore`
   - Double-check before pushing

2. **Use different API keys for dev/prod**
   - Easier to track usage
   - Better security

3. **Rotate keys regularly**
   - Especially if exposed

4. **Use environment-specific Firebase projects**
   - Separate dev and prod databases

5. **Restrict API key permissions**
   - Only enable required APIs
   - Set usage quotas

---

## 📝 Environment Variables Summary

| Component | File | Required Keys | Optional Keys |
|-----------|------|---------------|---------------|
| Main Backend | `backend/.env` | GEMINI_API_KEY, OPENAI_API_KEY, GROQ_API_KEY | YOUTUBE_API_KEY, HUGGINGFACE_API_KEY |
| Main Frontend (Dev) | `frontend/.env` | Firebase config, VITE_API_BASE_URL | - |
| Main Frontend (Prod) | `frontend/.env.production` | Firebase config, VITE_API_BASE_URL | - |
| MCP-IDE Backend | `mcp-ide/backend/.env` | GEMINI_API_KEY, SUPABASE_URL, SUPABASE_KEY | OLLAMA_BASE_URL |
| MCP-IDE Frontend | None (hardcoded) | - | - |

---

## 🆘 Troubleshooting

### "API key not found" error
- Check if .env file exists
- Verify key name matches exactly
- Restart the server after adding keys

### "CORS error" in browser
- Check CORS_ORIGINS in MCP-IDE backend .env
- Add your frontend URL to the array

### "Firebase auth error"
- Verify all Firebase config values
- Check Firebase console for enabled auth methods

### "Supabase connection failed"
- Verify Supabase URL and keys
- Check if database schema is set up
- Verify network connectivity

---

## 📞 Need Help?

- Check the main deployment guide: `AWS_DEPLOYMENT_GUIDE.md`
- Review the quick start: `QUICK_START.md`
- Check component-specific README files
