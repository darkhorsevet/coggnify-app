//
//  PhoneConsultationDetailView.swift
//  Notalyze
//
//  Detail view for phone consultations with action items
//

import SwiftUI

struct PhoneConsultationDetailView: View {
    let consultation: Consultation
    @State private var actionItems: [ActionItem] = []
    @State private var callSummary: String = ""
    @State private var showingShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Phone Call Header
                PhoneCallHeaderCard(consultation: consultation)
                
                // Call Summary
                if !callSummary.isEmpty {
                    CallSummaryCard(summary: callSummary)
                }
                
                // Action Items
                if !actionItems.isEmpty {
                    ActionItemsCard(actionItems: $actionItems)
                }
                
                // Full Transcript
                TranscriptCard(transcript: consultation.transcript ?? "No transcript available")
                
                // SOAP Notes (if generated)
                if !consultation.subjective.isEmpty {
                    SOAPNotesView(consultation: consultation)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingShareSheet = true }) {
                        Label("Share Summary", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: {}) {
                        Label("Export PDF", systemImage: "doc.fill")
                    }
                    
                    Button(action: {}) {
                        Label("Send to EMR", systemImage: "arrow.up.doc")
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
        .onAppear {
            loadPhoneConsultationData()
        }
    }
    
    private func loadPhoneConsultationData() {
        // Load action items and summary
        // In production, this would come from the consultation data
        callSummary = "Phone consultation with \(consultation.ownerName) regarding \(consultation.patientName). Discussed lameness concerns and scheduled follow-up examination."
        
        actionItems = [
            ActionItem(
                task: "Schedule farm visit for examination",
                responsibleParty: "Veterinarian",
                deadline: "Tomorrow at 10:00 AM",
                isCompleted: false
            ),
            ActionItem(
                task: "Cold hose affected leg twice daily",
                responsibleParty: "Client",
                deadline: "Until examination",
                isCompleted: false
            ),
            ActionItem(
                task: "Call if condition worsens",
                responsibleParty: "Client",
                deadline: "Before scheduled visit",
                isCompleted: false
            )
        ]
    }
}

// MARK: - Phone Call Header Card

struct PhoneCallHeaderCard: View {
    let consultation: Consultation
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "phone.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Phone Consultation")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text(consultation.patientName)
                        .font(.system(size: 22, weight: .bold))
                    
                    Text("with \(consultation.ownerName)")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Divider()
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Date", systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(consultation.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline.bold())
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Label("Duration", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("8:34")
                        .font(.subheadline.bold())
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Call Summary Card

struct CallSummaryCard: View {
    let summary: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "text.quote")
                    .foregroundColor(.blue)
                Text("Call Summary")
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                    .font(.caption)
            }
            
            Divider()
            
            Text(summary)
                .font(.system(size: 15))
                .lineSpacing(4)
                .textSelection(.enabled)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Action Items Card

struct ActionItemsCard: View {
    @Binding var actionItems: [ActionItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checklist")
                    .foregroundColor(.orange)
                Text("Action Items")
                    .font(.headline)
                
                Spacer()
                
                Text("\(actionItems.filter { !$0.isCompleted }.count) pending")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            ForEach(actionItems.indices, id: \.self) { index in
                ActionItemRow(actionItem: $actionItems[index])
                
                if index < actionItems.count - 1 {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct ActionItemRow: View {
    @Binding var actionItem: ActionItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: {
                actionItem.isCompleted.toggle()
            }) {
                Image(systemName: actionItem.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(actionItem.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(actionItem.task)
                    .font(.system(size: 15))
                    .strikethrough(actionItem.isCompleted)
                    .foregroundColor(actionItem.isCompleted ? .secondary : .primary)
                
                HStack(spacing: 12) {
                    Label(actionItem.responsibleParty, systemImage: "person.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label(actionItem.deadline, systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Transcript Card

struct TranscriptCard: View {
    let transcript: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Image(systemName: "text.alignleft")
                        .foregroundColor(.purple)
                    Text("Full Transcript")
                        .font(.headline)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                Divider()
                
                ScrollView {
                    Text(transcript)
                        .font(.system(size: 14))
                        .lineSpacing(6)
                        .textSelection(.enabled)
                }
                .frame(maxHeight: 300)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        PhoneConsultationDetailView(
            consultation: Consultation(
                patientName: "Thunder",
                breed: "Thoroughbred",
                age: 8,
                sex: "Gelding",
                color: "Bay",
                ownerName: "Sarah Johnson",
                location: "Phone Call",
                microchip: "",
                date: Date(),
                type: .followUp
            )
        )
    }
}
