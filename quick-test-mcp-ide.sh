#!/bin/bash

# Quick test script for MCP-IDE frontend build

echo "🧪 Testing MCP-IDE Frontend Build..."
echo "===================================="
echo ""

cd mcp-ide/frontend

echo "Running TypeScript compiler..."
if npx tsc --noEmit; then
    echo "✅ TypeScript check passed!"
else
    echo "❌ TypeScript check failed!"
    exit 1
fi

echo ""
echo "Building for production..."
if npm run build; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "Build output:"
    ls -lh dist/
    echo ""
    exit 0
else
    echo ""
    echo "❌ Build failed!"
    exit 1
fi
