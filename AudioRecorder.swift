//
//  AudioRecorder.swift
//  VetScribe
//
//  Handles audio recording and transcription
//

import Foundation
import AVFoundation
import SwiftUI

class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recordingTime = "00:00"
    @Published var audioLevel: Float = 0.0
    @Published var transcript = ""
    
    private var audioRecorder: AVAudioRecorder?
    private var recordingStartTime: Date?
    private var timer: Timer?
    private var levelTimer: Timer?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording-\(Date().timeIntervalSince1970).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            recordingStartTime = Date()
            
            startTimers()
            simulateTranscription()
            
            print("Recording started: \(audioFilename)")
        } catch {
            print("Could not start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        stopTimers()
        
        // In a production app, send the recording to an AI transcription service
        // Options: OpenAI Whisper, AssemblyAI, Google Speech-to-Text, AWS Transcribe Medical
        processRecording()
        
        print("Recording stopped")
    }
    
    private func startTimers() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateRecordingTime()
        }
        
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateAudioLevel()
        }
    }
    
    private func stopTimers() {
        timer?.invalidate()
        timer = nil
        levelTimer?.invalidate()
        levelTimer = nil
        recordingTime = "00:00"
        audioLevel = 0.0
    }
    
    private func updateRecordingTime() {
        guard let startTime = recordingStartTime else { return }
        let elapsed = Date().timeIntervalSince(startTime)
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        recordingTime = String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func updateAudioLevel() {
        audioRecorder?.updateMeters()
        if let recorder = audioRecorder {
            let normalizedLevel = pow(10, recorder.averagePower(forChannel: 0) / 20)
            audioLevel = max(0.0, min(1.0, normalizedLevel))
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func processRecording() {
        // TODO: Integrate with AI transcription service
        // Example services:
        // - OpenAI Whisper API
        // - AssemblyAI
        // - Google Cloud Speech-to-Text
        // - AWS Transcribe Medical (specialized for medical terminology)
        
        print("Processing recording with AI transcription...")
    }
    
    private func simulateTranscription() {
        // Simulate live transcription for demo purposes
        let samplePhrases = [
            "Patient is Thunder, eight-year-old Thoroughbred gelding.",
            "Owner reports right front limb lameness, grade two out of five.",
            "Noticed three days ago after dressage training session.",
            "No witnessed trauma reported.",
            "On physical examination, mild sensitivity on palpation of flexor tendons.",
            "No visible swelling or heat in distal limb.",
            "Positive response to flexion test of right front fetlock.",
            "Lameness more pronounced at trot than at walk."
        ]
        
        var index = 0
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] timer in
            guard let self = self, self.isRecording, index < samplePhrases.count else {
                timer.invalidate()
                return
            }
            
            self.transcript += samplePhrases[index] + "\n\n"
            index += 1
        }
    }
}

// MARK: - Request Microphone Permission
extension AudioRecorder {
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
}
