#!/bin/bash

# AdaptEd Environment Setup Script
# This script helps you create .env files from templates

set -e

echo "🔧 AdaptEd Environment Setup"
echo "=============================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to copy template if .env doesn't exist
setup_env_file() {
    local template=$1
    local target=$2
    local description=$3
    
    if [ -f "$target" ]; then
        echo -e "${YELLOW}⚠ $target already exists, skipping...${NC}"
    else
        if [ -f "$template" ]; then
            cp "$template" "$target"
            echo -e "${GREEN}✓ Created $target${NC}"
            echo -e "  ${YELLOW}→ Please edit $target and add your API keys${NC}"
        else
            echo -e "${RED}✗ Template $template not found${NC}"
        fi
    fi
}

echo "Setting up environment files..."
echo ""

# 1. Main Backend
echo "1️⃣  Main Backend (backend/.env)"
setup_env_file "backend/.env.template" "backend/.env" "Main AdaptEd API"
echo ""

# 2. Main Frontend - Development
echo "2️⃣  Main Frontend - Development (frontend/.env)"
setup_env_file "frontend/.env.template" "frontend/.env" "Main AdaptEd UI (Dev)"
echo ""

# 3. Main Frontend - Production
echo "3️⃣  Main Frontend - Production (frontend/.env.production)"
setup_env_file "frontend/.env.production.template" "frontend/.env.production" "Main AdaptEd UI (Prod)"
echo ""

# 4. MCP-IDE Backend
echo "4️⃣  MCP-IDE Backend (mcp-ide/backend/.env)"
setup_env_file "mcp-ide/backend/.env.template" "mcp-ide/backend/.env" "Code Editor API"
echo ""

echo "=============================="
echo -e "${GREEN}✅ Environment setup complete!${NC}"
echo ""
echo "📝 Next steps:"
echo "   1. Edit backend/.env and add your API keys"
echo "   2. Edit frontend/.env and add your Firebase config"
echo "   3. Edit frontend/.env.production for production deployment"
echo "   4. Edit mcp-ide/backend/.env and add Gemini + Supabase keys"
echo ""
echo "📚 For detailed instructions, see: ENV_SETUP_GUIDE.md"
echo ""
echo "🔑 Where to get API keys:"
echo "   • Gemini: https://makersuite.google.com/app/apikey"
echo "   • OpenAI: https://platform.openai.com/api-keys"
echo "   • Groq: https://console.groq.com/keys"
echo "   • Firebase: https://console.firebase.google.com/"
echo "   • Supabase: https://supabase.com/dashboard"
echo ""
