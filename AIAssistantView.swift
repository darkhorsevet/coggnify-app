//
//  AIAssistantView.swift
//  Notalyze
//
//  AI Assistant for field emergencies and clinical decision support
//

import SwiftUI

struct AIAssistantView: View {
    @StateObject private var assistantManager = AIAssistantManager()
    @State private var messageText = ""
    @State private var showingEmergencyMenu = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Emergency Quick Actions
                    if assistantManager.messages.isEmpty {
                        WelcomeAssistantView(assistantManager: assistantManager)
                            .transition(.opacity)
                    } else {
                        // Chat Messages
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(assistantManager.messages) { message in
                                        MessageBubble(message: message)
                                            .id(message.id)
                                    }
                                    
                                    if assistantManager.isProcessing {
                                        TypingIndicator()
                                    }
                                }
                                .padding()
                            }
                            .onChange(of: assistantManager.messages.count) { _ in
                                if let lastMessage = assistantManager.messages.last {
                                    withAnimation {
                                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Input Area
                    VStack(spacing: 0) {
                        Divider()
                        
                        HStack(spacing: 12) {
                            // Emergency Button
                            Button(action: { showingEmergencyMenu = true }) {
                                Image(systemName: "bolt.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.red, .orange],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            
                            // Text Input
                            HStack {
                                TextField("Ask about colic, medications, procedures...", text: $messageText, axis: .vertical)
                                    .textFieldStyle(.plain)
                                    .focused($isTextFieldFocused)
                                    .lineLimit(1...4)
                                
                                if !messageText.isEmpty {
                                    Button(action: { messageText = "" }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                            .cornerRadius(20)
                            
                            // Voice Input
                            Button(action: { assistantManager.startVoiceInput() }) {
                                Image(systemName: assistantManager.isListening ? "waveform" : "mic.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(assistantManager.isListening ? .red : .green)
                            }
                            .disabled(assistantManager.isProcessing)
                            
                            // Send Button
                            Button(action: sendMessage) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(messageText.isEmpty ? .secondary : .green)
                            }
                            .disabled(messageText.isEmpty || assistantManager.isProcessing)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                    }
                }
                .navigationTitle("Echo")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(action: { assistantManager.clearChat() }) {
                                Label("Clear Chat", systemImage: "trash")
                            }
                            
                    Button(action: { assistantManager.createEstimate() }) {
                        Label("Create Estimate from Chat", systemImage: "dollarsign.circle")
                    }
                    
                    Button(action: {}) {
                        Label("Save to Consultation", systemImage: "doc.badge.plus")
                    }
                            
                            Divider()
                            
                            Button(action: {}) {
                                Label("Settings", systemImage: "gear")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
                .confirmationDialog("Emergency Protocols", isPresented: $showingEmergencyMenu) {
                    Button("🚨 Colic Assessment") {
                        assistantManager.loadEmergencyProtocol(.colic)
                    }
                    Button("🩹 Laceration Management") {
                        assistantManager.loadEmergencyProtocol(.laceration)
                    }
                    Button("😰 Choke Protocol") {
                        assistantManager.loadEmergencyProtocol(.choke)
                    }
                    Button("🤕 Lameness Evaluation") {
                        assistantManager.loadEmergencyProtocol(.lameness)
                    }
                    Button("👁️ Eye Emergency") {
                        assistantManager.loadEmergencyProtocol(.eyeEmergency)
                    }
                    Button("💊 Drug Dosage Calculator") {
                        assistantManager.loadEmergencyProtocol(.drugCalculator)
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
            .sheet(isPresented: $assistantManager.showingEstimate) {
                if let estimate = assistantManager.generatedEstimate {
                    EstimateView(estimate: estimate)
                }
            }
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        assistantManager.sendMessage(messageText)
        messageText = ""
        isTextFieldFocused = false
    }
}

// MARK: - Welcome View

struct WelcomeAssistantView: View {
    @ObservedObject var assistantManager: AIAssistantManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "stethoscope")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                    
                    Text("Echo")
                        .font(.title.bold())
                    
                    Text("Your AI assistant for emergencies, estimates & more")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Emergency Quick Actions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Emergency Protocols")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        EmergencyButton(
                            icon: "exclamationmark.triangle.fill",
                            title: "Colic Assessment",
                            color: .red,
                            action: { assistantManager.loadEmergencyProtocol(.colic) }
                        )
                        
                        EmergencyButton(
                            icon: "bandage.fill",
                            title: "Laceration",
                            color: .orange,
                            action: { assistantManager.loadEmergencyProtocol(.laceration) }
                        )
                        
                        EmergencyButton(
                            icon: "wind",
                            title: "Choke",
                            color: .purple,
                            action: { assistantManager.loadEmergencyProtocol(.choke) }
                        )
                        
                        EmergencyButton(
                            icon: "figure.walk",
                            title: "Lameness",
                            color: .blue,
                            action: { assistantManager.loadEmergencyProtocol(.lameness) }
                        )
                        
                        EmergencyButton(
                            icon: "eye.fill",
                            title: "Eye Emergency",
                            color: .green,
                            action: { assistantManager.loadEmergencyProtocol(.eyeEmergency) }
                        )
                        
                        EmergencyButton(
                            icon: "pills.fill",
                            title: "Drug Calculator",
                            color: .cyan,
                            action: { assistantManager.loadEmergencyProtocol(.drugCalculator) }
                        )
                    }
                    .padding(.horizontal)
                }
                
                // Quick Tips
                VStack(alignment: .leading, spacing: 12) {
                    Text("What I Can Help With")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        TipRow(icon: "checklist", text: "Decision trees for emergency assessment")
                        TipRow(icon: "calculator", text: "Drug dosage calculations by weight")
                        TipRow(icon: "list.bullet.clipboard", text: "Step-by-step procedure guides")
                        TipRow(icon: "chart.line.uptrend.xyaxis", text: "Differential diagnosis suggestions")
                        TipRow(icon: "heart.text.square", text: "Normal vital ranges reference")
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Example Questions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Try Asking")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        ExampleQuestionButton(
                            question: "What's the flunixin dose for a 450kg horse?",
                            assistantManager: assistantManager
                        )
                        ExampleQuestionButton(
                            question: "Walk me through colic severity assessment",
                            assistantManager: assistantManager
                        )
                        ExampleQuestionButton(
                            question: "Best way to handle a severe laceration?",
                            assistantManager: assistantManager
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 20)
        }
    }
}

struct EmergencyButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 8)
        }
        .buttonStyle(.plain)
    }
}

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

struct ExampleQuestionButton: View {
    let question: String
    @ObservedObject var assistantManager: AIAssistantManager
    
    var body: some View {
        Button(action: {
            assistantManager.sendMessage(question)
        }) {
            HStack {
                Text(question)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: AssistantMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 6) {
                Text(message.content)
                    .font(.system(size: 15))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.isUser ?
                            AnyView(LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )) :
                            AnyView(Color(.systemGray5))
                    )
                    .cornerRadius(20)
                
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 8, height: 8)
                    .offset(y: animating ? -5 : 0)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray5))
        .cornerRadius(20)
        .onAppear { animating = true }
    }
}

#Preview {
    AIAssistantView()
}
