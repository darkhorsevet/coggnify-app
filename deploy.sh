#!/bin/bash

# Askapy Deployment Script for Railway
# Run this to deploy to your Railway account!

echo "🐾 Askapy Deployment Script"
echo "============================="
echo ""

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null
then
    echo "❌ Railway CLI not found. Installing..."
    echo ""
    echo "Run one of these:"
    echo "  npm install -g railway"
    echo "  OR"
    echo "  brew install railway"
    echo ""
    exit 1
fi

echo "✅ Railway CLI found"
echo ""

# Navigate to backend
cd askapy-backend

echo "📦 Deploying Askapy to Railway..."
echo ""

# Login
echo "Step 1: Login to Railway"
railway login

echo ""
echo "Step 2: Initialize project"
railway init

echo ""
echo "Step 3: Deploy!"
railway up

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Next steps:"
echo "1. Get your Railway URL: railway domain"
echo "2. Add custom domain: railway domain add api.askapy.com"
echo "3. Configure DNS CNAME: api.askapy.com → [railway URL]"
echo "4. Wait 10-30 min for DNS propagation"
echo "5. Test: curl https://api.askapy.com"
echo ""
echo "Then submit to ChatGPT!"
echo "🚀 Let's go!"
