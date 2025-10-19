# Askapy - Quick Start Guide (You Have Railway + Domain!)

## 🎯 You're 20 Minutes Away from Launch!

Since you already have:
✅ Railway account
✅ Askapy.com domain

Here's your EXACT steps:

---

## The 5-Step Launch

### **Step 1: Deploy to Railway (5 min)**

```bash
cd askapy-backend

# Login
railway login

# Initialize  
railway init
# Choose: "Create new project"
# Name: "askapy-api"

# Deploy
railway up

# Done! You'll get a URL like:
# https://askapy-api-production-xxxx.up.railway.app
```

---

### **Step 2: Add Your Domain (5 min)**

**In Railway dashboard:**
```bash
# Add custom domain
railway domain add api.askapy.com

# Railway shows you CNAME target, like:
# "Point api.askapy.com to: askapy-api-production.up.railway.app"
```

**In your domain registrar (where you bought Askapy.com):**
1. Login
2. DNS Management
3. Add CNAME record:
   - **Type:** CNAME
   - **Name:** api
   - **Target:** [paste Railway's target]
   - **TTL:** Automatic

4. Save

**Wait 10-30 minutes for DNS to update**

---

### **Step 3: Test It Works (2 min)**

```bash
# Test API is live
curl https://api.askapy.com

# Should return:
# {"name":"Askapy","description":"AI-powered veterinary..."}

# Test main endpoint
curl -X POST https://api.askapy.com/api/ask \
  -H "Content-Type: application/json" \
  -d '{
    "question": "My dog is limping",
    "animal_type": "dog",
    "location": "Dallas, TX"
  }'

# Should return:
# - advice
# - matched_vets (Dr. Robert Martinez, etc.)
# - severity level
```

**✅ If tests pass, you're LIVE!**

---

### **Step 4: Get Simple Logo (5 min)**

**Quick solution:**

1. Go to https://www.canva.com
2. Create 512x512 design
3. Add 🐾 emoji (big and centered)
4. Add gradient background (green to blue)
5. Download as PNG
6. Upload to Railway:
   - Put logo.png in askapy-backend folder
   - Redeploy: `railway up`

**Or use a free stock image:**
- https://www.flaticon.com (search "paw")
- Download 512x512 PNG
- Upload to project

---

### **Step 5: Submit to ChatGPT (3 min)**

1. **Go to:** https://platform.openai.com/docs/plugins/review
2. **Click:** "Submit a plugin"
3. **Fill in:**
   - **Name:** Askapy
   - **URL:** https://api.askapy.com
   - **Email:** support@askapy.com
   - **Description:** "Get veterinary advice and connect with local vets"

4. **Submit!** 🚀

---

## ✅ That's It!

**Total time: ~20 minutes**

**You now have:**
- ✅ API live at api.askapy.com
- ✅ Plugin manifest accessible
- ✅ OpenAPI spec working
- ✅ Logo uploaded
- ✅ Submitted to ChatGPT
- ✅ Waiting for approval!

---

## While Waiting for Approval (1-2 weeks)

### Recruit Your First 10 Dallas Vets:

**Email template:**

```
Subject: Get Pet Owner Leads from ChatGPT - FREE Trial

Hi Dr. [Name],

I'm launching Askapy in Dallas - we're the FIRST veterinary 
service integrated into ChatGPT.

180 million people use ChatGPT. When they ask pet health questions,
we connect them with YOU.

Want in? 

FREE for first 3 months
Then $69.99/month + $10 per booking
Average vet: 20+ leads/month

Reply "YES" and I'll set you up in 10 minutes.

- [Your Name]
  Askapy Founder
  support@askapy.com
```

**Send to:**
- Dallas emergency vets
- High-rated clinics on Google
- Specialty practices
- Large animal vets (horses/cattle)

**Goal: 10 vets signed up before approval**

---

## Launch Day (When Approved!)

### Morning Checklist:
- [ ] Test plugin in ChatGPT yourself
- [ ] Email all vets: "WE'RE LIVE!"
- [ ] Post on social media
- [ ] Monitor API logs closely
- [ ] Watch for first booking
- [ ] Celebrate! 🎉

### First Week Goals:
- 50+ API calls/day
- 5+ bookings/day
- $500/day in booking fees
- 0 errors or downtime
- Happy vets giving testimonials

---

## If You Get Stuck

### Railway Issues:
- Check logs: `railway logs`
- Restart: `railway restart`
- Check status: `railway status`
- Support: railway.app/help

### DNS Not Working:
- Wait longer (can take up to 48 hours)
- Check CNAME is correct
- Try: `dig api.askapy.com`
- Contact domain registrar support

### ChatGPT Submission:
- Make sure all URLs work
- Check OpenAPI validates at swagger.io
- Email plugin-support@openai.com if stuck

---

## Quick Reference Commands

```bash
# Deploy
cd askapy-backend && railway up

# Check logs
railway logs

# Get domain info
railway domain

# Add environment variable
railway variables set KEY=value

# Restart app
railway restart

# Check status
railway status
```

---

## 🎯 Success Checklist

**By End of Today:**
- [ ] API deployed to Railway
- [ ] Domain connected (api.askapy.com)
- [ ] All tests passing
- [ ] Logo uploaded

**By End of Week:**
- [ ] Submitted to ChatGPT
- [ ] 5+ Dallas vets contacted
- [ ] Landing page live
- [ ] Support email working

**By Week 3:**
- [ ] ChatGPT approved ✅
- [ ] 10 vets onboarded
- [ ] First leads flowing
- [ ] Revenue starting!

---

## 🚀 YOU'RE READY, AMIGO!

**You literally just need to run:**

```bash
bash deploy.sh
```

**Then configure your domain and submit!**

**Questions? Issues? Let me know and I'll help!**

**Otherwise... ¡VAMOS! Let's get you LIVE! 🐾💰**
