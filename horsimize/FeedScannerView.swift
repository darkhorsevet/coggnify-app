//
//  FeedScannerView.swift
//  Horsimize
//
//  Camera view to scan feed bag tags with OCR
//

import SwiftUI
import AVFoundation
import Vision
import VisionKit

struct FeedScannerView: View {
    @EnvironmentObject var feedDatabase: FeedDatabase
    @State private var showingCamera = false
    @State private var scannedImage: UIImage?
    @State private var scanResult: ScannedFeedResult?
    @State private var isAnalyzing = false
    @State private var showingResults = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if let image = scannedImage {
                    // Show scanned image with results
                    ScrollView {
                        VStack(spacing: 20) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(12)
                                .shadow(radius: 5)
                                .padding()
                            
                            if isAnalyzing {
                                ProgressView("Analyzing feed tag...")
                                    .padding()
                            } else if let result = scanResult {
                                ScanResultView(result: result)
                                    .padding(.horizontal)
                            }
                            
                            Button(action: {
                                scannedImage = nil
                                scanResult = nil
                                showingCamera = true
                            }) {
                                Label("Scan Another Feed", systemImage: "camera.fill")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                    }
                } else {
                    // Empty state - ready to scan
                    VStack(spacing: 25) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 100))
                            .foregroundColor(.green.opacity(0.5))
                        
                        Text("Scan Feed Bag Tag")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Point your camera at the guaranteed analysis section of any feed bag")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 40)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Reads protein, fat, and fiber percentages", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Label("Matches to our feed database", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Label("Gets instant recommendations", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        .padding()
                        
                        Button(action: { showingCamera = true }) {
                            Label("Start Scanning", systemImage: "camera.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: 250)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationTitle("Feed Scanner")
            .sheet(isPresented: $showingCamera) {
                ImagePicker(image: $scannedImage, onImageSelected: { image in
                    analyzeFeedTag(image)
                })
            }
        }
    }
    
    private func analyzeFeedTag(_ image: UIImage) {
        isAnalyzing = true
        
        // Perform OCR on the image
        guard let cgImage = image.cgImage else { return }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                isAnalyzing = false
                return
            }
            
            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            // Extract nutritional values
            let result = extractNutritionalInfo(from: recognizedText)
            
            DispatchQueue.main.async {
                scanResult = result
                isAnalyzing = false
                showingResults = true
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
    
    private func extractNutritionalInfo(from text: String) -> ScannedFeedResult {
        var protein: Double?
        var fat: Double?
        var fiber: Double?
        var nsc: Double?
        
        // Regex patterns to extract percentages
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            let lowercased = line.lowercased()
            
            // Extract protein
            if lowercased.contains("protein") {
                protein = extractPercentage(from: line)
            }
            
            // Extract fat
            if lowercased.contains("fat") && !lowercased.contains("min") {
                fat = extractPercentage(from: line)
            }
            
            // Extract fiber
            if lowercased.contains("fiber") {
                fiber = extractPercentage(from: line)
            }
            
            // Extract NSC (if mentioned)
            if lowercased.contains("nsc") || lowercased.contains("starch") {
                nsc = extractPercentage(from: line)
            }
        }
        
        // Try to match feed in database
        var matchedFeed: Feed?
        if let p = protein, let f = fat, let fb = fiber {
            matchedFeed = feedDatabase.matchFeed(protein: p, fat: f, fiber: fb)
        }
        
        // Calculate confidence based on extracted values
        let confidence: Double = {
            var score = 0.0
            if protein != nil { score += 0.33 }
            if fat != nil { score += 0.33 }
            if fiber != nil { score += 0.34 }
            return score
        }()
        
        return ScannedFeedResult(
            recognizedText: text,
            extractedProtein: protein,
            extractedFat: fat,
            extractedFiber: fiber,
            extractedNSC: nsc,
            matchedFeed: matchedFeed,
            confidence: confidence
        )
    }
    
    private func extractPercentage(from text: String) -> Double? {
        // Look for patterns like "12.5%", "12.5 %", "12.5"
        let pattern = #"(\d+\.?\d*)\s*%?"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let nsString = text as NSString
        let results = regex?.matches(in: text, range: NSRange(location: 0, length: nsString.length))
        
        if let match = results?.first {
            let valueString = nsString.substring(with: match.range(at: 1))
            return Double(valueString)
        }
        
        return nil
    }
}

// MARK: - Scan Result View

struct ScanResultView: View {
    let result: ScannedFeedResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Scan Results")
                .font(.title2)
                .fontWeight(.bold)
            
            // Confidence indicator
            HStack {
                Text("Confidence:")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(result.confidence * 100))%")
                    .fontWeight(.semibold)
                    .foregroundColor(confidenceColor)
            }
            
            Divider()
            
            // Extracted values
            VStack(spacing: 10) {
                if let protein = result.extractedProtein {
                    NutritionRow(label: "Crude Protein", value: protein)
                }
                if let fat = result.extractedFat {
                    NutritionRow(label: "Crude Fat", value: fat)
                }
                if let fiber = result.extractedFiber {
                    NutritionRow(label: "Crude Fiber", value: fiber)
                }
                if let nsc = result.extractedNSC {
                    NutritionRow(label: "NSC", value: nsc)
                }
            }
            
            // Matched feed
            if let feed = result.matchedFeed {
                Divider()
                
                Text("Matched Feed")
                    .font(.headline)
                    .padding(.top, 5)
                
                FeedCardView(feed: feed, isCompact: true)
                    .padding(.top, 5)
            } else {
                Divider()
                
                Text("No exact match found in database")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var confidenceColor: Color {
        if result.confidence > 0.7 { return .green }
        if result.confidence > 0.4 { return .orange }
        return .red
    }
}

struct NutritionRow: View {
    let label: String
    let value: Double
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(String(format: "%.1f%%", value))
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onImageSelected: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
                parent.onImageSelected(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
