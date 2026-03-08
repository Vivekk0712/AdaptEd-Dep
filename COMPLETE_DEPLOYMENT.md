# AdaptEd - Complete Deployment Guide (All 4 Services)

This is your **master deployment checklist** for getting AdaptEd running on AWS EC2. We're deploying **4 components** on a single **t3.medium** instance:

1. **Root Backend** (Port 8001) - Learning paths, Viva Voice, AI content
2. **Root Frontend** (Port 80) - Main AdaptEd UI
3. **MCP-IDE Backend** (Port 8000) - Code editor API
4. **MCP-IDE Frontend** (Embedded) - Code editor UI

---

## 🎯 What You're Building

```
Internet → Nginx (Port 80)
           ├─→ / → Root Frontend (static files)
           ├─→ /api/ → Root Backend (Port 8001)
           └─→ /mcp-ide/ → MCP-IDE Frontend (static files)

MCP-IDE Frontend → http://your-ip:8000 → MCP-IDE Backend
```

**Cost:** ~$40-45/month for t3.medium

---

## Phase 1: Create the AWS Server

1. **Login:** Go to [AWS Console](https://console.aws.amazon.com/) → Search **EC2**
2. **Launch Instance:** Click orange **Launch Instance** button
   * **Name:** `AdaptEd-Production`
   * **OS:** **Ubuntu 22.04 LTS**
   * **Instance Type:** **t3.medium** (2 vCPU, 4GB RAM - needed for all 4 services)

3. **Key Pair:** 
   * Click **Create new key pair**
   * Name: `adapted-key`
   * Download `.pem` file and keep it safe

4. **Network Settings:** Click **Edit**
   * **Auto-assign Public IP:** Enable
   * **Security Group Rules:** Add these 6 rules:
     * **SSH (22):** Source: "My IP"
     * **HTTP (80):** Source: "Anywhere"
     * **HTTPS (443):** Source: "Anywhere"
     * **Custom TCP (8000):** Source: "Anywhere" (MCP-IDE Backend)
     * **Custom TCP (8001):** Source: "Anywhere" (Root Backend)
     * **Custom TCP (5174):** Source: "Anywhere" (MCP-IDE Frontend iframe)

5. **Storage:** Change from 8GB to **30GB**
6. **Launch!**

---

## Phase 2: Connect & Install Dependencies

Open terminal on your laptop, navigate to where your `.pem` key is:

```bash
chmod 400 adapted-key.pem
ssh -i "adapted-key.pem" ubuntu@YOUR_EC2_PUBLIC_IP
```

Once inside the Ubuntu server:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs build-essential

# Install Python (3.10+ or 3.12 works fine)
sudo apt install -y python3 python3-venv python3-pip

# Install Nginx & PM2
sudo apt install -y nginx git
sudo npm install -g pm2

# Verify installations
node --version    # Should show v20.x
python3 --version # Should show 3.10+ or 3.12+
pm2 --version
nginx -v
```

---

## Phase 3: Clone & Setup Environment

1. **Clone Repository:**
```bash
cd /home/ubuntu
git clone <your-repo-url> adapted
cd adapted
```

2. **Setup Environment Files:**

Run the setup script:
```bash
bash setup-env.sh
```

Now edit each `.env` file with your API keys:

**Root Backend:**
```bash
nano backend/.env
```
Add:
```env
GEMINI_API_KEY=your_gemini_key
OPENAI_API_KEY=your_openai_key
GROQ_API_KEY=your_groq_key
YOUTUBE_API_KEY=your_youtube_key  # Optional
HUGGINGFACE_API_KEY=your_hf_key   # Optional
```

**Root Frontend (Production):**
```bash
nano frontend/.env.production
```
Add:
```env
VITE_API_BASE_URL=http://YOUR_EC2_IP/api
VITE_FIREBASE_API_KEY=your_firebase_key
VITE_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your_project_id
VITE_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
VITE_FIREBASE_APP_ID=your_app_id
```

**MCP-IDE Backend:**
```bash
nano mcp-ide/backend/.env
```
Add:
```env
GEMINI_API_KEY=your_gemini_key
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_anon_key
CORS_ORIGINS=["http://YOUR_EC2_IP", "http://YOUR_EC2_IP:5174"]
```

3. **Setup Dyslexia Fonts:**
```bash
bash setup-fonts.sh
```

---

## Phase 4: Deploy Root Backend (Port 8001)

```bash
cd /home/ubuntu/adapted/backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Create logs directory
mkdir -p logs

# Test it works
python start.py
# Press Ctrl+C after you see "Application startup complete"

# Create PM2 config
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'adapted-backend',
    script: 'venv/bin/python',
    args: 'start.py',
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

# Start with PM2
pm2 start ecosystem.config.js
deactivate
```

**Verify:** `curl http://localhost:8001/health`

---

## Phase 5: Deploy MCP-IDE Backend (Port 8000)

```bash
cd /home/ubuntu/adapted/mcp-ide/backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Create logs directory
mkdir -p logs

# Test it works
python main.py
# Press Ctrl+C after startup

# Create PM2 config
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'mcp-ide-backend',
    script: 'venv/bin/python',
    args: 'main.py',
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

# Start with PM2
pm2 start ecosystem.config.js
deactivate
```

**Verify:** `curl http://localhost:8000/health`

---

## Phase 6: Build Root Frontend

```bash
cd /home/ubuntu/adapted/frontend

# Install dependencies
npm install

# Build for production
npm run build

# Verify build
ls -la dist/
# Should see index.html, assets/, fonts/
```

---

## Phase 7: Build MCP-IDE Frontend

```bash
cd /home/ubuntu/adapted/mcp-ide/frontend

# Install dependencies
npm install

# Build for production
npm run build

# Verify build
ls -la dist/
# Should see index.html, assets/
```

---

## Phase 8: Configure Nginx (The Traffic Router)

1. **Create Nginx Config:**
```bash
sudo nano /etc/nginx/sites-available/adapted
```

2. **Paste this (Replace YOUR_EC2_IP with your actual IP):**
```nginx
server {
    listen 80;
    server_name YOUR_EC2_IP;
    
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

    # Health check
    location /health {
        proxy_pass http://localhost:8001/health;
        access_log off;
    }
}
```

3. **Enable and Restart:**
```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/adapted /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

---

## Phase 9: Save PM2 Configuration

```bash
# Save current PM2 processes
pm2 save

# Setup PM2 to start on boot
pm2 startup
# Run the command that PM2 outputs (it will be a sudo command)

# Verify both backends are running
pm2 status
# Should show:
# - adapted-backend (online)
# - mcp-ide-backend (online)
```

---

## Phase 10: Allocate Elastic IP (Prevent IP Changes)

AWS changes your IP every time you restart. Fix this:

1. In EC2 Console → **Network & Security** → **Elastic IPs**
2. Click **Allocate Elastic IP address** → **Allocate**
3. Select the new IP → **Actions** → **Associate Elastic IP address**
4. Choose your **AdaptEd-Production** instance → **Associate**

**Your app is now live at:** `http://YOUR_ELASTIC_IP`

---

## Phase 11: Update Frontend URLs (Important!)

Now that you have your Elastic IP, update the frontend to use it:

1. **Update Root Frontend .env.production:**
```bash
nano /home/ubuntu/adapted/frontend/.env.production
```
Change `YOUR_EC2_IP` to your actual Elastic IP.

2. **Update MCP-IDE Backend CORS:**
```bash
nano /home/ubuntu/adapted/mcp-ide/backend/.env
```
Update CORS_ORIGINS with your Elastic IP.

3. **Rebuild Root Frontend:**
```bash
cd /home/ubuntu/adapted/frontend
npm run build
sudo systemctl restart nginx
```

4. **Restart MCP-IDE Backend:**
```bash
pm2 restart mcp-ide-backend
```

---

## ✅ Final Verification Checklist

Run these commands to verify everything:

```bash
# Check PM2 services
pm2 status
# Should show 2 services online

# Check backend health
curl http://localhost:8001/health
curl http://localhost:8000/health

# Check Nginx
sudo systemctl status nginx

# Check logs
pm2 logs adapted-backend --lines 20
pm2 logs mcp-ide-backend --lines 20
```

**Test in Browser:**
1. Open `http://YOUR_ELASTIC_IP`
2. Login/Signup
3. Navigate to Dashboard
4. Go to "Code Sandbox" page
5. MCP-IDE should load in iframe
6. Test dyslexia mode toggle (bottom-right corner)

---

## 🔄 Updating Your Application

When you make changes and want to deploy:

```bash
cd /home/ubuntu/adapted

# Pull latest code
git pull

# Update Root Backend
cd backend
source venv/bin/activate
pip install -r requirements.txt
pm2 restart adapted-backend
deactivate

# Update Root Frontend
cd ../frontend
npm install
npm run build
sudo systemctl restart nginx

# Update MCP-IDE Backend
cd ../mcp-ide/backend
source venv/bin/activate
pip install -r requirements.txt
pm2 restart mcp-ide-backend
deactivate

# Update MCP-IDE Frontend
cd ../frontend
npm install
npm run build
sudo systemctl restart nginx
```

---

## 🆘 Troubleshooting

### Backend Not Starting?
```bash
pm2 logs adapted-backend
pm2 logs mcp-ide-backend
```

### Frontend Not Loading?
```bash
sudo nginx -t
sudo tail -f /var/log/nginx/error.log
```

### MCP-IDE Not Loading in Iframe?
- Check browser console for errors
- Verify port 5174 is open in security group
- Check `frontend/src/pages/CodeSandbox.tsx` iframe URL

### API Calls Failing?
```bash
# Test backends directly
curl http://localhost:8001/health
curl http://localhost:8000/health

# Check environment variables
cd /home/ubuntu/adapted/backend
source venv/bin/activate
python -c "import os; from dotenv import load_dotenv; load_dotenv(); print('Gemini Key:', bool(os.getenv('GEMINI_API_KEY')))"
```

### Dyslexia Fonts Missing?
```bash
ls -la /home/ubuntu/adapted/frontend/dist/fonts/
# If empty, run:
cd /home/ubuntu/adapted
bash setup-fonts.sh
cd frontend
npm run build
sudo systemctl restart nginx
```

---

## 📊 Port Reference

| Component | Port | Access |
|-----------|------|--------|
| Root Frontend | 80 | Public (via Nginx) |
| Root Backend | 8001 | Via Nginx /api/ |
| MCP-IDE Frontend | 5174 | Via iframe or Nginx /mcp-ide/ |
| MCP-IDE Backend | 8000 | Direct from MCP-IDE Frontend |

---

## 🎯 Summary Checklist

- [ ] AWS t3.medium instance running
- [ ] Ports 22, 80, 443, 8000, 8001, 5174 open
- [ ] All 4 .env files created and filled
- [ ] Dyslexia fonts copied
- [ ] PM2 shows 2 backends online
- [ ] Both frontends built (dist/ folders exist)
- [ ] Nginx configured and running
- [ ] Elastic IP allocated and associated
- [ ] Application accessible at http://YOUR_ELASTIC_IP
- [ ] Login/Signup works
- [ ] Code Sandbox loads MCP-IDE
- [ ] Dyslexia mode toggle works

---

## 💰 Monthly Cost Estimate

**t3.medium EC2:**
- Instance: ~$30/month
- Storage (30GB): ~$3/month
- Data Transfer: ~$5-10/month
- **Total: ~$40-45/month**

---

## 🔒 Security Recommendations

1. **Change SSH to key-only:**
```bash
sudo nano /etc/ssh/sshd_config
# Set: PasswordAuthentication no
sudo systemctl restart sshd
```

2. **Setup UFW Firewall:**
```bash
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 8000
sudo ufw allow 8001
sudo ufw allow 5174
sudo ufw enable
```

3. **Setup SSL (Optional but Recommended):**
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

---

## 📞 Quick Commands Reference

```bash
# View all services
pm2 status

# View logs
pm2 logs adapted-backend
pm2 logs mcp-ide-backend

# Restart services
pm2 restart adapted-backend
pm2 restart mcp-ide-backend
pm2 restart all

# Nginx commands
sudo systemctl status nginx
sudo systemctl restart nginx
sudo nginx -t

# Check what's using a port
sudo lsof -i :8000
sudo lsof -i :8001

# Monitor system resources
htop
```

---

**🎉 Congratulations! Your AdaptEd application is now live with all 4 services running!**

**Access your app:** `http://YOUR_ELASTIC_IP`

**Need help?** Check the troubleshooting section above or review the logs with `pm2 logs`.
