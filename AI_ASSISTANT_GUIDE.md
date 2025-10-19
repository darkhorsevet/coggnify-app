# AI Field Assistant Guide

## Overview

The **AI Field Assistant** is like having a senior equine veterinarian in your pocket. Perfect for those 2 AM emergency calls where you need quick reference, drug calculations, or step-by-step guidance.

## Perfect For

### 🚨 Emergency Situations
- **Colic at 2 AM** - "Walk me through severity assessment"
- **Severe laceration** - "Is this a referral case?"
- **Choke emergency** - "What's the protocol?"
- **Lameness** - "Help me grade this"

### 💊 Drug Calculations
- **In the field** - "What's the flunixin dose for 520kg?"
- **Quick reference** - "Penicillin dosing protocol?"
- **Safety checks** - "Can I give bute with this?"

### 🩺 Clinical Decision Support
- **Differential diagnosis** - "Horse with acute lameness and heat in fetlock"
- **Treatment protocols** - "Best approach for eye ulcer?"
- **Vital signs** - "Is 68 bpm high for a colic?"

## How to Use

### 1. Emergency Quick Actions

When you first open the AI Assistant, you'll see 6 emergency buttons:

#### 🚨 Colic Assessment
Instant access to:
- Vital sign ranges
- Pain grading system
- Red flags for surgical referral
- Step-by-step examination guide
- When to tube for reflux

#### 🩹 Laceration Management
Covers:
- Synovial structure assessment
- Primary vs delayed closure decision
- Wound cleaning protocols
- When to refer
- Antibiotic selection

#### 😰 Choke Protocol
Complete guide to:
- Initial assessment
- Sedation protocols
- NG tube technique
- Post-resolution care
- Aspiration prevention

#### 🤕 Lameness Evaluation
Systematic approach:
- Grading lameness
- Flexion test interpretation
- Localization techniques
- Common causes by location

#### 👁️ Eye Emergency
Critical information:
- Exam techniques
- Ulcer staining
- Uveitis vs trauma
- Emergency medications
- Referral criteria

#### 💊 Drug Calculator
Instant dosing for:
- NSAIDs (flunixin, bute, firocoxib)
- Antibiotics (penicillin, gentamicin, SMZs)
- Sedatives (xylazine, detomidine, ace)
- By weight with safety notes

### 2. Voice Input (Hands-Free!)

**Perfect when your hands are dirty or busy:**

1. Tap the **microphone button** 🎤
2. Speak your question naturally
3. AI transcribes and responds
4. Tap again to stop

**Example voice commands:**
- "What's the banamine dose for a four-fifty kilo horse?"
- "Walk me through colic severity assessment"
- "Is sixty-eight beats per minute high for colic?"

### 3. Chat Interface

**Type or speak naturally:**
- "My horse has 72 bpm, dark gums, and no gut sounds. Surgical?"
- "How much penicillin for a 600kg draft horse?"
- "Step-by-step wound lavage technique"

**AI provides:**
- Structured responses with bullet points
- Dosages with safety warnings
- Step-by-step protocols
- Red flags and referral criteria
- Follow-up questions

## Example Conversations

### Colic Emergency

**You:** "Horse with severe colic, HR 68, no gut sounds, been down for 2 hours"

**AI:**
```
🚨 RED FLAGS PRESENT - Consider immediate referral

Critical Findings:
• HR 68 bpm (normal: 28-44) - significant elevation
• Absent gut sounds - concerning for obstruction
• 2 hours duration - prolonged pain

Immediate Actions:
1. Pass nasogastric tube NOW
   - Check for reflux
   - If >2L reflux = surgical indication

2. Rectal examination
   - Distended small intestine?
   - Impaction palpable?
   - Gas distension?

3. Cardiovascular status
   - Mucous membranes color/CRT
   - Peripheral pulses

4. Pain control (if no contraindications)
   - Flunixin 1.1 mg/kg IV
   - Xylazine 0.5 mg/kg IV

STRONG SURGICAL CANDIDATE
Contact referral hospital NOW

What did you find on rectal exam?
```

### Drug Dosing

**You:** "Flunixin dose for 480kg horse?"

**AI:**
```
Flunixin Meglumine (Banamine) Dosage:

Standard Dose: 1.1 mg/kg

For 480kg horse: 528mg
= 10.5mL of 50mg/mL solution

Routes:
• IV (preferred) - immediate onset
• IM - AVOID in neck (clostridial risk)
• PO - paste formulation available

Frequency: q12-24h depending on severity
Duration: Maximum 5 consecutive days

⚠️ Warnings:
- Monitor for GI ulceration with prolonged use
- Avoid in late-term pregnant mares
- Check competition withdrawal times
- Can mask surgical colic - assess carefully first

Need help with anything else?
```

### Laceration Assessment

**You:** "Deep laceration over lateral hock, can see joint?"

**AI:**
```
🚨 POTENTIAL SYNOVIAL INVOLVEMENT - High Priority

Critical Assessment:
1. Joint Communication Test
   ✓ Clip and prep area sterile
   ✓ Insert needle into tarsocrural joint
   ✓ Inject sterile saline
   ✓ Does it leak from wound? = communication

2. If joint involved:
   - IMMEDIATE referral indicated
   - Septic arthritis risk is VERY HIGH
   - Regional limb perfusion with antibiotics
   - Lavage and arthroscopy likely needed

3. Temporary Management (transport to referral):
   - Sterile bandage immediately
   - Broad-spectrum antibiotics IV NOW
     • Gentamicin 6.6 mg/kg IV
     • Penicillin 22,000 IU/kg IV
   - NSAIDs for pain/inflammation
   - Tetanus prophylaxis if needed

⚠️ Time is critical for synovial structures
Contact referral hospital before you travel

What did the joint communication test show?
```

## AI Integration

The assistant is ready for integration with:

### Option 1: OpenAI GPT-4 (Recommended)
```swift
// In AIAssistantManager.swift
private func getAIResponse(for message: String) async throws -> String {
    let messages: [[String: String]] = [
        ["role": "system", "content": systemPrompt],
        ["role": "user", "content": message]
    ]
    
    let response = try await openAI.chat(
        model: "gpt-4-turbo",
        messages: messages,
        temperature: 0.7,
        maxTokens: 800
    )
    
    return response.choices[0].message.content
}
```

**Why GPT-4:**
- Best medical reasoning
- Understands veterinary context
- Structured responses
- Cost: ~$0.03 per query

### Option 2: Anthropic Claude
```swift
let response = try await anthropic.message(
    model: "claude-3-opus",
    messages: [
        .init(role: "user", content: message)
    ],
    system: systemPrompt,
    maxTokens: 800
)
```

**Why Claude:**
- Excellent safety guardrails
- Good at structured output
- Detailed explanations
- Cost: ~$0.04 per query

### Option 3: Local Model (Offline)
For situations without cell service, consider:
- **Llama 2** (7B or 13B)
- **Mistral 7B**
- Run on-device with reduced capability

## Voice Recognition

Uses Apple's **Speech Framework**:
- Works offline (after initial setup)
- Very accurate
- Natural language processing
- Multiple languages supported

**Permissions needed:**
- Microphone access
- Speech recognition access

Already configured in `Info.plist`!

## Best Practices

### 1. Be Specific
❌ "Help with colic"
✅ "Horse with 65 bpm, mild colic signs, normal gut sounds. Medical vs surgical?"

### 2. Include Context
❌ "Drug dose?"
✅ "Gentamicin dose for 550kg horse with suspected joint infection?"

### 3. Use Voice in Field
- Hands dirty? Use voice!
- Driving to emergency? Voice!
- Examining horse? Voice!

### 4. Save Important Chats
- Tap "Save to Consultation" 
- Adds AI guidance to case notes
- Reference later or for records

## Safety & Disclaimers

### Important Limitations

⚠️ **The AI Assistant:**
- Is a REFERENCE TOOL, not a replacement for clinical judgment
- Cannot examine the patient
- Cannot smell, see, or feel findings
- May not have latest research
- Should not override your clinical assessment

⚠️ **Always:**
- Verify dosages before administering
- Use your clinical judgment
- Refer when appropriate
- Follow your regional protocols
- Maintain professional liability insurance

⚠️ **Legal:**
- You are responsible for all clinical decisions
- AI provides reference information only
- Not a substitute for continuing education
- Consult specialists when needed

### When to NOT Rely on AI

1. **True life-threatening emergencies**
   - Severe hemorrhage
   - Respiratory failure
   - Anaphylaxis
   
2. **Legal/regulatory questions**
   - Drug withdrawal times (check official sources)
   - Controlled substances
   - Reporting requirements

3. **Novel/unusual cases**
   - Rare diseases
   - Unusual presentations
   - Species-specific questions for non-horses

## Customization

### Adding Your Protocols

Edit `systemPrompt` in `AIAssistantManager.swift`:

```swift
private let systemPrompt = """
You are an expert equine veterinarian...

Regional Protocols:
- Our practice uses X for colic pain control
- We refer to [Hospital Name] for surgical colics
- Our preferred antibiotic for wounds is Y

Custom Guidelines:
[Add your practice-specific protocols]
"""
```

### Adding New Emergency Buttons

In `AIAssistantView.swift`:

```swift
EmergencyButton(
    icon: "heart.circle.fill",
    title: "Cardiac Emergency",
    color: .red,
    action: { assistantManager.loadEmergencyProtocol(.cardiac) }
)
```

Then add to `EmergencyProtocol` enum in `AIAssistantManager.swift`.

## Cost Estimates

### Per Query Costs

**OpenAI GPT-4:**
- Input: ~100 tokens = $0.001
- Output: ~500 tokens = $0.015
- **Total per query: ~$0.016**

**Anthropic Claude 3:**
- Similar pricing structure
- **Total per query: ~$0.015-0.04**

### Monthly Usage Estimates

**Light use** (5 queries/day):
- 150 queries/month
- Cost: ~$2.40/month

**Moderate use** (15 queries/day):
- 450 queries/month  
- Cost: ~$7.20/month

**Heavy use** (30 queries/day):
- 900 queries/month
- Cost: ~$14.40/month

**Way cheaper than a reference book! 📚**

## Offline Capability

For areas with poor cell service:

### Option 1: Cache Common Queries
- Store frequent questions/answers locally
- Update cache when online
- Fall back to cache when offline

### Option 2: Local LLM
- Use Llama 2 7B model
- Run on-device (requires good iPhone)
- Reduced capability but works offline

### Option 3: Hybrid Approach
- Critical protocols stored locally
- AI enhancement when online

## Real-World Scenarios

### Scenario 1: 2 AM Colic Call

You're woken up at 2 AM. Client says horse is colicking.

1. **Drive to barn** (30 mins)
2. **Open AI Assistant via voice:** "Colic assessment protocol"
3. **Review checklist** while driving (passenger reads)
4. **Arrive prepared** with protocol in mind
5. **During exam, ask:** "HR is 52, gut sounds present but quiet, mild pain. Medical colic?"
6. **AI confirms:** Medical management appropriate
7. **Ask:** "Flunixin dose for 480kg?"
8. **Treat with confidence**

### Scenario 2: Severe Laceration

Horse kicked through fence, deep wound over carpus.

1. **Assess wound** - deep, near joint
2. **Voice ask:** "Laceration over carpus, can't tell if joint involved, what test?"
3. **AI suggests:** Joint communication test
4. **Perform test** - positive communication
5. **Ask:** "Joint communication positive, carpus. Referral?"
6. **AI confirms:** Yes, refer immediately
7. **Ask:** "Antibiotics for transport?"
8. **AI provides:** Gentamicin + Penicillin dosing
9. **Call referral hospital** while driving

### Scenario 3: Drug Dosing Verification

Client's horse needs antibiotics, you're second-guessing your dosing.

1. **Open AI Assistant**
2. **Type:** "Trimethoprim-sulfa dose for 625kg warmblood with pneumonia?"
3. **AI provides:** Dose, frequency, duration, monitoring
4. **Verify your calculation:** ✓ Correct
5. **Proceed with confidence**

## Tips for Busy Vets

### Save Time
- **Voice while driving** to emergency calls
- **Quick drug checks** instead of looking up references
- **Protocol reminders** for cases you don't see often

### Improve Care
- **Double-check dosing** before administering
- **Decision support** for referral decisions
- **Systematic approach** to emergencies

### Reduce Stress
- **24/7 reference** even when books are in truck
- **Quick answers** = faster patient care
- **Confidence** in emergency decisions

## Future Enhancements

Coming soon:
- [ ] Image recognition (send photos of wounds/x-rays)
- [ ] Integration with consultation notes
- [ ] Offline mode with local LLM
- [ ] Custom protocol templates
- [ ] Drug interaction checker
- [ ] Regional disease alerts
- [ ] Client education sheet generator

---

**This is a game-changer for field vets. You're never alone anymore! 🐴🤖**

Questions? Need help setting up? Let's make Notalyze work for YOUR practice!
