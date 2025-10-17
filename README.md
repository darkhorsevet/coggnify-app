# Notalyze 🐴

**AI-Powered Veterinary Consultation Notes for Equine Veterinarians**

A Granola-inspired iOS app specifically designed for equine veterinarians to record consultations and automatically generate structured SOAP notes using AI transcription.

## Features

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

3. **Configure microphone permissions:**
   - Open `Info.plist`
   - Add the following key:
     ```
     Privacy - Microphone Usage Description
     ```
   - Value: `"Notalyze needs microphone access to record veterinary consultations"`

4. **Build and run:**
   - Select your target device or simulator
   - Press ⌘+R to build and run

## Usage

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

## AI Integration (To Be Implemented)

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

- [ ] iCloud sync across devices
- [ ] Photo/video attachment support
- [ ] Offline mode with sync
- [ ] Integration with practice management software
- [ ] Client communication features
- [ ] Appointment scheduling
- [ ] Medication tracking
- [ ] Invoice generation

## License

This is a custom project created for equine veterinary practice use.

## Support

For setup assistance or customization requests, contact your development team.

---

**Built for veterinarians, by developers who care about animal health. 🐴**
