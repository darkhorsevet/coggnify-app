//
//  FeedCardView.swift
//  Horsimize
//
//  Reusable feed card component
//

import SwiftUI

struct FeedCardView: View {
    let feed: Feed
    var isCompact: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(feed.brandName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(feed.productName)
                        .font(isCompact ? .subheadline : .headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                    
                    Text("\(feed.feedType.icon) \(feed.feedType.rawValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let pricePerLb = feed.pricePerPound {
                    VStack(alignment: .trailing) {
                        Text("$\(String(format: "%.2f", pricePerLb))")
                            .font(.headline)
                            .foregroundColor(.green)
                        Text("per lb")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if !isCompact {
                // Nutritional info
                HStack(spacing: 15) {
                    NutritionalBadge(label: "Protein", value: feed.crudeProtein)
                    NutritionalBadge(label: "Fat", value: feed.crudeFat)
                    NutritionalBadge(label: "Fiber", value: feed.crudeFiber)
                    
                    if let nsc = feed.nsc {
                        NutritionalBadge(label: "NSC", value: nsc, color: nsc > 20 ? .red : .green)
                    }
                }
                .padding(.top, 5)
            }
        }
        .padding(isCompact ? 0 : 12)
    }
}

struct NutritionalBadge: View {
    let label: String
    let value: Double
    var color: Color = .blue
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("\(String(format: "%.1f", value))%")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}
