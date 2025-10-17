//
//  AIAssistantManager.swift
//  Notalyze
//
//  Manages AI Assistant chat and emergency protocols
//

import Foundation
import AVFoundation
import Speech

class AIAssistantManager: NSObject, ObservableObject {
    @Published var messages: [AssistantMessage] = []
    @Published var isProcessing = false
    @Published var isListening = false
    @Published var showingEstimate = false
    @Published var generatedEstimate: VetEstimate?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // System context for veterinary knowledge
    private let systemPrompt = """
    You are an expert equine veterinarian AI assistant designed to help veterinarians in field emergency situations.
    
    Your role:
    - Provide quick, accurate clinical decision support
    - Help with drug dosage calculations
    - Guide through emergency protocols step-by-step
    - Suggest differential diagnoses
    - Reference normal vital ranges
    - Offer procedure guidance
    
    Guidelines:
    - Be concise but thorough
    - Use bullet points for clarity
    - Always mention when to refer/escalate
    - Include safety warnings when relevant
    - Cite dosages with weight ranges
    - Use veterinary terminology appropriately
    
    Remember: You're assisting licensed veterinarians, not replacing them. When in doubt, recommend consulting specialists or referral.
    """
    
    override init() {
        super.init()
        requestSpeechPermission()
    }
    
    // MARK: - Chat Management
    
    func sendMessage(_ text: String) {
        let userMessage = AssistantMessage(content: text, isUser: true)
        messages.append(userMessage)
        
        isProcessing = true
        
        // Process with AI
        Task {
            do {
                let response = try await getAIResponse(for: text)
                await MainActor.run {
                    let aiMessage = AssistantMessage(content: response, isUser: false)
                    messages.append(aiMessage)
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    let errorMessage = AssistantMessage(
                        content: "I'm having trouble connecting right now. Please check your internet connection.",
                        isUser: false
                    )
                    messages.append(errorMessage)
                    isProcessing = false
                }
            }
        }
    }
    
    func clearChat() {
        messages.removeAll()
    }
    
    // MARK: - Emergency Protocols
    
    func loadEmergencyProtocol(_ type: EmergencyProtocol) {
        let protocolMessage = type.initialMessage
        sendMessage(protocolMessage)
    }
    
    // MARK: - AI Integration
    
    private func getAIResponse(for message: String) async throws -> String {
        // TODO: Integrate with OpenAI GPT-4, Anthropic Claude, or similar
        // Example using OpenAI:
        /*
        let messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": message]
        ]
        
        let response = try await openAI.chat(
            model: "gpt-4",
            messages: messages,
            temperature: 0.7,
            maxTokens: 500
        )
        
        return response.choices[0].message.content
        */
        
        // Mock responses for development
        return getMockResponse(for: message)
    }
    
    private func getMockResponse(for message: String) -> String {
        let lowercased = message.lowercased()
        
        // Drug dosage questions
        if lowercased.contains("flunixin") || lowercased.contains("banamine") {
            return """
            **Flunixin Meglumine (Banamine) Dosage:**
            
            **Standard Dose:** 1.1 mg/kg (0.5 mg/lb)
            
            **For a 450kg horse:** 495mg (approximately 9-10mL of 50mg/mL solution)
            
            **Routes:**
            • IV (preferred) - fastest onset
            • IM - risk of clostridial myositis
            • PO - paste formulation available
            
            **Frequency:** q12-24h depending on severity
            
            **Duration:** Maximum 5 consecutive days
            
            ⚠️ **Warnings:**
            - Avoid IM in neck muscles
            - Monitor for GI ulceration with prolonged use
            - Avoid in pregnant mares near term
            - Check withdrawal times if competing
            
            Need help calculating for a different weight?
            """
        }
        
        // Colic assessment
        if lowercased.contains("colic") {
            return """
            **Colic Severity Assessment:**
            
            **Vital Signs to Check:**
            ✓ Heart rate (normal: 28-44 bpm)
            ✓ Respiratory rate (normal: 8-16 bpm)
            ✓ Temperature (normal: 99-101°F)
            ✓ Mucous membranes (color, CRT)
            ✓ Gut sounds (all 4 quadrants)
            
            **Pain Assessment:**
            • Grade 1: Mild discomfort, looking at flanks
            • Grade 2: Pawing, lying down occasionally
            • Grade 3: Rolling, thrashing
            • Grade 4: Violent, uncontrollable
            
            **Red Flags for Referral:**
            🚨 HR >60bpm and rising
            🚨 Absent gut sounds
            🚨 Reflux on nasogastric tube
            🚨 Dark/toxic mucous membranes
            🚨 Severe unrelenting pain
            
            **Next Steps:**
            1. Perform rectal exam
            2. Pass nasogastric tube
            3. Assess cardiovascular status
            4. Consider analgesics if no contraindications
            
            What specific aspect would you like to explore?
            """
        }
        
        // Laceration management
        if lowercased.contains("laceration") || lowercased.contains("wound") {
            return """
            **Laceration Management Protocol:**
            
            **Initial Assessment:**
            1. Location and depth
            2. Involvement of synovial structures
            3. Neurovascular compromise
            4. Contamination level
            5. Time since injury
            
            **Immediate Actions:**
            ✓ Control bleeding (direct pressure)
            ✓ Cover with sterile gauze if possible
            ✓ Avoid aggressive cleaning initially
            ✓ Assess tetanus status
            
            **Synovial Involvement Testing:**
            • Joint effusion?
            • Joint communication (needle test)
            • Tendon sheath involvement
            
            **Treatment Approach:**
            
            **Clean wounds (<6hrs old):**
            - Primary closure candidate
            - Clip and clean carefully
            - Lavage thoroughly
            - Primary sutures if no tension
            
            **Contaminated/Old wounds:**
            - Delayed primary closure
            - Debride non-viable tissue
            - Bandage and second intention
            
            **Medications:**
            • Tetanus prophylaxis
            • Broad-spectrum antibiotics
            • NSAIDs for inflammation
            • Consider regional perfusion if limb wound
            
            🚨 **Refer if:**
            - Joint/tendon sheath involved
            - Major vessel damage
            - Extensive tissue loss
            - Penetrating chest/abdomen
            
            What's the location of the laceration?
            """
        }
        
        // Drug calculator
        if lowercased.contains("dose") || lowercased.contains("calculator") || lowercased.contains("weight") {
            return """
            **Drug Dosage Calculator**
            
            Please provide:
            1. Drug name
            2. Horse weight (kg or lbs)
            3. Route of administration
            
            **Common Equine Drugs:**
            
            **NSAIDs:**
            • Flunixin: 1.1 mg/kg IV/IM/PO q12-24h
            • Phenylbutazone: 2-4 mg/kg PO/IV q12h
            • Firocoxib: 0.1 mg/kg PO q24h
            
            **Antibiotics:**
            • Penicillin: 22,000 IU/kg IM q12h
            • Gentamicin: 6.6 mg/kg IV q24h
            • Trimethoprim-Sulfa: 30 mg/kg PO q12h
            
            **Sedation:**
            • Xylazine: 0.5-1.1 mg/kg IV
            • Detomidine: 10-20 mcg/kg IV
            • Acepromazine: 0.02-0.05 mg/kg IV
            
            **Quick Reference:**
            • 1 lb = 0.453 kg
            • 1000 lbs ≈ 454 kg
            • Average horse: 450-550 kg
            
            Which drug do you need help with?
            """
        }
        
        // Choke protocol
        if lowercased.contains("choke") {
            return """
            **Esophageal Obstruction (Choke) Protocol:**
            
            **Assessment:**
            ✓ Food/water draining from nostrils
            ✓ Repeated swallowing attempts
            ✓ Distress level
            ✓ Duration of obstruction
            ✓ Respiratory status
            
            **Immediate Actions:**
            1. **Remove all feed and water**
            2. Keep horse calm and still
            3. Lower head to promote drainage
            4. Do NOT attempt to pass stomach tube initially
            
            **Treatment:**
            
            **Sedation:**
            • Xylazine 0.5-1.0 mg/kg IV
            • Relaxes esophagus and calms horse
            
            **Wait 15-30 minutes** after sedation
            
            **If obstruction persists:**
            • Pass nasogastric tube GENTLY
            • Flush with warm water (small volumes)
            • Apply gentle steady pressure
            • NEVER force the tube
            
            **Medications:**
            • Buscopan 0.3 mg/kg IV (smooth muscle relaxant)
            • NSAIDs after resolution
            • Broad-spectrum antibiotics if aspiration risk
            
            **Post-Resolution:**
            • Keep NPO (nothing by mouth) for 24hrs
            • Introduce water slowly
            • Start with wet feed/soaked pellets
            • Monitor for aspiration pneumonia
            
            🚨 **Refer if:**
            - Obstruction >2 hours
            - Respiratory compromise
            - Unable to pass tube
            - Severe esophageal damage suspected
            
            How long has the horse been choked?
            """
        }
        
        // Default helpful response
        return """
        I'm here to help with emergency field situations! I can assist with:
        
        **Emergency Protocols:**
        • Colic assessment and management
        • Laceration/wound care
        • Choke (esophageal obstruction)
        • Lameness evaluation
        • Eye emergencies
        
        **Clinical Support:**
        • Drug dosage calculations
        • Differential diagnoses
        • Vital sign interpretation
        • Procedure step-by-steps
        
        Try asking a specific question like:
        • "What's the penicillin dose for a 500kg horse?"
        • "Walk me through colic assessment"
        • "How do I manage a severe laceration?"
        
        What can I help you with today?
        """
    }
    
    // MARK: - Voice Input
    
    func startVoiceInput() {
        if isListening {
            stopVoiceInput()
        } else {
            do {
                try startRecording()
                isListening = true
            } catch {
                print("Voice input failed: \(error.localizedDescription)")
            }
        }
    }
    
    func stopVoiceInput() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        isListening = false
    }
    
    private func startRecording() throws {
        // Cancel any ongoing task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "SpeechRecognition", code: -1)
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let transcribedText = result.bestTranscription.formattedString
                
                if result.isFinal {
                    self.sendMessage(transcribedText)
                    self.stopVoiceInput()
                }
            }
            
            if error != nil {
                self.stopVoiceInput()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    private func requestSpeechPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            print("Speech recognition authorization: \(status)")
        }
    }
    
    // MARK: - Estimate Generation
    
    func createEstimate() {
        // Extract conversation text
        let conversationText = messages.map { message in
            "\(message.isUser ? "Vet" : "Echo"): \(message.content)"
        }.joined(separator: "\n\n")
        
        // Generate estimate from conversation
        Task {
            let estimateGen = EstimateGenerator()
            do {
                let estimate = try await estimateGen.generateEstimate(
                    from: conversationText,
                    clientName: "Client", // Would extract from context
                    patientName: "Patient" // Would extract from context
                )
                
                await MainActor.run {
                    generatedEstimate = estimate
                    showingEstimate = true
                }
            } catch {
                print("Failed to generate estimate: \(error)")
            }
        }
    }
}

// MARK: - Assistant Message Model

struct AssistantMessage: Identifiable, Equatable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    init(id: UUID = UUID(), content: String, isUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
}

// MARK: - Emergency Protocol Types

enum EmergencyProtocol {
    case colic
    case laceration
    case choke
    case lameness
    case eyeEmergency
    case drugCalculator
    
    var initialMessage: String {
        switch self {
        case .colic:
            return "I need help with a colic case. Walk me through the assessment."
        case .laceration:
            return "I have a horse with a severe laceration. What's the protocol?"
        case .choke:
            return "Horse is choking. What do I do?"
        case .lameness:
            return "Help me evaluate this lameness systematically."
        case .eyeEmergency:
            return "I have an eye emergency. What should I check?"
        case .drugCalculator:
            return "I need to calculate a drug dosage."
        }
    }
}
