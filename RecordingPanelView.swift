//
//  RecordingPanelView.swift
//  VetScribe
//
//  Recording controls and templates panel
//

import SwiftUI

struct RecordingPanelView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @State private var selectedTemplate: TemplateType?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Recording Section
                RecordingControlsCard(audioRecorder: audioRecorder)
                
                // MARK: - Templates Section
                TemplatesCard(selectedTemplate: $selectedTemplate)
                
                // MARK: - Quick Actions
                QuickActionsCard()
                
                // MARK: - Live Transcript
                if audioRecorder.isRecording {
                    LiveTranscriptCard(audioRecorder: audioRecorder)
                }
            }
            .padding(20)
        }
        .frame(minWidth: 320)
        .background(Color(nsColor: .textBackgroundColor))
    }
}

// MARK: - Recording Controls Card
struct RecordingControlsCard: View {
    @ObservedObject var audioRecorder: AudioRecorder
    
    var body: some View {
        VStack(spacing: 20) {
            Text(audioRecorder.isRecording ? "Recording..." : "Ready to Record")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            // Record button
            Button(action: {
                if audioRecorder.isRecording {
                    audioRecorder.stopRecording()
                } else {
                    audioRecorder.startRecording()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            audioRecorder.isRecording ?
                            LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing) :
                            LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: (audioRecorder.isRecording ? Color.red : Color.green).opacity(0.3), radius: 15)
                    
                    Image(systemName: audioRecorder.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)
            .scaleEffect(audioRecorder.isRecording ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: audioRecorder.isRecording)
            
            // Timer
            Text(audioRecorder.recordingTime)
                .font(.system(size: 28, weight: .medium, design: .monospaced))
                .foregroundColor(audioRecorder.isRecording ? .red : .secondary)
            
            // Audio level indicator
            if audioRecorder.isRecording {
                HStack(spacing: 3) {
                    ForEach(0..<20) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index < Int(audioRecorder.audioLevel * 20) ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 4, height: 20)
                    }
                }
                .animation(.easeInOut(duration: 0.1), value: audioRecorder.audioLevel)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Templates Card
struct TemplatesCard: View {
    @Binding var selectedTemplate: TemplateType?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.accentColor)
                Text("Templates")
                    .font(.system(size: 16, weight: .semibold))
            }
            
            Divider()
            
            VStack(spacing: 8) {
                ForEach(TemplateType.allCases, id: \.self) { template in
                    TemplateButton(template: template, isSelected: selectedTemplate == template) {
                        selectedTemplate = template
                    }
                }
            }
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct TemplateButton: View {
    let template: TemplateType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: template.icon)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .white : .primary)
                    .frame(width: 24)
                
                Text(template.rawValue)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? Color.accentColor : Color(nsColor: .textBackgroundColor))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quick Actions Card
struct QuickActionsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "square.and.arrow.up.fill")
                    .foregroundColor(.accentColor)
                Text("Export")
                    .font(.system(size: 16, weight: .semibold))
            }
            
            Divider()
            
            VStack(spacing: 8) {
                ActionButton(icon: "doc.fill", title: "Export PDF", color: .red) {}
                ActionButton(icon: "doc.text.fill", title: "SOAP Format", color: .blue) {}
                ActionButton(icon: "square.and.arrow.up.fill", title: "Send to EMR", color: .green) {}
                ActionButton(icon: "printer.fill", title: "Print", color: .gray) {}
            }
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                    .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(nsColor: .textBackgroundColor))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Live Transcript Card
struct LiveTranscriptCard: View {
    @ObservedObject var audioRecorder: AudioRecorder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "waveform")
                    .foregroundColor(.accentColor)
                Text("Live Transcript")
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
            }
            
            Divider()
            
            ScrollView {
                Text(audioRecorder.transcript.isEmpty ? "Listening..." : audioRecorder.transcript)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 150)
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    RecordingPanelView(audioRecorder: AudioRecorder())
        .frame(width: 350)
}
