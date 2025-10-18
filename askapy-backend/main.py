# Askapy Backend API
# ChatGPT Plugin for Veterinary Lead Generation
# Connects pet owners with local vets

from fastapi import FastAPI, HTTPException, Header
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
import math
from datetime import datetime

app = FastAPI(title="Askapy", description="AI-powered veterinary lead generation")

# CORS for ChatGPT
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://chat.openai.com"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================================================
# DATA MODELS
# ============================================================================

class PetQuestion(BaseModel):
    question: str
    animal_type: str  # dog, cat, horse, cattle
    location: Optional[str] = None  # zip code or city
    urgency: Optional[str] = "routine"  # emergency, urgent, routine
    symptoms: Optional[List[str]] = []

class Vet(BaseModel):
    id: str
    name: str
    specialty: str
    rating: float
    review_count: int
    distance_miles: float
    animals_treated: List[str]  # ["dogs", "cats", "horses"]
    price_video: float
    price_clinic: float
    available_now: bool
    phone: str
    address: str
    lat: float
    lon: float
    tier: str  # "basic", "featured", "premium"

class TriageResponse(BaseModel):
    severity: str  # "emergency", "urgent", "routine"
    advice: str
    red_flags: List[str]
    matched_vets: List[Vet]
    should_see_vet: bool

# ============================================================================
# MOCK DATA (Replace with real database)
# ============================================================================

MOCK_VETS = [
    {
        "id": "vet_001",
        "name": "Dr. Robert Martinez",
        "specialty": "Veterinary Surgeon",
        "rating": 4.9,
        "review_count": 127,
        "distance_miles": 14.7,
        "animals_treated": ["dogs", "cats", "horses"],
        "price_video": 45.00,
        "price_clinic": 85.00,
        "available_now": True,
        "phone": "(555) 123-4567",
        "address": "123 Main St, Dallas, TX",
        "lat": 32.7767,
        "lon": -96.7970,
        "tier": "featured"  # $149.99/month - shown first!
    },
    {
        "id": "vet_002",
        "name": "Dr. Sarah Chen",
        "specialty": "Emergency Veterinarian",
        "rating": 4.8,
        "review_count": 89,
        "distance_miles": 8.3,
        "animals_treated": ["dogs", "cats", "exotics"],
        "price_video": 65.00,
        "price_clinic": 125.00,
        "available_now": True,
        "phone": "(555) 234-5678",
        "address": "456 Oak Ave, Dallas, TX",
        "lat": 32.8067,
        "lon": -96.8070,
        "tier": "premium"  # $249.99/month - TOP SPOT!
    },
    {
        "id": "vet_003",
        "name": "Dr. James Patterson",
        "specialty": "Large Animal Veterinarian",
        "rating": 4.7,
        "review_count": 64,
        "distance_miles": 22.1,
        "animals_treated": ["horses", "cattle"],
        "price_video": 55.00,
        "price_clinic": 150.00,
        "available_now": False,
        "phone": "(555) 345-6789",
        "address": "789 Farm Rd, Plano, TX",
        "lat": 33.0198,
        "lon": -96.6989,
        "tier": "basic"  # $69.99/month - standard listing
    }
]

# Veterinary knowledge base (simplified)
TRIAGE_KNOWLEDGE = {
    "limping": {
        "severity": "urgent",
        "advice": "Limping can indicate anything from a minor strain to a fracture. Avoid exercise and monitor for swelling, heat, or reluctance to bear weight.",
        "red_flags": [
            "Not bearing any weight on the leg",
            "Visible deformity or swelling",
            "Extreme pain when touched",
            "Limping after trauma or fall"
        ],
        "emergency_keywords": ["not bearing weight", "broken", "fracture", "severe pain"]
    },
    "vomiting": {
        "severity": "urgent",
        "advice": "Occasional vomiting can be normal, but frequent or projectile vomiting needs attention. Withhold food for 12 hours and offer small amounts of water.",
        "red_flags": [
            "Vomiting multiple times in a few hours",
            "Blood in vomit",
            "Lethargy or weakness",
            "Distended abdomen"
        ],
        "emergency_keywords": ["blood", "multiple times", "bloated", "lethargic"]
    },
    "not eating": {
        "severity": "routine",
        "advice": "Loss of appetite for 24 hours warrants attention. Ensure fresh water is available and monitor for other symptoms.",
        "red_flags": [
            "Not eating for more than 24 hours",
            "Weight loss",
            "Vomiting or diarrhea",
            "Lethargy"
        ],
        "emergency_keywords": ["days", "weak", "collapse"]
    },
    "colic": {
        "severity": "emergency",
        "advice": "Colic in horses is a MEDICAL EMERGENCY. Do not feed, remove water, and call a vet immediately.",
        "red_flags": [
            "Rolling repeatedly",
            "Pawing at ground",
            "Looking at flanks",
            "No manure production",
            "Elevated heart rate"
        ],
        "emergency_keywords": ["rolling", "thrashing", "severe pain"]
    }
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate distance between two points in miles using Haversine formula"""
    R = 3959  # Earth's radius in miles
    
    lat1_rad = math.radians(lat1)
    lat2_rad = math.radians(lat2)
    delta_lat = math.radians(lat2 - lat1)
    delta_lon = math.radians(lon2 - lon1)
    
    a = math.sin(delta_lat/2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(delta_lon/2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    
    return R * c

def match_vets(animal_type: str, user_lat: float, user_lon: float, max_distance: float = 50) -> List[Vet]:
    """
    Find vets that treat this animal type within radius
    
    TIER PRIORITY (AEO - AI Engine Optimization!):
    1. Premium vets (TOP SPOT - always first)
    2. Featured vets (shown prominently)
    3. Basic vets (sorted by rating + distance)
    """
    matched = []
    
    for vet_data in MOCK_VETS:
        # Check if vet treats this animal
        if animal_type.lower() not in vet_data["animals_treated"]:
            continue
        
        # Calculate distance
        distance = calculate_distance(user_lat, user_lon, vet_data["lat"], vet_data["lon"])
        
        if distance <= max_distance:
            vet_data["distance_miles"] = round(distance, 1)
            matched.append(Vet(**vet_data))
    
    # TIER-BASED SORTING (This is the $$ part!)
    # Premium = 1, Featured = 2, Basic = 3
    tier_priority = {"premium": 1, "featured": 2, "basic": 3}
    
    matched.sort(key=lambda v: (
        tier_priority.get(v.tier, 999),  # Tier first (premium wins!)
        -v.rating,                        # Then rating
        v.distance_miles                  # Then distance
    ))
    
    return matched[:5]  # Top 5 matches

def triage_question(question: str, symptoms: List[str]) -> dict:
    """Simple triage based on keywords"""
    question_lower = question.lower()
    
    # Check for emergency keywords
    emergency_keywords = ["emergency", "urgent", "bleeding", "unconscious", "seizure", "poisoned", "hit by car"]
    if any(keyword in question_lower for keyword in emergency_keywords):
        return {
            "severity": "emergency",
            "advice": "This sounds like an EMERGENCY. Please seek immediate veterinary care or call an emergency vet clinic right away.",
            "red_flags": ["Immediate attention required"],
            "should_see_vet": True
        }
    
    # Check against knowledge base
    for condition, info in TRIAGE_KNOWLEDGE.items():
        if condition in question_lower:
            # Check if emergency keywords present
            is_emergency = any(keyword in question_lower for keyword in info.get("emergency_keywords", []))
            
            if is_emergency:
                info["severity"] = "emergency"
                info["advice"] = f"This sounds URGENT. {info['advice']} Seek veterinary care immediately."
            
            return {
                "severity": info["severity"],
                "advice": info["advice"],
                "red_flags": info["red_flags"],
                "should_see_vet": info["severity"] in ["emergency", "urgent"]
            }
    
    # Default response
    return {
        "severity": "routine",
        "advice": "While this may not be an emergency, it's always best to consult with a veterinarian for professional advice tailored to your pet's specific situation.",
        "red_flags": ["Monitor for changes", "If symptoms worsen, seek immediate care"],
        "should_see_vet": True
    }

# ============================================================================
# API ENDPOINTS
# ============================================================================

@app.get("/")
def root():
    return {
        "name": "Askapy",
        "description": "AI-powered veterinary lead generation for ChatGPT",
        "version": "1.0.0",
        "status": "active"
    }

@app.get("/.well-known/ai-plugin.json")
def get_manifest():
    """ChatGPT plugin manifest"""
    return {
        "schema_version": "v1",
        "name_for_human": "Askapy",
        "name_for_model": "askapy",
        "description_for_human": "Get expert veterinary advice and connect with local vets for your pets",
        "description_for_model": "Askapy provides veterinary triage advice for dogs, cats, horses, and cattle. It assesses pet health concerns and connects users with local veterinarians based on location, specialty, and ratings.",
        "auth": {
            "type": "none"
        },
        "api": {
            "type": "openapi",
            "url": "https://your-domain.com/openapi.json"
        },
        "logo_url": "https://your-domain.com/logo.png",
        "contact_email": "support@askapy.com",
        "legal_info_url": "https://your-domain.com/legal"
    }

@app.post("/api/ask")
def ask_question(question: PetQuestion):
    """
    Main endpoint: Answer pet health question and provide vet matches
    
    This is what ChatGPT calls!
    """
    try:
        # Triage the question
        triage_result = triage_question(question.question, question.symptoms)
        
        # Get user location (mock for now - would use actual geolocation)
        # Default: Austin, TX
        user_lat = 30.2672
        user_lon = -97.7431
        
        # Match with local vets
        matched_vets = match_vets(
            animal_type=question.animal_type,
            user_lat=user_lat,
            user_lon=user_lon,
            max_distance=50
        )
        
        response = TriageResponse(
            severity=triage_result["severity"],
            advice=triage_result["advice"],
            red_flags=triage_result["red_flags"],
            matched_vets=matched_vets,
            should_see_vet=triage_result["should_see_vet"]
        )
        
        # Log the lead (for tracking/billing)
        log_lead(question, matched_vets)
        
        return response
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/vets/{vet_id}")
def get_vet_details(vet_id: str):
    """Get detailed info about a specific vet"""
    for vet in MOCK_VETS:
        if vet["id"] == vet_id:
            return vet
    raise HTTPException(status_code=404, detail="Vet not found")

@app.post("/api/book/{vet_id}")
def book_appointment(vet_id: str, appointment_type: str, contact_info: dict):
    """
    Book appointment with vet
    This is where the MONEY happens! 💰
    """
    # Find vet
    vet = None
    for v in MOCK_VETS:
        if v["id"] == vet_id:
            vet = v
            break
    
    if not vet:
        raise HTTPException(status_code=404, detail="Vet not found")
    
    # Create booking
    booking = {
        "booking_id": f"book_{datetime.now().timestamp()}",
        "vet_id": vet_id,
        "vet_name": vet["name"],
        "appointment_type": appointment_type,
        "price": vet["price_video"] if appointment_type == "video" else vet["price_clinic"],
        "contact_info": contact_info,
        "status": "pending",
        "created_at": datetime.now().isoformat()
    }
    
    # TODO: 
    # 1. Send booking to VetQube dashboard
    # 2. Charge customer for appointment
    # 3. Bill vet $10 booking fee (on top of $69.99/month)
    # 4. Send confirmation emails
    
    # Charge vet $10 booking fee
    print(f"💰 BOOKING COMPLETED: Charge {vet['name']} $10 booking fee")
    
    return {
        "success": True,
        "booking": booking,
        "message": f"Booking confirmed with {vet['name']}! They'll contact you within 1 hour."
    }

def log_lead(question: PetQuestion, matched_vets: List[Vet]):
    """
    Log lead for billing/analytics
    
    Revenue model:
    - Vet pays $69.99/month subscription
    - PLUS: $10 per booking completed
    """
    lead_data = {
        "timestamp": datetime.now().isoformat(),
        "question": question.question,
        "animal_type": question.animal_type,
        "vets_shown": [v.id for v in matched_vets],
        "urgency": question.urgency
    }
    
    # TODO: Save to database
    print(f"💰 LEAD LOGGED: {lead_data}")
    
    # Lead shown - already covered by $69.99/month subscription
    # Will charge $10 when booking is completed
    for vet in matched_vets:
        print(f"   📊 Lead shown to {vet.name} (included in subscription)")

# ============================================================================
# HEALTH CHECK
# ============================================================================

@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "vets_in_network": len(MOCK_VETS)
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
