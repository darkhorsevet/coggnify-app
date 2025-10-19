//
//  BCSAnalyzerView.swift
//  Horsimize
//
//  Photo-based body condition score analyzer
//

import SwiftUI
import AVFoundation

struct BCSAnalyzerView: View {
    @EnvironmentObject var horseManager: HorseManager
    @State var selectedHorse: Horse?
    @State private var showingCamera = false
    @State private var capturedImage: UIImage?
    @State private var analyzedBCS: Int?
    @State private var isAnalyzing = false
    @State private var showingSaveConfirmation = false
    @State private var bcsNotes = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if selectedHorse == nil {
                        // Horse selection
                        VStack(spacing: 15) {
                            Text("Select a Horse")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            ForEach(horseManager.horses) { horse in
                                Button(action: { selectedHorse = horse }) {
                                    HStack {
                                        Text("🐴")
                                            .font(.title2)
                                        VStack(alignment: .leading) {
                                            Text(horse.name)
                                                .font(.headline)
                                            Text("Current BCS: \(horse.currentBCS)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                    .foregroundColor(.primary)
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding()
                    } else if capturedImage == nil {
                        // Instructions and camera button
                        VStack(spacing: 20) {
                            Text("📸 Body Condition Score")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            if let horse = selectedHorse {
                                Text(horse.name)
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Instructions
                            VStack(alignment: .leading, spacing: 12) {
                                Text("How to Take the Photo:")
                                    .font(.headline)
                                
                                InstructionRow(number: "1", text: "Stand directly to the side of your horse")
                                InstructionRow(number: "2", text: "Capture full body from head to tail")
                                InstructionRow(number: "3", text: "Ensure good lighting")
                                InstructionRow(number: "4", text: "Horse should be standing square")
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                            
                            // BCS reference
                            VStack(alignment: .leading, spacing: 10) {
                                Text("BCS Scale (1-9):")
                                    .font(.headline)
                                
                                BCSReferenceRow(score: "1-3", description: "Too Thin", color: .red)
                                BCSReferenceRow(score: "4-6", description: "Ideal Weight", color: .green)
                                BCSReferenceRow(score: "7-9", description: "Overweight", color: .orange)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            
                            Button(action: { showingCamera = true }) {
                                Label("Take Photo", systemImage: "camera.fill")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                    } else {
                        // Show captured image and analysis
                        VStack(spacing: 20) {
                            if let image = capturedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                            }
                            
                            if isAnalyzing {
                                ProgressView("Analyzing body condition...")
                                    .padding()
                            } else if let bcs = analyzedBCS {
                                // Results
                                VStack(spacing: 15) {
                                    Text("Estimated BCS")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("\(bcs)")
                                        .font(.system(size: 72, weight: .bold))
                                        .foregroundColor(bcsColor(bcs))
                                    
                                    Text(bcsDescription(bcs))
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                    
                                    // Manual adjustment slider
                                    VStack(spacing: 10) {
                                        Text("Adjust if needed:")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        Picker("BCS", selection: Binding(
                                            get: { analyzedBCS ?? 5 },
                                            set: { analyzedBCS = $0 }
                                        )) {
                                            ForEach(1...9, id: \.self) { score in
                                                Text("\(score)").tag(score)
                                            }
                                        }
                                        .pickerStyle(.segmented)
                                    }
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(12)
                                    
                                    // Notes
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Notes (optional):")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        TextEditor(text: $bcsNotes)
                                            .frame(height: 100)
                                            .padding(8)
                                            .background(Color(.systemBackground))
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    }
                                    
                                    // Recommendations based on BCS
                                    RecommendationBox(bcs: bcs, horse: selectedHorse)
                                    
                                    // Action buttons
                                    VStack(spacing: 12) {
                                        Button(action: saveBCS) {
                                            Label("Save to \(selectedHorse?.name ?? "Horse")'s Profile", systemImage: "checkmark.circle.fill")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.green)
                                                .cornerRadius(12)
                                        }
                                        
                                        Button(action: retakePhoto) {
                                            Label("Retake Photo", systemImage: "camera.fill")
                                                .font(.headline)
                                                .foregroundColor(.green)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.green.opacity(0.1))
                                                .cornerRadius(12)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGroupedBackground))
                                .cornerRadius(15)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Body Condition Score")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingCamera) {
                ImagePicker(image: $capturedImage, onImageSelected: { image in
                    analyzeBCS(image)
                })
            }
            .alert("BCS Saved!", isPresented: $showingSaveConfirmation) {
                Button("OK") {
                    resetView()
                }
            } message: {
                Text("Body condition score has been saved to \(selectedHorse?.name ?? "your horse")'s profile.")
            }
        }
    }
    
    private func analyzeBCS(_ image: UIImage) {
        isAnalyzing = true
        
        // TODO: In production, integrate with CoreML model or cloud API
        // For MVP, we'll use a mock analysis with a realistic delay
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Mock analysis - in production this would be AI-based
            // For demo, we can estimate based on current BCS with some variation
            let currentBCS = selectedHorse?.currentBCS ?? 5
            let variation = Int.random(in: -1...1)
            analyzedBCS = max(1, min(9, currentBCS + variation))
            isAnalyzing = false
        }
    }
    
    private func saveBCS() {
        guard let horse = selectedHorse, let bcs = analyzedBCS else { return }
        
        let entry = BCSEntry(
            score: bcs,
            weight: horse.weight,
            notes: bcsNotes
        )
        
        horseManager.addBCSEntry(for: horse.id, entry: entry)
        showingSaveConfirmation = true
    }
    
    private func retakePhoto() {
        capturedImage = nil
        analyzedBCS = nil
        bcsNotes = ""
        showingCamera = true
    }
    
    private func resetView() {
        selectedHorse = nil
        capturedImage = nil
        analyzedBCS = nil
        bcsNotes = ""
    }
    
    private func bcsColor(_ bcs: Int) -> Color {
        switch bcs {
        case 1...3: return .red
        case 4...6: return .green
        case 7...9: return .orange
        default: return .gray
        }
    }
    
    private func bcsDescription(_ bcs: Int) -> String {
        switch bcs {
        case 1: return "Poor - Emaciated"
        case 2: return "Very Thin"
        case 3: return "Thin"
        case 4: return "Moderately Thin"
        case 5: return "Ideal - Moderate"
        case 6: return "Moderately Fleshy"
        case 7: return "Fleshy"
        case 8: return "Fat"
        case 9: return "Extremely Fat - Obese"
        default: return "Unknown"
        }
    }
}

// MARK: - Helper Views

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.green)
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

struct BCSReferenceRow: View {
    let score: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(score)
                .font(.headline)
                .foregroundColor(color)
                .frame(width: 50)
            
            Text(description)
                .font(.subheadline)
            
            Spacer()
            
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
        }
    }
}

struct RecommendationBox: View {
    let bcs: Int
    let horse: Horse?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Recommendation")
                    .font(.headline)
            }
            
            Text(recommendation)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var recommendation: String {
        switch bcs {
        case 1...3:
            return "Your horse is underweight. Increase feed gradually and consider high-fat supplements. Consult your veterinarian to rule out health issues."
        case 4...5:
            return "Your horse is at an ideal weight! Maintain current feeding program and monitor regularly."
        case 6:
            return "Your horse is slightly above ideal weight. Monitor closely and consider reducing grain slightly or increasing exercise."
        case 7...9:
            return "Your horse is overweight. Reduce grain/concentrate, use a ration balancer, increase exercise, and consider low-NSC feed options."
        default:
            return "Continue monitoring your horse's condition regularly."
        }
    }
}
