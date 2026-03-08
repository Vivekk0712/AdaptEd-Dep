No problem at all—let's restart and keep this as your master checklist. Because you have **$100 in credits**, we are using a **t3.medium** instance. This gives you enough RAM (4GB) to handle all four components (2 Backends + 2 Frontends) without the server freezing during builds.

---

## Phase 1: Create the Server (AWS Console)

1. **Login:** Go to the [AWS Console](https://console.aws.amazon.com/) and search for **EC2**.
2. **Launch Instance:** Click the orange **Launch Instance** button.
* **Name:** `AdaptEd-Production`
* **OS:** **Ubuntu 22.04 LTS** (Standard and stable).
* **Instance Type:** Select **t3.medium** (This is important for your credits/RAM balance).


3. **Key Pair:** Click **Create new key pair**. Name it `adapted-key`. Download the `.pem` file and keep it safe.
4. **Network Settings:** Click **Edit** (top right of the network section).
* **Auto-assign Public IP:** Enable.
* **Security Group Rules:** Add these 5 rules:
* **SSH (22):** Source: "My IP" (For you to log in).
* **HTTP (80):** Source: "Anywhere" (For the public to see your website).
* **HTTPS (443):** Source: "Anywhere" (For future SSL).
* **Custom TCP (8000):** Source: "Anywhere" (MCP-IDE Backend).
* **Custom TCP (8001):** Source: "Anywhere" (Root Backend).




5. **Storage:** Change the size from 8GB to **30GB** (to fit all your builds and dependencies).
6. **Launch!**

---

## Phase 2: Connect & Install Dependencies

Open your terminal (on your laptop) and move to the folder where your `.pem` key is.

1. **Login via SSH:**
```bash
chmod 400 adapted-key.pem
ssh -i "adapted-key.pem" ubuntu@YOUR_EC2_PUBLIC_IP

```


2. **Update and Install Software:**
Once you are inside the Ubuntu server, run:
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 20 & Build Tools
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs build-essential

# Install Python 3.11 & Venv
sudo apt install -y python3.11 python3.11-venv python3-pip

# Install Nginx (Web Server) & PM2 (Process Manager)
sudo apt install -y nginx git
sudo npm install -g pm2

```



---

## Phase 3: Deploy the Code

1. **Clone your Repo:**
```bash
cd /home/ubuntu
git clone <your-repo-url> adapted
cd adapted

```


2. **Setup Environment Variables:**
You need to manually create the `.env` files for your backends.
```bash
nano backend/.env         # Paste your Root Backend keys here
nano mcp-ide/backend/.env # Paste your MCP Backend keys here

```



---

## Phase 4: Start the Backends (PM2)

We use PM2 so your Python backends keep running even if you close the terminal.

1. **Root Backend (8001):**
```bash
cd /home/ubuntu/adapted/backend
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pm2 start "python main.py" --name "root-backend"
deactivate

```


2. **MCP-IDE Backend (8000):**
```bash
cd /home/ubuntu/adapted/mcp-ide/backend
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pm2 start "python main.py" --name "mcp-backend"
deactivate

```



---

## Phase 5: Build the Frontends (The "Port 8080" fix)

Instead of "running" the frontends on 8080 or 5174, we "build" them into static files.

1. **Root Frontend:**
```bash
cd /home/ubuntu/adapted/frontend
npm install
npm run build   # This creates the 'dist' folder

```


2. **MCP-IDE Frontend:**
```bash
cd /home/ubuntu/adapted/mcp-ide/frontend
npm install
npm run build   # This creates another 'dist' folder

```



---

## Phase 6: Configure Nginx (The Traffic Cop)

Now we tell Nginx to serve the Root Frontend on Port 80 and route the API calls.

1. **Create the Config:**
`sudo nano /etc/nginx/sites-available/adapted`
2. **Paste this exactly (Replace YOUR_IP with your actual EC2 IP):**
```nginx
server {
    listen 80;
    server_name YOUR_EC2_PUBLIC_IP;

    # 1. Main Root Frontend (The one that was 8080)
    location / {
        root /home/ubuntu/adapted/frontend/dist;
        try_files $uri $uri/ /index.html;
    }

    # 2. MCP-IDE Frontend (Embedded in Iframe)
    location /mcp-ide/ {
        alias /home/ubuntu/adapted/mcp-ide/frontend/dist/;
        try_files $uri $uri/ /mcp-ide/index.html;
    }

    # 3. Root Backend Proxy
    location /api/ {
        proxy_pass http://localhost:8001/;
        proxy_set_header Host $host;
    }
}

```


3. **Enable and Restart:**
```bash
sudo ln -s /etc/nginx/sites-available/adapted /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

```



---

## Phase 7: The Final (Crucial) Step—Elastic IP

AWS changes your IP every time you restart the server. To stop this:

1. In the EC2 Sidebar, go to **Network & Security** > **Elastic IPs**.
2. Click **Allocate Elastic IP address** > **Allocate**.
3. Select the IP > **Actions** > **Associate Elastic IP address**.
4. Choose your **AdaptEd-Production** instance and click **Associate**.

**Your app is now live at `http://YOUR_ELASTIC_IP**`

---

### Summary Checklist

* [ ] AWS Instance running (t3.medium).
* [ ] Ports 80, 8000, 8001 open in Security Group.
* [ ] PM2 shows 2 backends online (`pm2 status`).
* [ ] Nginx is serving the `/dist` folders.
* [ ] Elastic IP is associated.

**Would you like me to help you configure the "Iframe" URL in your React code so it knows to look for the MCP-IDE at your new IP address?**