//
//  HorseDetailView.swift
//  Horsimize
//
//  Detailed view of a single horse with recommendations
//

import SwiftUI

struct HorseDetailView: View {
    @EnvironmentObject var horseManager: HorseManager
    @EnvironmentObject var feedDatabase: FeedDatabase
    @State var horse: Horse
    @State private var showingEditHorse = false
    @State private var showingFeedRecommendations = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                VStack(spacing: 15) {
                    Text("🐴")
                        .font(.system(size: 80))
                    
                    Text(horse.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("\(horse.breed) • \(horse.age) years old")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 30) {
                        VStack {
                            Text("\(horse.weight)")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("lbs")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                            .frame(height: 40)
                        
                        VStack {
                            Text("BCS \(horse.currentBCS)")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(bcsColor)
                            Text(bcsStatus)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                            .frame(height: 40)
                        
                        VStack {
                            Text(horse.activityLevel.rawValue.split(separator: " ").first ?? "")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Activity")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Health Conditions
                if !horse.healthConditions.filter({ $0 != .none }).isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Health Conditions")
                            .font(.headline)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(horse.healthConditions.filter { $0 != .none }, id: \.self) { condition in
                                Text("\(condition.icon) \(condition.rawValue)")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.red.opacity(0.2))
                                    .foregroundColor(.red)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                
                // Current Feed
                if let feed = horse.currentFeed {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Current Feed")
                            .font(.headline)
                        
                        FeedCardView(feed: feed, isCompact: true)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: { showingFeedRecommendations = true }) {
                        Label("Get Feed Recommendations", systemImage: "sparkles")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                    
                    NavigationLink(destination: BCSAnalyzerView(selectedHorse: horse)) {
                        Label("Update Body Condition Score", systemImage: "camera.fill")
                            .font(.headline)
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                // BCS History
                if !horse.bcsHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("BCS History")
                            .font(.headline)
                        
                        ForEach(horse.bcsHistory.sorted(by: { $0.date > $1.date }).prefix(5)) { entry in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("BCS \(entry.score)")
                                        .font(.headline)
                                    Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if let weight = entry.weight {
                                    Text("\(weight) lbs")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                            Divider()
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(horse.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditHorse = true
                }
            }
        }
        .sheet(isPresented: $showingFeedRecommendations) {
            FeedRecommendationsView(horse: horse)
        }
    }
    
    private var bcsColor: Color {
        switch horse.currentBCS {
        case 1...3: return .red
        case 4...6: return .green
        case 7...9: return .orange
        default: return .gray
        }
    }
    
    private var bcsStatus: String {
        switch horse.currentBCS {
        case 1...3: return "Too Thin"
        case 4...6: return "Ideal"
        case 7...9: return "Overweight"
        default: return "Unknown"
        }
    }
}

// MARK: - Flow Layout for Tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}
