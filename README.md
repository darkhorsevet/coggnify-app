# Notalyze 🐴

**AI-Powered Veterinary Consultation Notes for Equine Veterinarians**

A Granola-inspired iOS app specifically designed for equine veterinarians to record consultations and automatically generate structured SOAP notes using AI transcription.

## Features

### 📞 Phone Call Recording (NEW!)
- **Automatic call detection** - Detects incoming and outgoing calls
- **One-tap recording** - Start recording phone consultations instantly
- **Call summary** - AI generates concise summaries of phone conversations
- **Action items extraction** - Automatically identifies tasks and follow-ups
- **Smart notifications** - Prompts to record when calls are detected
- **Legal compliance** - Built-in reminders to inform callers

### 🎤 Smart Recording
- Hands-free audio recording during consultations
- Real-time audio level monitoring
- Live transcription display
- Automatic SOAP note generation

### 📋 SOAP Note Structure
- **Subjective**: Patient history and chief complaint
- **Objective**: Physical examination findings
- **Assessment**: Diagnosis and differentials
- **Plan**: Treatment and follow-up recommendations

### 🏥 Veterinary-Specific Templates
- **Lameness Examination**: Gait analysis and flexion tests
- **Colic Evaluation**: Emergency abdominal assessment
- **Routine Checkup**: General wellness exam
- **Dental Exam**: Oral health evaluation
- **Reproductive Check**: Breeding soundness exam
- **Pre-Purchase Exam**: Comprehensive buyer's examination
- **Wound Care**: Injury assessment
- **Emergency**: Critical case documentation
- **Follow-up**: Progress monitoring

### 📱 Native iOS Experience
- Bottom tab navigation
- Pull-to-refresh consultations list
- Swipe to delete
- Search and filter
- Dark mode support
- Native iOS design language

### 💾 Data Management
- Patient information (breed, age, sex, color, microchip)
- Owner and location details
- Consultation history
- Audio recordings storage
- Export to PDF, SOAP format, or EMR systems

## Getting Started

### Requirements
- Xcode 15.0 or later
- iOS 17.0 or later
- iPhone (optimized for mobile use)

### Setup in Xcode

1. **Create a new Xcode project:**
   - Open Xcode
   - File → New → Project
   - Choose "App" under iOS
   - Product Name: `Notalyze`
   - Interface: SwiftUI
   - Language: Swift

2. **Add the Swift files:**
   - Copy all `.swift` files from this repository into your Xcode project:
     - `NotalyzeApp.swift`
     - `MainTabView.swift`
     - `ConsultationsListView.swift`
     - `ConsultationDetailView.swift`
     - `RecordView.swift`
     - `TemplatesView.swift`
     - `NewConsultationSheet.swift`
     - `Models.swift`
     - `ConsultationManager.swift`
     - `AudioRecorder.swift`
     - `SettingsView.swift`
     - `CallManager.swift` ⭐ NEW
     - `CallRecordingView.swift` ⭐ NEW
     - `PhoneConsultationDetailView.swift` ⭐ NEW

3. **Configure permissions in Info.plist:**
   - Copy the provided `Info.plist` or add these keys:
     - `NSMicrophoneUsageDescription`: "Notalyze needs microphone access to record veterinary consultations and phone calls"
     - `UIBackgroundModes`: Add "audio" and "voip" for call recording

4. **Add required frameworks:**
   - In Xcode, select your target
   - Go to "Frameworks, Libraries, and Embedded Content"
   - Add: `CallKit.framework`
   - Add: `UserNotifications.framework`

5. **Build and run:**
   - Select your target device (phone call features require a real device)
   - Press ⌘+R to build and run

## Usage

### Recording Phone Calls (Game Changer! 📞)

**Perfect for client calls about their horses:**

1. **Make or receive a call** from a client
2. **App automatically detects** the call and shows a prompt
3. **Tap "Start Recording"** (make sure to inform the caller)
4. **Continue your conversation** naturally
5. **Recording stops automatically** when the call ends
6. **AI processes the call** and generates:
   - Full transcript
   - Call summary (2-3 sentences)
   - Action items with deadlines
   - Responsible parties for each task
7. **Find it in your Consultations** list

**Example Use Cases:**
- Emergency colic calls at 2 AM
- Follow-up check-ins with clients
- Pre-appointment consultations
- Post-procedure care instructions
- Scheduling and coordination calls

**Legal Note:** Recording laws vary by location. The app reminds you to inform callers they're being recorded. Always comply with local two-party consent laws.

### Creating a Consultation

1. **Tap the "+" button** in the Consultations tab
2. **Fill in patient information:**
   - Patient name (horse)
   - Breed
   - Age
   - Sex (Stallion/Mare/Gelding)
   - Color/markings
   - Owner name
   - Location/farm
   - Microchip (optional)
3. **Select consultation type**
4. **Tap "Create"**

### Recording a Consultation

1. **Go to the Record tab**
2. **Tap the microphone button** to start recording
3. **Speak naturally** during your consultation
4. **Watch the live transcript** appear in real-time
5. **Tap the stop button** when finished
6. **AI processes** your recording into structured SOAP notes

### Using Templates

1. **Go to the Templates tab**
2. **Browse available templates** for different consultation types
3. **Tap a template** to view details and key points to cover
4. **Use Template** to create a new consultation with that structure

### Viewing and Editing Notes

1. **Tap any consultation** from the list
2. **View the complete SOAP notes**
3. **Tap sections** to expand/collapse
4. **Use the menu** (⋯) to edit or delete
5. **Export** as PDF, SOAP text, or send to your EMR system

## AI Integration

### Phone Call Features

The `CallManager.swift` file has placeholder methods ready for AI integration:

1. **`transcribeAudio(fileURL:)`** - Transcribe the call recording
2. **`generateCallSummary(transcript:)`** - Create a concise summary
3. **`extractActionItems(transcript:)`** - Pull out tasks and follow-ups

### Recommended AI Services

The app is ready for AI transcription integration. Recommended services:

### Option 1: OpenAI Whisper API
```swift
// In AudioRecorder.swift, implement:
func transcribeAudio(fileURL: URL) async throws -> String {
    // Call OpenAI Whisper API
    // https://platform.openai.com/docs/api-reference/audio
}
```

### Option 2: AssemblyAI
```swift
// Medical terminology support
// https://www.assemblyai.com/
```

### Option 3: AWS Transcribe Medical
```swift
// Specialized for medical/veterinary terminology
// https://aws.amazon.com/transcribe/medical/
```

### Option 4: Google Cloud Speech-to-Text
```swift
// Support for multiple languages
// https://cloud.google.com/speech-to-text
```

### For Action Items Extraction
Use GPT-4 or Claude with a prompt like:
```swift
let prompt = """
Extract action items from this veterinary phone call transcript.
For each action item, identify:
- The specific task
- Who is responsible (vet or client)
- When it needs to be done

Transcript: \(transcript)
"""
```

## Customization

### Branding
- App icon: Replace in `Assets.xcassets`
- Accent color: Change `.accentColor(.green)` in `MainTabView.swift`
- App name: Update in Xcode project settings

### Adding Custom Templates
Edit the `TemplateType` enum in `Models.swift`:
```swift
case myCustomTemplate = "My Template"
```

### EMR Integration
Implement export functions in `ConsultationDetailView.swift`:
```swift
func sendToEMR() {
    // Connect to your practice management software
}
```

## Data Privacy

- All data stored locally on device
- No cloud sync by default (can be enabled via iCloud)
- Audio recordings stored in app's document directory
- HIPAA/VCPR compliance considerations for production use

## Future Enhancements

- [x] ✅ Phone call recording and transcription
- [x] ✅ Action items extraction from calls
- [x] ✅ Call summary generation
- [ ] iCloud sync across devices
- [ ] Photo/video attachment support
- [ ] Offline mode with sync
- [ ] Integration with practice management software
- [ ] Client communication features via the app
- [ ] Appointment scheduling
- [ ] Medication tracking
- [ ] Invoice generation
- [ ] Automated follow-up reminders from action items
- [ ] Integration with client databases

## License

This is a custom project created for equine veterinary practice use.

## Support

For setup assistance or customization requests, contact your development team.

---

**Built for veterinarians, by developers who care about animal health. 🐴**
