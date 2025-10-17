//
//  TemplatesView.swift
//  Notalyze
//
//  View for selecting consultation templates
//

import SwiftUI

struct TemplatesView: View {
    @State private var selectedTemplate: TemplateType?
    @State private var showingTemplateDetail = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Choose a Template")
                            .font(.title2.bold())
                        Text("Start with a structured format for your consultation type")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Templates Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(TemplateType.allCases, id: \.self) { template in
                            TemplateCard(template: template) {
                                selectedTemplate = template
                                showingTemplateDetail = true
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingTemplateDetail) {
                if let template = selectedTemplate {
                    TemplateDetailSheet(template: template)
                }
            }
        }
    }
}

// MARK: - Template Card
struct TemplateCard: View {
    let template: TemplateType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [template.color, template.color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: template.icon)
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
                
                Text(template.rawValue)
                    .font(.system(size: 15, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(template.description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Template Detail Sheet
struct TemplateDetailSheet: View {
    let template: TemplateType
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [template.color, template.color.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 72, height: 72)
                            
                            Image(systemName: template.icon)
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.rawValue)
                                .font(.title2.bold())
                            Text(template.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    // Template Fields
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Included Sections")
                            .font(.headline)
                        
                        ForEach(template.sections, id: \.self) { section in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(section)
                                    .font(.system(size: 15))
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Key Points
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Key Points to Cover")
                            .font(.headline)
                        
                        ForEach(template.keyPoints, id: \.self) { point in
                            HStack(alignment: .top, spacing: 12) {
                                Circle()
                                    .fill(template.color.opacity(0.3))
                                    .frame(width: 6, height: 6)
                                    .padding(.top, 6)
                                
                                Text(point)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Template Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Use Template") {
                        // Create new consultation with template
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    TemplatesView()
}
