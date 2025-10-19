//
//  FeedRecommendationsView.swift
//  Horsimize
//
//  Display feed recommendations for a specific horse
//

import SwiftUI

struct FeedRecommendationsView: View {
    @EnvironmentObject var feedDatabase: FeedDatabase
    @Environment(\.dismiss) var dismiss
    let horse: Horse
    
    @State private var recommendations: [FeedRecommendation] = []
    @State private var isLoading = true
    @State private var filterRating: Int = 0 // 0 = show all
    @State private var sortBy: SortOption = .rating
    
    enum SortOption: String, CaseIterable {
        case rating = "Best Match"
        case price = "Price"
        case protein = "Protein"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Horse info header
                HStack {
                    VStack(alignment: .leading) {
                        Text(horse.name)
                            .font(.headline)
                        Text("\(horse.activityLevel.rawValue) • BCS \(horse.currentBCS)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if !horse.healthConditions.filter({ $0 != .none }).isEmpty {
                        Text("⚠️")
                            .font(.title2)
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                // Filters
                HStack {
                    Picker("Sort", selection: $sortBy) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                // Recommendations list
                if isLoading {
                    Spacer()
                    ProgressView("Finding best feeds...")
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(filteredAndSortedRecommendations) { recommendation in
                                RecommendationCard(recommendation: recommendation, horse: horse)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Feed Recommendations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                generateRecommendations()
            }
        }
    }
    
    private var filteredAndSortedRecommendations: [FeedRecommendation] {
        var filtered = recommendations
        
        // Filter by rating if needed
        if filterRating > 0 {
            filtered = filtered.filter { $0.rating >= filterRating }
        }
        
        // Sort
        switch sortBy {
        case .rating:
            filtered.sort { $0.rating > $1.rating }
        case .price:
            filtered.sort { ($0.monthlyCost ?? 999) < ($1.monthlyCost ?? 999) }
        case .protein:
            filtered.sort { $0.feed.crudeProtein > $1.feed.crudeProtein }
        }
        
        return filtered
    }
    
    private func generateRecommendations() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let engine = FeedRecommendationEngine()
            let results = engine.getRecommendations(for: horse, from: feedDatabase.feeds)
            
            DispatchQueue.main.async {
                recommendations = results
                isLoading = false
            }
        }
    }
}

// MARK: - Recommendation Card

struct RecommendationCard: View {
    let recommendation: FeedRecommendation
    let horse: Horse
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendation.feed.brandName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(recommendation.feed.productName)
                        .font(.headline)
                    
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < recommendation.rating ? "star.fill" : "star")
                                .foregroundColor(index < recommendation.rating ? .yellow : .gray)
                                .font(.caption)
                        }
                        Text(recommendation.matchReason)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    if let cost = recommendation.monthlyCost {
                        Text("$\(Int(cost))/mo")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    
                    Text(recommendation.feed.feedType.icon)
                        .font(.title2)
                }
            }
            
            // Nutritional summary
            HStack(spacing: 20) {
                NutrientBadge(label: "Protein", value: recommendation.feed.crudeProtein)
                NutrientBadge(label: "Fat", value: recommendation.feed.crudeFat)
                NutrientBadge(label: "Fiber", value: recommendation.feed.crudeFiber)
                if let nsc = recommendation.feed.nsc {
                    NutrientBadge(label: "NSC", value: nsc, isWarning: nsc > 20)
                }
            }
            
            // Feeding guideline
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                Text(recommendation.feedingGuideline)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            
            // Pros and Cons (expandable)
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Text(isExpanded ? "Hide Details" : "Show Details")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .foregroundColor(.green)
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    if !recommendation.pros.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("✅ Pros:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            ForEach(recommendation.pros, id: \.self) { pro in
                                Text("• \(pro)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if !recommendation.cons.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("⚠️ Cons:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            ForEach(recommendation.cons, id: \.self) { con in
                                Text("• \(con)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.top, 5)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct NutrientBadge: View {
    let label: String
    let value: Double
    var isWarning: Bool = false
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("\(String(format: "%.1f", value))%")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isWarning ? .red : .primary)
        }
    }
}
