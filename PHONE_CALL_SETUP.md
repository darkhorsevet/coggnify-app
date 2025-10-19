# Phone Call Recording Setup Guide

## Overview

Notalyze now includes **automatic phone call recording** similar to Granola. When you're on a call with a client, the app detects it and offers to record, then uses AI to generate summaries and action items.

## How It Works

### 1. Call Detection
The app uses **CallKit** to detect when you're in a phone call:
- Monitors incoming and outgoing calls
- Tracks call duration
- Detects when calls end

### 2. Recording Process
When a call is detected:
1. Push notification appears
2. Tap to open Notalyze
3. See the "Record This Call?" prompt
4. Tap "Start Recording"
5. **Important:** Inform the caller they're being recorded
6. Continue your conversation normally
7. Recording stops automatically when call ends

### 3. AI Processing
After the call:
1. **Transcription** - Full conversation is transcribed
2. **Summary** - 2-3 sentence summary of the call
3. **Action Items** - Tasks extracted with:
   - What needs to be done
   - Who's responsible (vet or client)
   - When it's due
4. **Consultation Created** - Appears in your list

## Technical Implementation

### Required Frameworks
```swift
import CallKit           // Call detection
import AVFoundation      // Audio recording
import UserNotifications // Alerts
```

### Key Files

#### CallManager.swift
- Detects phone calls via CallKit
- Manages recording state
- Processes audio with AI
- Extracts action items

#### CallRecordingView.swift
- "Phone Calls" tab UI
- Shows call status
- Recording controls
- Real-time call timer

#### PhoneConsultationDetailView.swift
- Displays call summary
- Shows action items (checkable)
- Full transcript view
- Export options

### Info.plist Permissions

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Notalyze needs microphone access to record veterinary consultations and phone calls</string>

<key>UIBackgroundModes</key>
<array>
    <string>audio</string>  <!-- Keep recording in background -->
    <string>voip</string>   <!-- VoIP background handling -->
</array>
```

## AI Integration

### Step 1: Transcription
Integrate with a speech-to-text service in `CallManager.swift`:

```swift
private func transcribeAudio(fileURL: URL) async throws -> String {
    // Option 1: OpenAI Whisper
    let audioData = try Data(contentsOf: fileURL)
    let response = try await openAI.transcribe(
        audio: audioData,
        model: "whisper-1"
    )
    return response.text
    
    // Option 2: AssemblyAI (better for phone quality)
    let assembly = AssemblyAI(apiKey: "your-key")
    let transcript = try await assembly.transcribe(fileURL)
    return transcript.text
}
```

### Step 2: Generate Summary
Use GPT-4 to create a concise summary:

```swift
private func generateCallSummary(transcript: String) async throws -> String {
    let prompt = """
    You are a veterinary assistant. Summarize this phone consultation in 2-3 sentences.
    Focus on: patient name, chief complaint, and planned action.
    
    Transcript:
    \(transcript)
    """
    
    let response = try await openAI.chat(
        messages: [.user(prompt)],
        model: "gpt-4"
    )
    return response.message.content
}
```

### Step 3: Extract Action Items
Pull out tasks automatically:

```swift
private func extractActionItems(transcript: String) async throws -> [ActionItem] {
    let prompt = """
    Extract action items from this veterinary phone call.
    Return as JSON array with fields: task, responsibleParty, deadline
    
    Transcript:
    \(transcript)
    """
    
    let response = try await openAI.chat(
        messages: [.user(prompt)],
        model: "gpt-4",
        responseFormat: .json
    )
    
    let items = try JSONDecoder().decode([ActionItem].self, from: response.data)
    return items
}
```

## Testing

### On Simulator
⚠️ **Call detection requires a real device.** Simulator cannot detect calls.

### On Real Device
1. Build to your iPhone
2. Make or receive a test call
3. App should show recording prompt
4. Test the full flow

### Mock Testing
The app includes simulated transcripts for development:
- Edit `transcribeAudio()` to return sample data
- Test AI processing without making real calls

## Legal Considerations

### Two-Party Consent
In many jurisdictions, **both parties must consent** to being recorded.

**Best Practices:**
1. Inform caller at start: "This call is being recorded for medical records"
2. Get verbal consent
3. Document consent in notes
4. Follow your state/country laws

### States Requiring Two-Party Consent (USA)
- California
- Connecticut
- Florida
- Illinois
- Maryland
- Massachusetts
- Montana
- New Hampshire
- Pennsylvania
- Washington

### HIPAA Compliance
- Store recordings securely
- Encrypt audio files
- Implement access controls
- Have retention/deletion policies

## Common Issues

### "Recording Not Starting"
- Check microphone permissions
- Ensure you're in an active call
- Check audio session configuration

### "Call Not Detected"
- Requires real device (not simulator)
- Check CallKit delegate is set up
- Verify Info.plist permissions

### "Poor Audio Quality"
- Phone calls are compressed (8kHz typically)
- Use AssemblyAI's phone call model
- Enable noise reduction in recording settings

### "Action Items Not Extracting"
- Improve AI prompt with examples
- Use GPT-4 (not 3.5) for better results
- Add veterinary context to prompt

## Cost Considerations

### Transcription Costs (per hour)
- OpenAI Whisper: ~$0.36/hour
- AssemblyAI: ~$0.65/hour
- Google Speech: ~$1.44/hour
- AWS Transcribe Medical: ~$2.50/hour (but better for medical terms)

### GPT-4 for Summaries
- ~$0.03 per call summary
- ~$0.05 per action item extraction

### Optimization Tips
1. Cache common veterinary terms
2. Batch process multiple calls
3. Use cheaper models for simple tasks
4. Only transcribe flagged calls

## Example Client Conversation

**Client:** "Hi Dr. Smith, Thunder is limping badly on his front left leg."

**Vet (You):** "Just so you know, I'm recording this call for your medical records. Is that okay?"

**Client:** "Yes, that's fine."

**Vet:** "Great. When did the limping start?"

**Client:** "Yesterday after our trail ride..."

→ **App captures everything**
→ **AI generates:**
- Summary: "Emergency consultation for Thunder regarding acute left front limb lameness post-trail ride. Scheduled farm visit for tomorrow 9 AM."
- Action Items:
  - ✓ Schedule farm visit (Vet, Tomorrow 9 AM)
  - ✓ Cold hose leg 2x daily (Client, Until visit)
  - ✓ Stall rest (Client, 24 hours)

## Next Steps

1. **Add your AI API keys** to the app
2. **Implement the three AI methods** in `CallManager.swift`
3. **Test with real calls** on your device
4. **Customize action item prompts** for your practice style
5. **Set up proper data retention** policies

---

**This feature is a game-changer for busy equine vets.** No more frantically taking notes during emergency calls! 🐴📞
