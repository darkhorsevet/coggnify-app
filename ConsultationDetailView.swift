//
//  ConsultationDetailView.swift
//  VetScribe
//
//  Detailed view of a consultation with SOAP notes
//

import SwiftUI

struct ConsultationDetailView: View {
    let consultation: Consultation
    @State private var isEditing = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Patient Header
                PatientHeaderCard(consultation: consultation)
                
                // MARK: - SOAP Notes
                SOAPNotesView(consultation: consultation, isEditing: $isEditing)
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .textBackgroundColor))
        .toolbar {
            ToolbarItemGroup {
                Button(action: { isEditing.toggle() }) {
                    Label(isEditing ? "Done" : "Edit", systemImage: isEditing ? "checkmark" : "pencil")
                }
                
                Menu {
                    Button(action: {}) {
                        Label("Export as PDF", systemImage: "doc.fill")
                    }
                    Button(action: {}) {
                        Label("Export SOAP Format", systemImage: "doc.text")
                    }
                    Divider()
                    Button(action: {}) {
                        Label("Send to EMR", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                
                Button(action: {}) {
                    Label("Share", systemImage: "paperplane")
                }
            }
        }
    }
}

// MARK: - Patient Header Card
struct PatientHeaderCard: View {
    let consultation: Consultation
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with emoji
            HStack {
                Text("🐴")
                    .font(.system(size: 48))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(consultation.patientName)
                        .font(.system(size: 28, weight: .bold))
                    
                    Text("\(consultation.breed) • \(consultation.age) years old")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ConsultationTypeBadge(type: consultation.type)
            }
            .padding(20)
            
            Divider()
            
            // Patient details grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                DetailItem(label: "Owner", value: consultation.ownerName, icon: "person.fill")
                DetailItem(label: "Location", value: consultation.location, icon: "mappin.circle.fill")
                DetailItem(label: "Date", value: consultation.date.formatted(date: .abbreviated, time: .shortened), icon: "calendar")
                DetailItem(label: "Sex", value: consultation.sex, icon: "pawprint.fill")
                DetailItem(label: "Color", value: consultation.color, icon: "paintpalette.fill")
                DetailItem(label: "Microchip", value: consultation.microchip, icon: "barcode")
            }
            .padding(20)
        }
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct DetailItem: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
        }
    }
}

// MARK: - SOAP Notes View
struct SOAPNotesView: View {
    let consultation: Consultation
    @Binding var isEditing: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            SOAPSection(
                title: "Subjective",
                icon: "text.bubble.fill",
                color: .blue,
                content: consultation.subjective,
                isEditing: isEditing
            )
            
            SOAPSection(
                title: "Objective",
                icon: "stethoscope",
                color: .green,
                content: consultation.objective,
                isEditing: isEditing
            )
            
            SOAPSection(
                title: "Assessment",
                icon: "heart.text.square.fill",
                color: .orange,
                content: consultation.assessment,
                isEditing: isEditing
            )
            
            SOAPSection(
                title: "Plan",
                icon: "list.clipboard.fill",
                color: .purple,
                content: consultation.plan,
                isEditing: isEditing
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
    let isEditing: Bool
    
    @State private var editedContent: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                
                Spacer()
                
                Text("SOAP")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.15))
                    .cornerRadius(4)
            }
            
            Divider()
            
            if isEditing {
                TextEditor(text: $editedContent)
                    .font(.system(size: 14))
                    .frame(minHeight: 150)
                    .padding(8)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(6)
            } else {
                Text(content)
                    .font(.system(size: 14))
                    .lineSpacing(6)
                    .textSelection(.enabled)
            }
        }
        .padding(20)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .onAppear {
            editedContent = content
        }
    }
}

// MARK: - Consultation Type Badge
struct ConsultationTypeBadge: View {
    let type: ConsultationType
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: type.icon)
                .font(.system(size: 10))
            Text(type.rawValue)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(type.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(type.color.opacity(0.15))
        .cornerRadius(6)
    }
}

#Preview {
    ConsultationDetailView(consultation: Consultation.sampleData[0])
}
