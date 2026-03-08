# MCP-IDE Deployment Steps

After pushing the code changes, follow these steps on your EC2 server:

## 1. Pull Latest Code

```bash
cd /home/ubuntu/adapted
git pull
```

## 2. Create MCP-IDE Frontend .env.production

```bash
nano mcp-ide/frontend/.env.production
```

Add:
```env
VITE_API_URL=http://34.235.200.248:8000
```

Save and exit (Ctrl+X, Y, Enter).

## 3. Build MCP-IDE Frontend

```bash
cd /home/ubuntu/adapted/mcp-ide/frontend
npm install
npm run build
```

## 4. Deploy MCP-IDE Frontend via Nginx

```bash
# Copy to nginx location
sudo mkdir -p /var/www/mcp-ide
sudo cp -r /home/ubuntu/adapted/mcp-ide/frontend/dist/* /var/www/mcp-ide/
sudo chown -R www-data:www-data /var/www/mcp-ide
sudo chmod -R 755 /var/www/mcp-ide

# Restart nginx
sudo systemctl restart nginx
```

## 5. Update Main Frontend Environment

```bash
nano /home/ubuntu/adapted/frontend/.env.production
```

Make sure it has:
```env
VITE_API_BASE_URL=http://34.235.200.248/api
VITE_API_URL=http://34.235.200.248
VITE_MCP_IDE_URL=http://34.235.200.248/mcp-ide
VITE_FIREBASE_API_KEY=your_key
VITE_FIREBASE_AUTH_DOMAIN=your_domain
VITE_FIREBASE_PROJECT_ID=your_project
VITE_FIREBASE_STORAGE_BUCKET=your_bucket
VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender
VITE_FIREBASE_APP_ID=your_app_id
```

## 6. Rebuild Main Frontend

```bash
cd /home/ubuntu/adapted/frontend
npm run build
sudo systemctl restart nginx
```

## 7. Test Everything

```bash
# Check PM2 status
pm2 status

# Test backends
curl http://localhost:8001/health
curl http://localhost:8000/health

# Test frontends
curl http://localhost/ | head -20
curl http://localhost/mcp-ide/ | head -20
```

## 8. Open in Browser

Visit: http://34.235.200.248

- Login
- Go to Code Sandbox
- MCP-IDE should now load properly!

---

## Troubleshooting

### MCP-IDE shows main frontend
```bash
# Check what's in /var/www/mcp-ide
ls -la /var/www/mcp-ide/
head -20 /var/www/mcp-ide/index.html

# Should see MCP-IDE content, not main frontend
```

### API calls failing
```bash
# Check browser console (F12)
# Look for CORS errors or 404s
# Verify VITE_API_URL is set correctly
```

### Still showing localhost
```bash
# Make sure you pulled latest code
cd /home/ubuntu/adapted
git log --oneline -5

# Should see commit about "Fix: Replace hardcoded localhost URLs"
```
