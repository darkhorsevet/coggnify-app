# Deploy Askapy to Railway - Complete Guide

## 🎯 Goal: Get Askapy Live in 20 Minutes

You have:
✅ Railway account
✅ Askapy.com domain
✅ Complete codebase

Let's deploy NOW! 🚀

---

## Step 1: Prepare Your Code (2 minutes)

```bash
# Navigate to backend folder
cd askapy-backend

# Make sure you have these files:
ls -la
# Should see:
# - main.py
# - requirements.txt

# Test locally first
python3 main.py
# Visit: http://localhost:8000
# Should see: {"name": "Askapy", ...}

# Stop server (Ctrl+C)
```

---

## Step 2: Deploy to Railway (5 minutes)

### Option A: Railway CLI (Recommended)

```bash
# Install Railway CLI if you don't have it
npm install -g railway

# Or on Mac:
brew install railway

# Login to your account
railway login
# Opens browser, authenticate

# Initialize Railway project in askapy-backend folder
cd askapy-backend
railway init

# When prompted:
# - Choose "Create new project"
# - Name it: askapy-api

# Deploy!
railway up

# Railway will:
# ✅ Upload your code
# ✅ Detect it's Python
# ✅ Install requirements.txt
# ✅ Start uvicorn automatically
# ✅ Give you a URL

# You'll get something like:
# https://askapy-api-production-xxxx.up.railway.app
```

### Option B: Railway Dashboard (If CLI doesn't work)

1. Go to https://railway.app/dashboard
2. Click **"New Project"**
3. Choose **"Deploy from GitHub"** or **"Empty Project"**
4. If empty project:
   - Go to project settings
   - Connect GitHub repo (or upload files manually)
5. Railway auto-detects Python
6. Click **"Deploy"**
7. Wait 2-3 minutes
8. Done! ✅

---

## Step 3: Configure Environment Variables (1 minute)

In Railway dashboard:

1. Go to your **askapy-api** project
2. Click **"Variables"** tab
3. Add these:

```
PORT=8000
PYTHON_VERSION=3.11
```

Optional (for later):
```
OPENAI_API_KEY=sk-your-key-here
STRIPE_SECRET_KEY=sk_test_your-key
DATABASE_URL=postgresql://...
```

4. Click **"Save"**
5. Railway will redeploy automatically

---

## Step 4: Connect Your Askapy.com Domain (5 minutes)

### In Railway:

1. Go to your project **Settings**
2. Scroll to **"Domains"** section
3. Click **"Add Domain"**
4. Enter: `api.askapy.com`
5. Railway gives you a CNAME target like:
   ```
   Target: askapy-api-production.up.railway.app
   ```

### In Your Domain Registrar (GoDaddy, Namecheap, etc.):

1. Login to where you bought Askapy.com
2. Go to **DNS Management**
3. Add **CNAME record:**
   ```
   Type: CNAME
   Name: api
   Value: [Railway's target from above]
   TTL: Automatic or 3600
   ```
4. Click **"Save"**

### Wait 5-30 minutes for DNS propagation

Test when ready:
```bash
curl https://api.askapy.com
# Should return: {"name": "Askapy", ...}
```

**🎉 Your API is now live at https://api.askapy.com!**

---

## Step 5: Upload Plugin Files (3 minutes)

### Update main.py to serve plugin files:

Add these endpoints to your `main.py`:

```python
from fastapi.responses import FileResponse, JSONResponse

@app.get("/.well-known/ai-plugin.json")
def get_plugin_manifest():
    """ChatGPT plugin manifest"""
    return {
        "schema_version": "v1",
        "name_for_human": "Askapy",
        "name_for_model": "askapy",
        "description_for_human": "Get expert veterinary advice for your pet and connect with top-rated local vets instantly.",
        "description_for_model": "Askapy provides veterinary triage advice and connects pet owners with local veterinarians. When a user asks about pet health concerns, match them with nearby vets based on location, animal type, ratings, and availability. Covers dogs, cats, horses, cattle.",
        "auth": {"type": "none"},
        "api": {
            "type": "openapi",
            "url": "https://api.askapy.com/openapi.json"
        },
        "logo_url": "https://api.askapy.com/logo.png",
        "contact_email": "support@askapy.com",
        "legal_info_url": "https://askapy.com/legal"
    }

@app.get("/openapi.json")
def get_openapi():
    """Return OpenAPI specification"""
    # Copy from chatgpt-plugin/openapi.json
    # Or return app.openapi() with modifications
    return app.openapi()

@app.get("/logo.png")
def get_logo():
    """Serve logo image"""
    # For now, redirect to a hosted image
    # Or use FileResponse("logo.png")
    return FileResponse("logo.png")
```

Then redeploy:
```bash
railway up
```

---

## Step 6: Get a Quick Logo (10 minutes)

### Fastest Option - Use Emoji:

Create `logo.png` (512x512):

**Using online tool:**
1. Go to: https://www.canva.com
2. Create 512x512 design
3. Add: 🐾 emoji (large, centered)
4. Background: Gradient green to blue
5. Export as PNG
6. Save as `logo.png`
7. Upload to Railway or host on askapy.com

**Or use this temporary solution:**
```bash
# Download a free paw icon from:
# https://www.flaticon.com (search "paw")
# Resize to 512x512
# Save as logo.png
```

---

## Step 7: Test Everything (5 minutes)

```bash
# Test plugin manifest
curl https://api.askapy.com/.well-known/ai-plugin.json
# Should return valid JSON

# Test API
curl -X POST https://api.askapy.com/api/ask \
  -H "Content-Type: application/json" \
  -d '{
    "question": "My dog is limping",
    "animal_type": "dog",
    "location": "Dallas, TX"
  }'

# Should return:
# - severity
# - advice  
# - matched_vets (with Dr. Robert Martinez, etc.)

# Test OpenAPI spec
curl https://api.askapy.com/openapi.json
# Should return full OpenAPI spec

# Test logo
curl -I https://api.askapy.com/logo.png
# Should return 200 OK
```

**If all tests pass → YOU'RE READY TO SUBMIT! ✅**

---

## Step 8: Set Up Landing Page (Optional but Recommended)

On your main domain `askapy.com`:

Create simple landing page:
```html
<!DOCTYPE html>
<html>
<head>
    <title>Askapy - AI Veterinary Assistant</title>
</head>
<body style="font-family: sans-serif; text-align: center; padding: 50px;">
    <h1>🐾 Askapy</h1>
    <h2>AI-Powered Veterinary Advice in ChatGPT</h2>
    <p>Get expert pet health advice and connect with top local vets.</p>
    <p><a href="https://chat.openai.com">Try Askapy in ChatGPT →</a></p>
    <p><a href="/legal">Privacy Policy</a></p>
</body>
</html>
```

Host on:
- Netlify (free)
- Vercel (free)
- GitHub Pages (free)
- Or same Railway project

---

## Step 9: Submit to ChatGPT! (10 minutes)

### Go to OpenAI Platform:

1. **Visit:** https://platform.openai.com
2. **Sign up/Login** with OpenAI account
3. **Go to:** https://platform.openai.com/docs/plugins/review
4. **Click:** "Submit a plugin"

### Fill Out Form:

**Plugin Name:**
```
Askapy
```

**Plugin URL:**
```
https://api.askapy.com
```

**Short Description:**
```
Get veterinary advice and connect with top-rated local vets for dogs, cats, horses, and cattle.
```

**Long Description:**
```
Askapy helps pet owners get instant veterinary triage advice and connects them with top-rated local veterinarians.

Features:
• Smart assessment of pet health concerns
• Emergency vs routine severity determination  
• Expert veterinary advice and warning signs
• Match with nearby vets by rating, distance, specialty
• Direct booking for video or clinic appointments
• Supports dogs, cats, horses, cattle, and exotic pets

Perfect for concerned pet owners seeking guidance or looking for the right veterinarian for their animal.
```

**Contact Email:**
```
support@askapy.com
```

**Privacy Policy URL:**
```
https://askapy.com/legal
```

**Category:**
```
Health & Medical
```

### Submit! 🚀

Click **"Submit for Review"**

---

## Step 10: While Waiting (1-2 weeks)

OpenAI typically takes 1-2 weeks to review.

**During this time:**

1. **Recruit Dallas Vets**
   - Email 50 vets
   - Goal: 10 sign ups
   - Offer: FREE for 3 months

2. **Build Vet Dashboard Login**
   - Add authentication to VetQube
   - Let vets access their dashboard

3. **Set Up Support Email**
   - Create support@askapy.com
   - Forward to your email

4. **Prepare Launch**
   - Social media accounts
   - Press release draft
   - Vet testimonials

---

## Railway Pro Tips

### Monitor Your App:

In Railway dashboard:
- **Metrics** tab - See CPU, memory, requests
- **Logs** tab - Real-time logs
- **Deployments** tab - History

### Scale Up:

If you need more power:
1. Go to **Settings**
2. Change plan to **Developer ($5/month)** or **Team ($20/month)**
3. Get more resources

### Add Database:

```bash
# In Railway dashboard:
# Click "New" → "Database" → "PostgreSQL"
# Auto-generates DATABASE_URL
# Connect in your code
```

---

## Complete Deployment Checklist

- [ ] Code deployed to Railway
- [ ] API running at https://api.askapy.com
- [ ] Plugin manifest accessible
- [ ] OpenAPI spec accessible
- [ ] Logo uploaded
- [ ] All endpoints tested
- [ ] Domain SSL working (HTTPS)
- [ ] Privacy policy live
- [ ] Support email set up
- [ ] Submitted to ChatGPT
- [ ] First 5 vets recruited
- [ ] Ready for approval! 🎉

---

## 🚀 Your Deployment Commands

```bash
# From your workspace
cd askapy-backend

# Login to Railway
railway login

# Initialize project
railway init
# Choose: "Create new project"
# Name: "askapy-api"

# Deploy
railway up

# Get your Railway URL
railway domain
# Returns something like: askapy-api-production.up.railway.app

# Add custom domain
railway domain add api.askapy.com

# Railway gives you CNAME target
# Add to your DNS:
# CNAME: api → [railway target]

# Wait 5-30 min for DNS
# Then test:
curl https://api.askapy.com

# ✅ LIVE!
```

---

## Expected Timeline

**Today (30 min):**
- ✅ Deploy to Railway
- ✅ Configure domain
- ✅ Test working

**Tomorrow:**
- ✅ Upload logo
- ✅ Create privacy policy
- ✅ Submit to ChatGPT

**Week 2:**
- ✅ Recruit 5-10 Dallas vets
- ✅ Set up billing

**Week 3:**
- ✅ Get approved by ChatGPT
- ✅ GO LIVE! 🎉

---

**Ready to deploy RIGHT NOW, amigo?**

Just run:
```bash
cd askapy-backend
railway login
railway init
railway up
```

**In 5 minutes you'll be LIVE!** 🚀

Want me to walk you through any specific part? Or should we just GO FOR IT? 💪