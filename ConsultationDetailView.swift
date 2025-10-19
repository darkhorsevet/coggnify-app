//
//  ConsultationDetailView.swift
//  Notalyze
//
//  Detailed view of a consultation with SOAP notes
//

import SwiftUI

struct ConsultationDetailView: View {
    let consultation: Consultation
    @State private var isEditing = false
    @State private var showingShareSheet = false
    @State private var showingExportOptions = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Patient Header
                PatientHeaderCard(consultation: consultation)
                
                // SOAP Notes
                SOAPNotesView(consultation: consultation)
                
                // Action Buttons
                VStack(spacing: 12) {
                    ActionButton(
                        title: "Export as PDF",
                        icon: "doc.fill",
                        color: .red
                    ) {
                        showingExportOptions = true
                    }
                    
                    ActionButton(
                        title: "Share",
                        icon: "square.and.arrow.up",
                        color: .blue
                    ) {
                        showingShareSheet = true
                    }
                    
                    ActionButton(
                        title: "Send to EMR",
                        icon: "arrow.up.doc",
                        color: .green
                    ) {
                        // Send to EMR
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { isEditing.toggle() }) {
                        Label(isEditing ? "Done Editing" : "Edit", systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: {}) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog("Export Options", isPresented: $showingExportOptions) {
            Button("Export as PDF") { }
            Button("Export as SOAP Text") { }
            Button("Export as Word Document") { }
            Button("Cancel", role: .cancel) { }
        }
    }
}

// MARK: - Patient Header Card
struct PatientHeaderCard: View {
    let consultation: Consultation
    
    var body: some View {
        VStack(spacing: 16) {
            // Horse emoji and name
            HStack {
                Text("🐴")
                    .font(.system(size: 48))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(consultation.patientName)
                        .font(.system(size: 26, weight: .bold))
                    
                    Text("\(consultation.breed) • \(consultation.age) yrs")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Divider()
            
            // Details grid
            VStack(spacing: 12) {
                DetailRow(icon: "person.fill", label: "Owner", value: consultation.ownerName)
                DetailRow(icon: "mappin.circle.fill", label: "Location", value: consultation.location)
                DetailRow(icon: "calendar", label: "Date", value: consultation.date.formatted(date: .long, time: .shortened))
                DetailRow(icon: "circle.fill", label: "Sex", value: consultation.sex)
                DetailRow(icon: "paintpalette.fill", label: "Color", value: consultation.color)
                
                if !consultation.microchip.isEmpty && consultation.microchip != "Not set" {
                    DetailRow(icon: "barcode", label: "Microchip", value: consultation.microchip)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.green)
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - SOAP Notes View
struct SOAPNotesView: View {
    let consultation: Consultation
    
    var body: some View {
        VStack(spacing: 16) {
            SOAPSection(
                title: "Subjective",
                icon: "text.bubble.fill",
                color: .blue,
                content: consultation.subjective
            )
            
            SOAPSection(
                title: "Objective",
                icon: "stethoscope",
                color: .green,
                content: consultation.objective
            )
            
            SOAPSection(
                title: "Assessment",
                icon: "heart.text.square.fill",
                color: .orange,
                content: consultation.assessment
            )
            
            SOAPSection(
                title: "Plan",
                icon: "list.clipboard.fill",
                color: .purple,
                content: consultation.plan
            )
        }
    }
}

// MARK: - SOAP Section
struct SOAPSection: View {
    let title: String
    let icon: String
    let color: Color
    let content: String
    
    @State private var isExpanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                    
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text("SOAP")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(color.opacity(0.15))
                            .cornerRadius(4)
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                Divider()
                
                Text(content.isEmpty ? "No notes recorded" : content)
                    .font(.system(size: 15))
                    .lineSpacing(4)
                    .foregroundColor(content.isEmpty ? .secondary : .primary)
                    .italic(content.isEmpty)
                    .textSelection(.enabled)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .foregroundColor(color)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
}

#Preview {
    NavigationStack {
        ConsultationDetailView(consultation: Consultation.sampleData[0])
    }
}
