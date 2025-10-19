//
//  ConsultationsListView.swift
//  Notalyze
//
//  List of all consultations
//

import SwiftUI

struct ConsultationsListView: View {
    @EnvironmentObject var consultationManager: ConsultationManager
    @State private var searchText = ""
    @State private var showingNewConsultation = false
    
    var filteredConsultations: [Consultation] {
        if searchText.isEmpty {
            return consultationManager.consultations
        }
        return consultationManager.consultations.filter { consultation in
            consultation.patientName.localizedCaseInsensitiveContains(searchText) ||
            consultation.ownerName.localizedCaseInsensitiveContains(searchText) ||
            consultation.breed.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if consultationManager.consultations.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(filteredConsultations) { consultation in
                            NavigationLink(destination: ConsultationDetailView(consultation: consultation)) {
                                ConsultationRow(consultation: consultation)
                            }
                        }
                        .onDelete(perform: deleteConsultations)
                    }
                    .searchable(text: $searchText, prompt: "Search consultations")
                    .refreshable {
                        // Pull to refresh
                        consultationManager.loadConsultations()
                    }
                }
            }
            .navigationTitle("Notalyze")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewConsultation = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
            .sheet(isPresented: $showingNewConsultation) {
                NewConsultationSheet()
            }
        }
    }
    
    private func deleteConsultations(at offsets: IndexSet) {
        for index in offsets {
            let consultation = filteredConsultations[index]
            consultationManager.deleteConsultation(consultation)
        }
    }
}

// MARK: - Consultation Row
struct ConsultationRow: View {
    let consultation: Consultation
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(consultation.type.color.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 24))
                    .foregroundColor(consultation.type.color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(consultation.patientName)
                    .font(.system(size: 17, weight: .semibold))
                
                Text("\(consultation.breed) • \(consultation.age) yrs")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    ConsultationTypeBadge(type: consultation.type)
                    
                    Text(consultation.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("No Consultations Yet")
                .font(.title2.bold())
            
            Text("Tap the + button to create your first consultation or use the Record tab to start recording.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
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
            Text(type.displayName)
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundColor(type.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(type.color.opacity(0.15))
        .cornerRadius(6)
    }
}

#Preview {
    ConsultationsListView()
        .environmentObject(ConsultationManager())
}
