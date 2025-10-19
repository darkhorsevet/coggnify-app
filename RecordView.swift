//
//  RecordView.swift
//  Notalyze
//
//  Recording interface for consultations
//

import SwiftUI

struct RecordView: View {
    @EnvironmentObject var audioRecorder: AudioRecorder
    @EnvironmentObject var consultationManager: ConsultationManager
    @State private var showingNewConsultationSheet = false
    @State private var currentConsultation: Consultation?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: audioRecorder.isRecording ? 
                        [Color.red.opacity(0.1), Color.orange.opacity(0.1)] :
                        [Color.green.opacity(0.1), Color.mint.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Recording Status
                        VStack(spacing: 16) {
                            Text(audioRecorder.isRecording ? "Recording..." : "Ready to Record")
                                .font(.title3.bold())
                                .foregroundColor(audioRecorder.isRecording ? .red : .secondary)
                            
                            // Record Button
                            Button(action: toggleRecording) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            audioRecorder.isRecording ?
                                            LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                            LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                        .frame(width: 140, height: 140)
                                        .shadow(color: (audioRecorder.isRecording ? Color.red : Color.green).opacity(0.4), radius: 20)
                                    
                                    Image(systemName: audioRecorder.isRecording ? "stop.fill" : "mic.fill")
                                        .font(.system(size: 56))
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(.plain)
                            .scaleEffect(audioRecorder.isRecording ? 1.05 : 1.0)
                            .animation(
                                audioRecorder.isRecording ? 
                                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true) : 
                                    .default,
                                value: audioRecorder.isRecording
                            )
                            
                            // Timer
                            Text(audioRecorder.recordingTime)
                                .font(.system(size: 48, weight: .medium, design: .monospaced))
                                .foregroundColor(audioRecorder.isRecording ? .red : .secondary)
                            
                            // Audio Level Indicator
                            if audioRecorder.isRecording {
                                AudioLevelIndicator(level: audioRecorder.audioLevel)
                                    .frame(height: 32)
                                    .padding(.horizontal, 40)
                            }
                        }
                        .padding(.top, 40)
                        
                        // Live Transcript
                        if audioRecorder.isRecording && !audioRecorder.transcript.isEmpty {
                            LiveTranscriptCard(transcript: audioRecorder.transcript)
                        }
                        
                        // Instructions
                        if !audioRecorder.isRecording {
                            InstructionsCard()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if currentConsultation != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingNewConsultationSheet = true }) {
                            Image(systemName: "info.circle")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingNewConsultationSheet) {
                NewConsultationSheet()
            }
        }
    }
    
    private func toggleRecording() {
        if audioRecorder.isRecording {
            audioRecorder.stopRecording()
            // Save the recording
            saveConsultation()
        } else {
            // Show sheet to capture patient info first
            if currentConsultation == nil {
                showingNewConsultationSheet = true
            }
            audioRecorder.startRecording()
        }
    }
    
    private func saveConsultation() {
        // In production, process the recording and create consultation
        // For now, just create a sample consultation
        print("Saving consultation with recording...")
    }
}

// MARK: - Audio Level Indicator
struct AudioLevelIndicator: View {
    let level: Float
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 4) {
                ForEach(0..<30, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            index < Int(level * 30) ?
                                LinearGradient(colors: [.green, .mint], startPoint: .bottom, endPoint: .top) :
                                LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.3)], startPoint: .bottom, endPoint: .top)
                        )
                        .frame(width: (geometry.size.width - (29 * 4)) / 30)
                }
            }
        }
    }
}

// MARK: - Live Transcript Card
struct LiveTranscriptCard: View {
    let transcript: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "waveform")
                    .foregroundColor(.red)
                Text("Live Transcript")
                    .font(.headline)
                Spacer()
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
            }
            
            Divider()
            
            ScrollView {
                Text(transcript)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 150)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10)
    }
}

// MARK: - Instructions Card
struct InstructionsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("How to Use")
                    .font(.headline)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                InstructionRow(
                    number: 1,
                    text: "Tap the microphone to start recording"
                )
                InstructionRow(
                    number: 2,
                    text: "Speak naturally during your consultation"
                )
                InstructionRow(
                    number: 3,
                    text: "AI will transcribe and structure your notes in SOAP format"
                )
                InstructionRow(
                    number: 4,
                    text: "Review, edit, and export when done"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10)
    }
}

struct InstructionRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 28, height: 28)
                Text("\(number)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.green)
            }
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    RecordView()
        .environmentObject(AudioRecorder())
        .environmentObject(ConsultationManager())
}
