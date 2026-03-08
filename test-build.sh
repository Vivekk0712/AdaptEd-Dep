#!/bin/bash

# Pre-Deployment Build Test Script
# Tests all builds before deploying to production

set -e  # Exit on error

echo "🧪 AdaptEd - Pre-Deployment Build Test"
echo "========================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Track failures
FAILURES=0

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    FAILURES=$((FAILURES + 1))
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "Testing directory: $SCRIPT_DIR"
echo ""

# ============================================
# 1. Check Environment Files
# ============================================
echo "1️⃣  Checking Environment Files..."
echo "-----------------------------------"

check_env_file() {
    local file=$1
    local description=$2
    
    if [ -f "$file" ]; then
        print_success "$description exists"
        
        # Check if file has content (not just empty or template)
        if grep -q "your_.*_here" "$file" 2>/dev/null; then
            print_warning "$description contains template values - update before deployment!"
        fi
    else
        print_error "$description missing - run 'bash setup-env.sh'"
    fi
}

check_env_file "backend/.env" "Root Backend .env"
check_env_file "frontend/.env" "Root Frontend .env (dev)"
check_env_file "frontend/.env.production" "Root Frontend .env.production"
check_env_file "mcp-ide/backend/.env" "MCP-IDE Backend .env"

echo ""

# ============================================
# 2. Check Dyslexia Fonts
# ============================================
echo "2️⃣  Checking Dyslexia Fonts..."
echo "-----------------------------------"

if [ -f "frontend/public/fonts/OpenDyslexic-Regular.otf" ]; then
    print_success "Dyslexia fonts are present"
else
    print_error "Dyslexia fonts missing - run 'bash setup-fonts.sh'"
fi

echo ""

# ============================================
# 3. Test Root Backend
# ============================================
echo "3️⃣  Testing Root Backend..."
echo "-----------------------------------"

cd backend

if [ ! -d "venv" ]; then
    print_info "Creating virtual environment..."
    python3 -m venv venv
fi

print_info "Activating virtual environment..."
source venv/bin/activate

print_info "Checking dependencies..."
if pip install -r requirements.txt --quiet; then
    print_success "Root Backend dependencies OK"
else
    print_error "Root Backend dependencies failed"
fi

print_info "Checking Python syntax..."
if python -m py_compile main.py 2>/dev/null; then
    print_success "Root Backend syntax OK"
else
    print_error "Root Backend has syntax errors"
fi

deactivate
cd ..

echo ""

# ============================================
# 4. Test Root Frontend Build
# ============================================
echo "4️⃣  Testing Root Frontend Build..."
echo "-----------------------------------"

cd frontend

print_info "Installing dependencies..."
if npm install --silent 2>&1 | grep -i "error" > /dev/null; then
    print_error "Root Frontend npm install failed"
else
    print_success "Root Frontend dependencies installed"
fi

print_info "Running TypeScript check..."
if npx tsc --noEmit 2>&1 | grep -i "error" > /dev/null; then
    print_warning "Root Frontend has TypeScript errors (may still build)"
else
    print_success "Root Frontend TypeScript OK"
fi

print_info "Building for production..."
if npm run build 2>&1 | tee /tmp/frontend-build.log | grep -i "error" > /dev/null; then
    print_error "Root Frontend build failed"
    echo "Check /tmp/frontend-build.log for details"
else
    print_success "Root Frontend build successful"
    
    # Check if dist folder was created
    if [ -d "dist" ]; then
        DIST_SIZE=$(du -sh dist | cut -f1)
        print_info "Build output: dist/ ($DIST_SIZE)"
        
        # Check for index.html
        if [ -f "dist/index.html" ]; then
            print_success "dist/index.html exists"
        else
            print_error "dist/index.html missing"
        fi
        
        # Check for assets
        if [ -d "dist/assets" ]; then
            print_success "dist/assets/ exists"
        else
            print_warning "dist/assets/ missing"
        fi
        
        # Check for fonts
        if [ -d "dist/fonts" ]; then
            print_success "dist/fonts/ exists (dyslexia fonts)"
        else
            print_error "dist/fonts/ missing - dyslexia mode won't work!"
        fi
    else
        print_error "dist/ folder not created"
    fi
fi

cd ..

echo ""

# ============================================
# 5. Test MCP-IDE Backend
# ============================================
echo "5️⃣  Testing MCP-IDE Backend..."
echo "-----------------------------------"

cd mcp-ide/backend

if [ ! -d "venv" ]; then
    print_info "Creating virtual environment..."
    python3 -m venv venv
fi

print_info "Activating virtual environment..."
source venv/bin/activate

print_info "Checking dependencies..."
if pip install -r requirements.txt --quiet; then
    print_success "MCP-IDE Backend dependencies OK"
else
    print_error "MCP-IDE Backend dependencies failed"
fi

print_info "Checking Python syntax..."
if python -m py_compile main.py 2>/dev/null; then
    print_success "MCP-IDE Backend syntax OK"
else
    print_error "MCP-IDE Backend has syntax errors"
fi

deactivate
cd ../..

echo ""

# ============================================
# 6. Test MCP-IDE Frontend Build
# ============================================
echo "6️⃣  Testing MCP-IDE Frontend Build..."
echo "-----------------------------------"

cd mcp-ide/frontend

print_info "Installing dependencies..."
if npm install --silent 2>&1 | grep -i "error" > /dev/null; then
    print_error "MCP-IDE Frontend npm install failed"
else
    print_success "MCP-IDE Frontend dependencies installed"
fi

print_info "Running TypeScript check..."
if npx tsc --noEmit 2>&1 | tee /tmp/mcp-ide-tsc.log | grep -i "error TS" > /dev/null; then
    print_error "MCP-IDE Frontend has TypeScript errors"
    echo "Check /tmp/mcp-ide-tsc.log for details"
else
    print_success "MCP-IDE Frontend TypeScript OK"
fi

print_info "Building for production..."
if npm run build 2>&1 | tee /tmp/mcp-ide-build.log; then
    if grep -i "error" /tmp/mcp-ide-build.log | grep -v "error TS6133" > /dev/null; then
        print_error "MCP-IDE Frontend build failed"
        echo "Check /tmp/mcp-ide-build.log for details"
    else
        print_success "MCP-IDE Frontend build successful"
        
        # Check if dist folder was created
        if [ -d "dist" ]; then
            DIST_SIZE=$(du -sh dist | cut -f1)
            print_info "Build output: dist/ ($DIST_SIZE)"
            
            # Check for index.html
            if [ -f "dist/index.html" ]; then
                print_success "dist/index.html exists"
            else
                print_error "dist/index.html missing"
            fi
        else
            print_error "dist/ folder not created"
        fi
    fi
else
    print_error "MCP-IDE Frontend build command failed"
fi

cd ../..

echo ""

# ============================================
# Summary
# ============================================
echo "========================================"
echo "📊 Test Summary"
echo "========================================"
echo ""

if [ $FAILURES -eq 0 ]; then
    print_success "All tests passed! ✨"
    echo ""
    echo "✅ Ready for deployment!"
    echo ""
    echo "Next steps:"
    echo "  1. Review any warnings above"
    echo "  2. Update template values in .env files"
    echo "  3. Deploy to AWS EC2 (see DEPLOYMENT_GUIDE.md)"
    echo ""
    exit 0
else
    print_error "$FAILURES test(s) failed"
    echo ""
    echo "❌ Fix the errors above before deploying"
    echo ""
    echo "Common fixes:"
    echo "  • Run 'bash setup-env.sh' to create .env files"
    echo "  • Run 'bash setup-fonts.sh' to copy dyslexia fonts"
    echo "  • Check build logs in /tmp/ for details"
    echo "  • Verify all dependencies are installed"
    echo ""
    exit 1
fi
