# Askapy - Complete Handoff Document

## 🎯 Project Overview

**Askapy** is a ChatGPT plugin that provides veterinary advice and connects pet owners with local veterinarians.

**Business Model:**
- Vets pay $69.99/month + $10 per booking
- 3-tier system: Basic, Featured, Premium ($69.99 / $149.99 / $299.99)
- AEO (AI Engine Optimization) - paid tiers rank higher in recommendations
- Target: Dallas, TX veterinarians first

**Owner:** Has Railway account + owns Askapy.com domain

---

## 📁 Complete File Structure

```
/workspace/
├── askapy-backend/
│   ├── main.py                 # FastAPI backend with all endpoints
│   ├── requirements.txt         # Python dependencies
│   └── README.md               # Backend documentation
│
├── vetqube/
│   ├── dashboard.html          # Vet dashboard (VetQube)
│   └── signup.html             # Vet signup portal
│
├── chatgpt-plugin/
│   ├── .well-known/
│   │   └── ai-plugin.json     # ChatGPT plugin manifest
│   ├── openapi.json           # OpenAPI specification
│   ├── SUBMISSION_GUIDE.md    # How to submit to ChatGPT
│   ├── LEGAL_TEMPLATES.md     # Privacy policy, ToS templates
│   └── LOGO_DESIGN.md         # Logo requirements
│
├── DEPLOY_TO_RAILWAY.md        # Complete Railway deployment guide
├── QUICK_START.md              # 20-minute launch guide
├── LAUNCH_CHECKLIST.md         # Day-by-day launch roadmap
├── deploy.sh                   # Automated deployment script
└── ASKAPY_HANDOFF.md          # This file!
```

---

## ✅ What's Complete

### Backend (main.py):
- ✅ FastAPI server setup
- ✅ CORS middleware for ChatGPT
- ✅ `/api/ask` - Pet health triage endpoint
- ✅ `/api/vets/{vet_id}` - Get vet details
- ✅ `/api/book/{vet_id}` - Book appointment
- ✅ Mock vet data (5 Dallas vets with tiers)
- ✅ AEO algorithm (tier-based ranking)
- ✅ Haversine distance calculation
- ✅ Lead logging and revenue tracking

### ChatGPT Plugin:
- ✅ Plugin manifest (ai-plugin.json)
- ✅ OpenAPI specification
- ✅ Submission guide
- ✅ Legal templates
- ✅ Logo design guide

### Vet Portal (VetQube):
- ✅ Dashboard with leads tracking
- ✅ Tier badges (Basic/Featured/Premium)
- ✅ Signup form with tier selection
- ✅ Revenue calculator
- ✅ Analytics display

### Documentation:
- ✅ Complete deployment guide
- ✅ Quick start guide
- ✅ Launch checklist
- ✅ Tier system documentation

---

## 🚀 Next Steps for Assistant

### **IMMEDIATE (Today):**

1. **Deploy to Railway:**
   ```bash
   cd /workspace/askapy-backend
   railway login
   # Choose "Empty Project" in dashboard first
   railway link
   railway up
   ```

2. **Configure Domain:**
   - In Railway: `railway domain add api.askapy.com`
   - Get CNAME target from Railway
   - In domain registrar: Add CNAME record
     - Name: `api`
     - Target: `[railway CNAME]`
   - Wait 10-30 minutes for DNS

3. **Test Deployment:**
   ```bash
   curl https://api.askapy.com
   # Should return: {"name":"Askapy",...}
   ```

### **THIS WEEK:**

4. **Get Logo:**
   - Use Canva.com or Flaticon
   - Create 512x512 PNG with 🐾 emoji
   - Upload to askapy-backend/logo.png
   - Redeploy: `railway up`

5. **Create Privacy Policy:**
   - Use template in `chatgpt-plugin/LEGAL_TEMPLATES.md`
   - Host at askapy.com/legal
   - Can use simple HTML on Netlify/Vercel

6. **Submit to ChatGPT:**
   - Go to: https://platform.openai.com/docs/plugins
   - Click "Submit a plugin"
   - Fill in:
     - Name: Askapy
     - URL: https://api.askapy.com
     - Email: support@askapy.com
     - Description: (see SUBMISSION_GUIDE.md)
   - Submit!

### **WEEKS 2-3 (While Waiting for Approval):**

7. **Recruit Dallas Vets:**
   - Target: 10 vets
   - Email template in LAUNCH_CHECKLIST.md
   - Offer: FREE for 3 months
   - Focus on: Emergency clinics, high-rated practices

8. **Set Up Support:**
   - Create support@askapy.com email
   - Forward to owner's email

9. **Build Landing Page:**
   - Simple HTML at askapy.com
   - "Coming soon to ChatGPT"
   - Link to privacy policy
   - Vet signup CTA

10. **Add Authentication to VetQube:**
    - Current dashboard.html is static
    - Need login system
    - Connect to backend database

### **WEEK 4 (After Approval):**

11. **Go Live!**
    - Test plugin in ChatGPT
    - Email all vets: "WE'RE LIVE"
    - Monitor API logs
    - Watch for first bookings

12. **Add Real Database:**
    - Current: Mock data in Python
    - Need: PostgreSQL on Railway
    - In Railway dashboard: New → Database → PostgreSQL
    - Update main.py to use DATABASE_URL

13. **Add Stripe Payment:**
    - Get Stripe account
    - Add STRIPE_SECRET_KEY to Railway
    - Implement subscription billing
    - Add webhook for payment events

---

## 🔑 Important Info

### **Railway Account:**
- Owner has account set up
- Choose "Empty Project" when creating
- Use CLI for deployment

### **Domain:**
- Owner owns Askapy.com
- Need to configure DNS CNAME
- Point `api.askapy.com` to Railway

### **Current Status:**
- ✅ All code written
- ✅ Backend tested locally
- ⏳ Need to deploy to Railway
- ⏳ Need to submit to ChatGPT
- ⏳ Need to recruit vets

---

## 📊 Business Metrics to Track

### **Week 1 Goals:**
- Deploy to Railway ✅
- Submit to ChatGPT ✅
- Recruit 5 vets ✅

### **Month 1 Goals (After Approval):**
- 100+ API calls/day
- 10+ bookings/day
- 10 active vet partners
- $3,000/month revenue

### **Month 3 Goals:**
- 500+ API calls/day
- 50+ bookings/day
- 30 active vet partners
- $15,000/month revenue

---

## 🛠️ Technical Stack

**Backend:**
- FastAPI (Python web framework)
- Uvicorn (ASGI server)
- Pydantic (data validation)
- No database yet (using mock data)

**Hosting:**
- Railway (backend API)
- Askapy.com (landing page - not built yet)

**Future Additions:**
- PostgreSQL database
- Stripe payments
- User authentication
- Email notifications

---

## 📞 Support Resources

### **Deployment Help:**
- See: DEPLOY_TO_RAILWAY.md
- Railway docs: railway.app/docs
- Railway CLI help: `railway help`

### **ChatGPT Plugin Help:**
- See: chatgpt-plugin/SUBMISSION_GUIDE.md
- OpenAI plugin docs: platform.openai.com/docs/plugins
- Plugin support: plugin-support@openai.com

### **Business Help:**
- See: LAUNCH_CHECKLIST.md
- Tier system: askapy-backend/TIERS.md
- Revenue projections in askapy-backend/README.md

---

## ⚠️ Important Notes

1. **Legal Disclaimer:**
   - Askapy provides general advice only
   - Not a substitute for veterinary care
   - MUST include disclaimer in all responses
   - See LEGAL_TEMPLATES.md

2. **Dallas Focus First:**
   - All mock vets are in Dallas, TX
   - Expand to other cities after proof of concept
   - Don't over-promise coverage

3. **Vet Pricing:**
   - $69.99/month base (Basic tier)
   - $10 per booking
   - Featured: $149.99/month (higher ranking)
   - Premium: $299.99/month (top priority + badge)

4. **API Rate Limits:**
   - ChatGPT may send lots of requests
   - Monitor Railway usage
   - May need to upgrade plan

---

## 🎯 Success Criteria

**You'll know it's working when:**

1. ✅ Can access https://api.askapy.com
2. ✅ Plugin manifest loads: https://api.askapy.com/.well-known/ai-plugin.json
3. ✅ Test query returns vets: POST to /api/ask
4. ✅ ChatGPT approves plugin (1-2 weeks)
5. ✅ First vet signs up
6. ✅ First booking happens
7. ✅ First revenue received! 💰

---

## 📧 Contact

**For questions about this handoff:**
- All documentation is in /workspace/
- Check README files in each folder
- Railway CLI: `railway help`
- ChatGPT plugins: platform.openai.com/docs/plugins

---

## 🚀 Quick Command Reference

```bash
# Deploy to Railway
cd /workspace/askapy-backend
railway login
railway link
railway up

# Add custom domain
railway domain add api.askapy.com

# Check logs
railway logs

# Check status
railway status

# Redeploy after changes
railway up

# Set environment variables
railway variables set KEY=value
```

---

## ✅ Final Checklist for Assistant

**Before you start:**
- [ ] Read this entire document
- [ ] Review DEPLOY_TO_RAILWAY.md
- [ ] Review QUICK_START.md
- [ ] Have owner's Railway login ready
- [ ] Have owner's domain registrar login ready

**Deployment:**
- [ ] Create empty project in Railway
- [ ] Deploy via CLI: `railway up`
- [ ] Configure custom domain
- [ ] Test API endpoints
- [ ] Upload logo
- [ ] Test plugin manifest

**Submission:**
- [ ] Create privacy policy
- [ ] Set up support email
- [ ] Submit to ChatGPT plugin store
- [ ] Document submission ID

**Launch Prep:**
- [ ] Draft vet recruitment emails
- [ ] Create landing page
- [ ] Set up analytics
- [ ] Prepare for first bookings

---

## 💡 Pro Tips

1. **Deploy early, deploy often** - Get it on Railway TODAY
2. **Start with 5 vets** - Don't wait for 50
3. **Keep it simple** - Mock data is fine for now
4. **Monitor logs closely** - Catch errors fast
5. **Get ONE booking** - Then optimize from there

---

## 🎉 You Got This!

Everything is built and ready to deploy. Just follow the steps in order:

1. Deploy to Railway (20 min)
2. Configure domain (10 min)
3. Submit to ChatGPT (10 min)
4. Recruit vets (2 weeks)
5. Go live! (Week 3)

**Total time to submission: 40 minutes**
**Total time to revenue: 3 weeks**

Good luck, amigo! 🐾💰

---

*Last updated: October 17, 2025*
*Project status: Ready to deploy*
*All code complete and tested locally*
