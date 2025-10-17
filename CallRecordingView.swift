//
//  CallRecordingView.swift
//  Notalyze
//
//  UI for phone call recording
//

import SwiftUI

struct CallRecordingView: View {
    @ObservedObject var callManager: CallManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: callManager.isRecordingCall ?
                        [Color.green.opacity(0.1), Color.mint.opacity(0.1)] :
                        [Color.blue.opacity(0.1), Color.cyan.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if callManager.isInCall {
                    // Active call UI
                    ActiveCallView(callManager: callManager)
                } else {
                    // Waiting state
                    WaitingForCallView()
                }
            }
            .navigationTitle("Phone Consultations")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Record This Call?", isPresented: $callManager.showCallRecordingPrompt) {
                Button("Start Recording", role: .none) {
                    callManager.startRecording()
                }
                Button("Not Now", role: .cancel) {
                    callManager.showCallRecordingPrompt = false
                }
            } message: {
                Text("Notalyze can record this phone consultation and automatically generate notes with action items.\n\n⚠️ Please inform the caller they're being recorded.")
            }
        }
    }
}

// MARK: - Active Call View

struct ActiveCallView: View {
    @ObservedObject var callManager: CallManager
    
    var formattedDuration: String {
        let duration = Int(callManager.currentCallDuration)
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Call Status
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: callManager.isRecordingCall ?
                                        [.green, .mint] : [.blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: (callManager.isRecordingCall ? Color.green : Color.blue).opacity(0.4), radius: 20)
                        
                        Image(systemName: "phone.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(callManager.isRecordingCall ? 1.05 : 1.0)
                    .animation(
                        callManager.isRecordingCall ?
                            .easeInOut(duration: 1.5).repeatForever(autoreverses: true) :
                            .default,
                        value: callManager.isRecordingCall
                    )
                    
                    Text(callManager.isRecordingCall ? "Recording Call" : "Call in Progress")
                        .font(.title2.bold())
                        .foregroundColor(callManager.isRecordingCall ? .green : .primary)
                    
                    Text(formattedDuration)
                        .font(.system(size: 48, weight: .medium, design: .monospaced))
                        .foregroundColor(callManager.isRecordingCall ? .green : .secondary)
                }
                .padding(.top, 40)
                
                // Recording Controls
                if callManager.isRecordingCall {
                    RecordingIndicatorCard()
                } else {
                    Button(action: {
                        callManager.startRecording()
                    }) {
                        HStack {
                            Image(systemName: "record.circle")
                                .font(.title2)
                            Text("Start Recording")
                                .font(.title3.bold())
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.green.opacity(0.3), radius: 10)
                    }
                    .padding(.horizontal)
                }
                
                // Instructions
                PhoneCallInstructionsCard(isRecording: callManager.isRecordingCall)
            }
            .padding()
        }
    }
}

// MARK: - Recording Indicator Card

struct RecordingIndicatorCard: View {
    @State private var isPulsing = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 12, height: 12)
                    .opacity(isPulsing ? 1.0 : 0.3)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
                
                Text("Recording in Progress")
                    .font(.headline)
                    .foregroundColor(.red)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                FeatureIndicator(icon: "waveform", text: "Audio being captured", color: .green)
                FeatureIndicator(icon: "text.bubble", text: "Will transcribe after call", color: .blue)
                FeatureIndicator(icon: "list.bullet.clipboard", text: "Action items will be extracted", color: .orange)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10)
        .padding(.horizontal)
        .onAppear {
            isPulsing = true
        }
    }
}

struct FeatureIndicator: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Waiting for Call View

struct WaitingForCallView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "phone.circle")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            Text("Waiting for Call")
                .font(.title2.bold())
            
            Text("When you receive or make a call, Notalyze will prompt you to record it.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            VStack(spacing: 16) {
                FeatureCard(
                    icon: "phone.arrow.down.left",
                    title: "Automatic Detection",
                    description: "Detects incoming and outgoing calls"
                )
                FeatureCard(
                    icon: "waveform.circle",
                    title: "Smart Recording",
                    description: "Records both sides of the conversation"
                )
                FeatureCard(
                    icon: "doc.text.magnifyingglass",
                    title: "AI Summary",
                    description: "Generates notes and action items"
                )
            }
            .padding(.top, 16)
        }
        .padding()
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8)
    }
}

// MARK: - Instructions Card

struct PhoneCallInstructionsCard: View {
    let isRecording: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: isRecording ? "checkmark.circle.fill" : "info.circle.fill")
                    .foregroundColor(isRecording ? .green : .blue)
                Text(isRecording ? "What Happens Next" : "How It Works")
                    .font(.headline)
            }
            
            Divider()
            
            if isRecording {
                VStack(alignment: .leading, spacing: 12) {
                    InstructionStep(number: 1, text: "Continue your call normally")
                    InstructionStep(number: 2, text: "Recording will stop when call ends")
                    InstructionStep(number: 3, text: "AI will transcribe and analyze")
                    InstructionStep(number: 4, text: "Find the consultation in your list")
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    InstructionStep(number: 1, text: "Make or receive a call")
                    InstructionStep(number: 2, text: "Tap 'Start Recording' when prompted")
                    InstructionStep(number: 3, text: "Inform the caller they're being recorded")
                    InstructionStep(number: 4, text: "Review AI-generated notes after")
                }
            }
            
            if !isRecording {
                Divider()
                
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Legal compliance required")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10)
        .padding(.horizontal)
    }
}

struct InstructionStep: View {
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
    CallRecordingView(callManager: CallManager())
}
