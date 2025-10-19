//
//  CallManager.swift
//  Notalyze
//
//  Manages phone call detection and recording
//

import Foundation
import CallKit
import AVFoundation
import Combine

class CallManager: NSObject, ObservableObject {
    @Published var isInCall = false
    @Published var isRecordingCall = false
    @Published var currentCallDuration: TimeInterval = 0
    @Published var callStartTime: Date?
    @Published var detectedPhoneNumber: String?
    @Published var showCallRecordingPrompt = false
    
    private let callObserver = CXCallObserver()
    private var callTimer: Timer?
    private var audioRecorder: AVAudioRecorder?
    private var audioSession = AVAudioSession.sharedInstance()
    
    override init() {
        super.init()
        setupCallObserver()
        setupNotifications()
    }
    
    // MARK: - Call Detection
    
    private func setupCallObserver() {
        callObserver.setDelegate(self, queue: DispatchQueue.main)
    }
    
    private func setupNotifications() {
        // Listen for audio route changes (when call starts/ends)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioRouteChanged),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }
    
    @objc private func audioRouteChanged(notification: Notification) {
        // Additional call detection through audio route changes
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        switch reason {
        case .newDeviceAvailable, .oldDeviceUnavailable:
            // Call state might have changed
            checkCallState()
        default:
            break
        }
    }
    
    private func checkCallState() {
        // Check if we're in a call
        if !callObserver.calls.isEmpty {
            if !isInCall {
                handleCallStarted()
            }
        } else {
            if isInCall {
                handleCallEnded()
            }
        }
    }
    
    // MARK: - Call Lifecycle
    
    private func handleCallStarted() {
        DispatchQueue.main.async {
            self.isInCall = true
            self.callStartTime = Date()
            self.startCallTimer()
            
            // Show prompt to record call
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showCallRecordingPrompt = true
            }
            
            print("📞 Call detected - Ready to record")
        }
    }
    
    private func handleCallEnded() {
        DispatchQueue.main.async {
            self.isInCall = false
            self.stopCallTimer()
            
            if self.isRecordingCall {
                self.stopRecording()
            }
            
            self.callStartTime = nil
            self.detectedPhoneNumber = nil
            
            print("📞 Call ended")
        }
    }
    
    private func startCallTimer() {
        callTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.callStartTime else { return }
            self.currentCallDuration = Date().timeIntervalSince(startTime)
        }
    }
    
    private func stopCallTimer() {
        callTimer?.invalidate()
        callTimer = nil
        currentCallDuration = 0
    }
    
    // MARK: - Recording
    
    func startRecording() {
        guard isInCall else {
            print("⚠️ Cannot record - not in a call")
            return
        }
        
        do {
            // Configure audio session for recording during call
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
            
            // Create recording file
            let recordingURL = getRecordingFileURL()
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: recordingURL, settings: settings)
            audioRecorder?.record()
            
            isRecordingCall = true
            showCallRecordingPrompt = false
            
            print("🎙️ Started recording call")
            
            // Send notification
            sendLocalNotification(
                title: "Recording Call",
                body: "Notalyze is recording your phone consultation"
            )
            
        } catch {
            print("❌ Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        guard isRecordingCall else { return }
        
        audioRecorder?.stop()
        
        if let recordingURL = audioRecorder?.url {
            processRecording(url: recordingURL)
        }
        
        audioRecorder = nil
        isRecordingCall = false
        
        print("⏹️ Stopped recording call")
    }
    
    private func getRecordingFileURL() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "call_recording_\(Date().timeIntervalSince1970).m4a"
        return documentsPath.appendingPathComponent(fileName)
    }
    
    // MARK: - AI Processing
    
    private func processRecording(url: URL) {
        print("🤖 Processing call recording with AI...")
        
        // This is where you'd integrate with AI services:
        // 1. Transcribe the call (OpenAI Whisper, AssemblyAI, etc.)
        // 2. Generate call summary
        // 3. Extract action items
        // 4. Create structured notes
        
        Task {
            do {
                let transcript = try await transcribeAudio(fileURL: url)
                let summary = try await generateCallSummary(transcript: transcript)
                let actionItems = try await extractActionItems(transcript: transcript)
                
                // Create consultation with call data
                await createPhoneConsultation(
                    transcript: transcript,
                    summary: summary,
                    actionItems: actionItems,
                    audioURL: url
                )
                
            } catch {
                print("❌ AI processing failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - AI Integration (To Be Implemented)
    
    private func transcribeAudio(fileURL: URL) async throws -> String {
        // TODO: Integrate with OpenAI Whisper, AssemblyAI, or similar
        // Example using OpenAI Whisper:
        /*
        let fileData = try Data(contentsOf: fileURL)
        let request = WhisperTranscriptionRequest(
            file: fileData,
            model: "whisper-1",
            language: "en"
        )
        let response = try await openAI.transcribe(request)
        return response.text
        */
        
        // Mock implementation
        return """
        [Simulated transcript]
        Client: Hi Dr. Smith, this is Sarah calling about Thunder. He's been limping on his right front leg for the past two days.
        
        Vet: Thanks for calling Sarah. Can you describe the lameness? Is he weight-bearing?
        
        Client: Yes, he's putting weight on it but he's definitely favoring it. I noticed it after our trail ride on Saturday.
        
        Vet: Okay. Any heat or swelling in the leg or hoof?
        
        Client: A little warmth around the fetlock area, but no obvious swelling.
        
        Vet: Alright. I'd like to come out and examine him tomorrow morning around 10 AM. In the meantime, keep him in his stall with limited movement, and you can cold hose the leg for 20 minutes twice today.
        
        Client: Perfect, I'll do that. Should I give him any bute?
        
        Vet: Let's wait until I examine him tomorrow. I want to see the lameness without any masking from anti-inflammatories.
        
        Client: Got it. See you tomorrow at 10.
        
        Vet: Sounds good. Call me if anything changes before then.
        """
    }
    
    private func generateCallSummary(transcript: String) async throws -> String {
        // TODO: Use GPT-4 or similar to generate summary
        // Example prompt:
        /*
        let prompt = """
        Summarize this veterinary phone consultation in 2-3 sentences:
        
        \(transcript)
        """
        */
        
        return "Phone consultation with Sarah Johnson regarding Thunder's right front limb lameness. Lameness observed for 2 days post-trail ride with mild warmth at fetlock. Farm visit scheduled for tomorrow 10 AM for full examination; cold hosing recommended until then."
    }
    
    private func extractActionItems(transcript: String) async throws -> [ActionItem] {
        // TODO: Use AI to extract action items
        // Example using GPT-4:
        /*
        let prompt = """
        Extract action items from this veterinary call transcript. Format as JSON array with fields: task, responsible_party, deadline.
        
        \(transcript)
        """
        */
        
        return [
            ActionItem(
                task: "Schedule farm visit for Thunder examination",
                responsibleParty: "Veterinarian",
                deadline: "Tomorrow at 10:00 AM",
                isCompleted: false
            ),
            ActionItem(
                task: "Cold hose Thunder's right front leg for 20 minutes, twice today",
                responsibleParty: "Client (Sarah Johnson)",
                deadline: "Today",
                isCompleted: false
            ),
            ActionItem(
                task: "Keep Thunder in stall with limited movement",
                responsibleParty: "Client (Sarah Johnson)",
                deadline: "Until examination",
                isCompleted: false
            ),
            ActionItem(
                task: "Monitor for changes and call if condition worsens",
                responsibleParty: "Client (Sarah Johnson)",
                deadline: "Before tomorrow's visit",
                isCompleted: false
            )
        ]
    }
    
    private func createPhoneConsultation(
        transcript: String,
        summary: String,
        actionItems: [ActionItem],
        audioURL: URL
    ) async {
        // Create a new consultation with phone call data
        print("✅ Created phone consultation with summary and action items")
        
        // Generate estimate from call
        let estimateGen = EstimateGenerator()
        do {
            let estimate = try await estimateGen.generateEstimate(
                from: transcript,
                clientName: "Client", // Extract from call
                patientName: "Patient" // Extract from call
            )
            
            print("💰 Generated estimate: $\(estimate.total)")
            
            // Post notification to create consultation in the app
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NSNotification.Name("CreatePhoneConsultation"),
                    object: nil,
                    userInfo: [
                        "transcript": transcript,
                        "summary": summary,
                        "actionItems": actionItems,
                        "audioURL": audioURL.path,
                        "duration": self.currentCallDuration,
                        "estimate": estimate
                    ]
                )
                
                // Show notification about estimate
                self.sendLocalNotification(
                    title: "Estimate Generated",
                    body: "Estimate for $\(String(format: "%.2f", estimate.total)) created from call"
                )
            }
        } catch {
            print("Failed to generate estimate: \(error)")
        }
    }
    
    // MARK: - Notifications
    
    private func sendLocalNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - CXCallObserverDelegate

extension CallManager: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded {
            handleCallEnded()
        } else if call.isOutgoing || !call.hasConnected {
            // Call is ringing or outgoing
            print("📞 Call in progress...")
        } else if call.hasConnected && !call.hasEnded {
            handleCallStarted()
        }
    }
}

// MARK: - Action Item Model

struct ActionItem: Identifiable, Codable, Hashable {
    let id: UUID
    var task: String
    var responsibleParty: String
    var deadline: String
    var isCompleted: Bool
    
    init(
        id: UUID = UUID(),
        task: String,
        responsibleParty: String,
        deadline: String,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.task = task
        self.responsibleParty = responsibleParty
        self.deadline = deadline
        self.isCompleted = isCompleted
    }
}
