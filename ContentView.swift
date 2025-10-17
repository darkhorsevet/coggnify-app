//
//  ContentView.swift
//  VetScribe
//
//  Main application view with three-column layout
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var consultationManager: ConsultationManager
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var selectedConsultation: Consultation?
    @State private var searchText = ""
    
    var body: some View {
        NavigationSplitView {
            // MARK: - Sidebar (Consultation List)
            SidebarView(
                consultations: consultationManager.consultations,
                selectedConsultation: $selectedConsultation,
                searchText: $searchText
            )
        } content: {
            // MARK: - Main Content (Notes)
            if let consultation = selectedConsultation {
                ConsultationDetailView(consultation: consultation)
            } else {
                WelcomeView()
            }
        } detail: {
            // MARK: - Detail Panel (Recording & Tools)
            RecordingPanelView(audioRecorder: audioRecorder)
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear {
            if !consultationManager.consultations.isEmpty {
                selectedConsultation = consultationManager.consultations.first
            }
        }
    }
}

// MARK: - Sidebar View
struct SidebarView: View {
    let consultations: [Consultation]
    @Binding var selectedConsultation: Consultation?
    @Binding var searchText: String
    
    var filteredConsultations: [Consultation] {
        if searchText.isEmpty {
            return consultations
        }
        return consultations.filter { consultation in
            consultation.patientName.localizedCaseInsensitiveContains(searchText) ||
            consultation.ownerName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search consultations...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
            .padding(.horizontal, 12)
            .padding(.top, 12)
            
            Divider()
                .padding(.vertical, 8)
            
            // Consultation list
            List(filteredConsultations, selection: $selectedConsultation) { consultation in
                ConsultationListItem(consultation: consultation)
                    .tag(consultation)
            }
            .listStyle(.sidebar)
        }
        .navigationTitle("VetScribe")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {}) {
                    Label("New", systemImage: "plus")
                }
            }
        }
    }
}

// MARK: - Consultation List Item
struct ConsultationListItem: View {
    let consultation: Consultation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.accentColor)
                Text(consultation.patientName)
                    .font(.system(size: 14, weight: .semibold))
            }
            
            Text(consultation.breed)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 10))
                Text(consultation.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 11))
            }
            .foregroundColor(.secondary)
            
            ConsultationTypeBadge(type: consultation.type)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Welcome View
struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .mint],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 12) {
                Text("Welcome to VetScribe")
                    .font(.system(size: 32, weight: .bold))
                
                Text("AI-powered consultation notes for equine veterinarians")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                FeatureRow(icon: "mic.fill", title: "Record Consultations", description: "Capture everything hands-free")
                FeatureRow(icon: "doc.text.fill", title: "Auto-Generate SOAP Notes", description: "AI structures your notes automatically")
                FeatureRow(icon: "square.and.arrow.up.fill", title: "Export Anywhere", description: "PDF, EMR, practice management systems")
            }
            .padding(.top, 16)
            
            Button(action: {}) {
                Label("Start New Consultation", systemImage: "plus.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .textBackgroundColor))
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.accentColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .frame(maxWidth: 400)
    }
}

#Preview {
    ContentView()
        .environmentObject(ConsultationManager())
}
