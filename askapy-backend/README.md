# Askapy Backend API

**AI-Powered Veterinary Lead Generation Platform**

Connects pet owners asking questions in ChatGPT with local veterinarians.

---

## 🎯 How It Works

1. **User asks ChatGPT:** "My dog is limping, should I be worried?"
2. **ChatGPT calls Askapy API** via plugin
3. **Askapy provides:**
   - Smart triage advice
   - List of nearby vets (with ratings, distance)
   - Direct booking links
4. **User books appointment** → Vet gets lead! 💰

---

## 🚀 Quick Start

```bash
# Install dependencies
pip install -r requirements.txt

# Run server
python main.py

# Server runs on: http://localhost:8000
```

### Test the API

```bash
# Ask a question
curl -X POST http://localhost:8000/api/ask \
  -H "Content-Type: application/json" \
  -d '{
    "question": "My dog is limping on his front leg",
    "animal_type": "dog",
    "location": "Austin, TX",
    "urgency": "urgent"
  }'

# Response:
{
  "severity": "urgent",
  "advice": "Limping can indicate...",
  "red_flags": ["Not bearing weight...", "Visible swelling..."],
  "matched_vets": [
    {
      "name": "Dr. Robert Martinez",
      "rating": 4.9,
      "distance_miles": 14.7,
      "price_video": 45.00,
      ...
    }
  ],
  "should_see_vet": true
}
```

---

## 💰 Business Model

### For Vets (Revenue Sources):

**Option 1: Per-Lead Pricing**
- $15 per qualified lead shown
- Only pay when your profile is displayed
- Best for vets starting out

**Option 2: Monthly Subscription**
- $99/month - Unlimited leads
- Featured placement
- Priority ranking
- Best for established clinics

**Option 3: Hybrid (Recommended)**
- $49/month base + $10 per booking
- Lower subscription, pay for results
- Most attractive to vets

### Projected Revenue:

**Month 1-3 (100 vets):**
- 100 vets × $49/month = $4,900/month
- 500 leads × $10/booking = $5,000/month
- **Total: ~$10,000/month**

**Month 6 (500 vets):**
- 500 vets × $49/month = $24,500/month
- 2,500 leads × $10/booking = $25,000/month
- **Total: ~$50,000/month**

**Year 1 (2,000 vets):**
- 2,000 vets × $49/month = $98,000/month
- 10,000 leads × $10/booking = $100,000/month
- **Total: ~$200,000/month = $2.4M/year**

---

## 🏗️ Architecture

```
User in ChatGPT
      ↓
ChatGPT calls Askapy Plugin
      ↓
Askapy API (FastAPI)
      ↓
┌─────────────┬──────────────┬─────────────┐
│             │              │             │
Triage      Vet Matching   Lead Logging
System      Algorithm      & Billing
│             │              │
└─────────────┴──────────────┴─────────────┘
      ↓
Response to ChatGPT
      ↓
User sees vets & books
```

---

## 📊 Key Features

### 1. Smart Triage
- Emergency detection
- Severity assessment
- Red flag identification
- Animal-specific knowledge

### 2. Geographic Matching
- Find vets within radius
- Haversine distance calculation
- Sort by rating + distance
- Filter by specialty

### 3. Lead Generation
- Capture qualified leads
- Route to appropriate vets
- Track booking conversions
- Automated billing

### 4. Vet Dashboard (Coming Soon)
- See incoming leads
- Respond to inquiries
- Analytics dashboard
- Payment management

---

## 🛠️ Tech Stack

- **Backend:** FastAPI (Python)
- **Database:** PostgreSQL (add later)
- **Cache:** Redis (for fast matching)
- **Payments:** Stripe
- **Hosting:** Railway/Render/AWS
- **CDN:** Cloudflare

---

## 📱 API Endpoints

### Public Endpoints

```
GET  /                          # API info
GET  /.well-known/ai-plugin.json # ChatGPT manifest
POST /api/ask                   # Main: Answer question + match vets
GET  /api/vets/{vet_id}        # Get vet details
POST /api/book/{vet_id}        # Book appointment
GET  /health                    # Health check
```

### Vet Portal Endpoints (To Build)

```
POST /api/vet/signup            # Vet registration
POST /api/vet/login             # Authentication
GET  /api/vet/leads             # View leads
PUT  /api/vet/profile           # Update profile
GET  /api/vet/analytics         # Dashboard stats
```

---

## 🔒 Security

### For Production:

1. **API Authentication**
```python
# Add to endpoints
async def verify_api_key(api_key: str = Header(...)):
    if api_key not in VALID_API_KEYS:
        raise HTTPException(401, "Invalid API key")
```

2. **Rate Limiting**
```python
from slowapi import Limiter
limiter = Limiter(key_func=get_remote_address)

@app.post("/api/ask")
@limiter.limit("10/minute")
def ask_question(...):
    ...
```

3. **Input Validation**
- Already using Pydantic models
- Add more validation rules
- Sanitize all inputs

---

## 🚀 Deployment

### Option 1: Railway (Easiest)
```bash
# Install Railway CLI
npm install -g railway

# Deploy
railway login
railway init
railway up
```

### Option 2: Render
```yaml
# render.yaml
services:
  - type: web
    name: askapy-api
    env: python
    buildCommand: pip install -r requirements.txt
    startCommand: uvicorn main:app --host 0.0.0.0 --port $PORT
```

### Option 3: AWS EC2
```bash
# SSH into server
sudo apt update
sudo apt install python3-pip
pip3 install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 80
```

---

## 🧪 Testing

```python
# test_api.py
import requests

def test_ask_question():
    response = requests.post("http://localhost:8000/api/ask", json={
        "question": "My dog won't stop vomiting",
        "animal_type": "dog",
        "urgency": "urgent"
    })
    assert response.status_code == 200
    data = response.json()
    assert "matched_vets" in data
    assert len(data["matched_vets"]) > 0
    print(f"✅ Matched {len(data['matched_vets'])} vets")
```

---

## 📈 Next Steps

### Week 1:
- [ ] Add PostgreSQL database
- [ ] Build vet signup portal
- [ ] Add Stripe payments
- [ ] Submit ChatGPT plugin

### Week 2:
- [ ] Vet dashboard (see leads)
- [ ] Email notifications
- [ ] SMS alerts for urgent cases
- [ ] Analytics tracking

### Week 3:
- [ ] Advanced matching (insurance, hours, etc.)
- [ ] Review system
- [ ] Photo upload for questions
- [ ] Telemedicine integration

### Week 4:
- [ ] Marketing to vets
- [ ] SEO for vet signups
- [ ] Beta testing with 10 vets
- [ ] Refine based on feedback

---

## 💡 Growth Strategy

### Month 1-2: Launch
- Get 50-100 vets signed up
- Free for first month
- Collect feedback

### Month 3-4: Scale
- ChatGPT plugin approved
- Start charging
- Add more animal types

### Month 5-6: Expand
- 500+ vets
- Multiple cities
- Telemedicine partners

### Month 7-12: Dominate
- 2,000+ vets
- National coverage
- $200K+ MRR

---

## 🐾 Animal Coverage

**Phase 1 (Now):**
- Dogs
- Cats
- Horses
- Cattle

**Phase 2 (Month 3):**
- Rabbits
- Birds
- Reptiles
- Other exotics

---

## 🎯 Success Metrics

- **Leads generated per day**
- **Vet signup rate**
- **Booking conversion rate**
- **Average revenue per vet**
- **Customer satisfaction score**
- **Vet retention rate**

---

## 💪 Let's Go, Amigo!

This is the foundation! Now we need to:
1. Deploy this API
2. Build vet signup portal
3. Submit to ChatGPT
4. Start getting vets!

**Questions? Let's keep building! 🚀**
