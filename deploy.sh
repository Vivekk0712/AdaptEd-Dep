#!/bin/bash

# AdaptEd Deployment Script for AWS EC2
# This script automates the deployment process

set -e  # Exit on error

echo "🚀 Starting AdaptEd Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    print_error "Please do not run as root"
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

print_info "Deployment directory: $SCRIPT_DIR"

# Step 1: Pull latest changes
print_info "Pulling latest changes from git..."
git pull origin main || git pull origin master
print_success "Code updated"

# Step 2: Deploy Backend
print_info "Deploying backend..."
cd backend

# Activate virtual environment
if [ ! -d "venv" ]; then
    print_info "Creating virtual environment..."
    python3.11 -m venv venv
fi

source venv/bin/activate

# Install/update dependencies
print_info "Installing backend dependencies..."
pip install --upgrade pip
pip install -r requirements.txt
print_success "Backend dependencies installed"

# Check if .env exists
if [ ! -f ".env" ]; then
    print_error ".env file not found in backend directory"
    print_info "Please create .env file with required API keys"
    exit 1
fi

# Create logs directory
mkdir -p logs

# Restart backend with PM2
print_info "Restarting backend service..."
if pm2 list | grep -q "adapted-backend"; then
    pm2 restart adapted-backend
else
    pm2 start ecosystem.config.js
fi
pm2 save
print_success "Backend deployed and running"

# Step 3: Deploy Frontend
print_info "Deploying frontend..."
cd ../frontend

# Check if .env.production exists
if [ ! -f ".env.production" ]; then
    print_error ".env.production file not found in frontend directory"
    print_info "Please create .env.production file with required configuration"
    exit 1
fi

# Install/update dependencies
print_info "Installing frontend dependencies..."
npm install
print_success "Frontend dependencies installed"

# Build frontend
print_info "Building frontend for production..."
npm run build
print_success "Frontend built successfully"

# Step 4: Restart Nginx
print_info "Restarting Nginx..."
sudo systemctl restart nginx
print_success "Nginx restarted"

# Step 5: Show status
echo ""
print_success "🎉 Deployment completed successfully!"
echo ""
print_info "Service Status:"
pm2 status
echo ""
print_info "Nginx Status:"
sudo systemctl status nginx --no-pager -l
echo ""
print_info "View logs with:"
echo "  Backend: pm2 logs adapted-backend"
echo "  Nginx: sudo tail -f /var/log/nginx/error.log"
echo ""
print_success "Application is now running!"
