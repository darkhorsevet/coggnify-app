//
//  FeedLibraryView.swift
//  Horsimize
//
//  Browse and search all feeds in the database
//

import SwiftUI

struct FeedLibraryView: View {
    @EnvironmentObject var feedDatabase: FeedDatabase
    @State private var searchText = ""
    @State private var selectedType: FeedType? = nil
    @State private var sortOption: SortOption = .brand
    
    enum SortOption: String, CaseIterable {
        case brand = "Brand"
        case price = "Price"
        case protein = "Protein"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search feeds...", text: $searchText)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()
                
                // Filter by type
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        FilterChip(title: "All", isSelected: selectedType == nil) {
                            selectedType = nil
                        }
                        
                        ForEach(FeedType.allCases, id: \.self) { type in
                            FilterChip(
                                title: "\(type.icon) \(type.rawValue)",
                                isSelected: selectedType == type
                            ) {
                                selectedType = type
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
                
                // Sort options
                Picker("Sort", selection: $sortOption) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Feed list
                List(filteredAndSortedFeeds) { feed in
                    NavigationLink(destination: FeedDetailView(feed: feed)) {
                        FeedCardView(feed: feed, isCompact: true)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Feed Library")
        }
    }
    
    private var filteredAndSortedFeeds: [Feed] {
        var filtered = feedDatabase.feeds
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = feedDatabase.searchFeeds(query: searchText)
        }
        
        // Filter by type
        if let type = selectedType {
            filtered = filtered.filter { $0.feedType == type }
        }
        
        // Sort
        switch sortOption {
        case .brand:
            filtered.sort { $0.brandName < $1.brandName }
        case .price:
            filtered.sort { ($0.pricePerPound ?? 999) < ($1.pricePerPound ?? 999) }
        case .protein:
            filtered.sort { $0.crudeProtein > $1.crudeProtein }
        }
        
        return filtered
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.green : Color(.systemGray6))
                .cornerRadius(20)
        }
    }
}

// MARK: - Feed Detail View

struct FeedDetailView: View {
    let feed: Feed
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(feed.feedType.icon)
                        .font(.system(size: 60))
                    
                    Text(feed.brandName)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(feed.productName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(feed.feedType.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                
                Divider()
                
                // Guaranteed Analysis
                VStack(alignment: .leading, spacing: 12) {
                    Text("Guaranteed Analysis")
                        .font(.headline)
                    
                    AnalysisRow(label: "Crude Protein", value: feed.crudeProtein)
                    AnalysisRow(label: "Crude Fat", value: feed.crudeFat)
                    AnalysisRow(label: "Crude Fiber", value: feed.crudeFiber)
                    
                    if let nsc = feed.nsc {
                        AnalysisRow(label: "NSC (Starch + Sugar)", value: nsc, isHighlight: true)
                    }
                    
                    if let calories = feed.calories {
                        HStack {
                            Text("Calories")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(calories) kcal/lb")
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                Divider()
                
                // Price Info
                if let price = feed.price, let weight = feed.bagWeight {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pricing")
                            .font(.headline)
                        
                        HStack {
                            Text("Bag Size")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(weight) lbs")
                        }
                        
                        HStack {
                            Text("Price per Bag")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("$\(String(format: "%.2f", price))")
                                .fontWeight(.semibold)
                        }
                        
                        if let pricePerLb = feed.pricePerPound {
                            HStack {
                                Text("Price per Pound")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("$\(String(format: "%.2f", pricePerLb))")
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    Divider()
                }
                
                // Ingredients
                if !feed.ingredients.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Key Ingredients")
                            .font(.headline)
                        
                        ForEach(feed.ingredients.prefix(10), id: \.self) { ingredient in
                            HStack {
                                Text("•")
                                Text(ingredient)
                                    .font(.subheadline)
                            }
                        }
                    }
                    
                    Divider()
                }
                
                // Notes
                if !feed.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        
                        Text(feed.notes)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Feed Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AnalysisRow: View {
    let label: String
    let value: Double
    var isHighlight: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(String(format: "%.1f%%", value))
                .fontWeight(.semibold)
                .foregroundColor(isHighlight ? .orange : .primary)
        }
    }
}
