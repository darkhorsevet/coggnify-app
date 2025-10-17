//
//  MainTabView.swift
//  Notalyze
//
//  Main tab navigation for iPhone
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var consultationManager: ConsultationManager
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home / Consultations List
            ConsultationsListView()
                .tabItem {
                    Label("Consultations", systemImage: "list.bullet.clipboard")
                }
                .tag(0)
            
            // Record / New Consultation
            RecordView()
                .environmentObject(audioRecorder)
                .tabItem {
                    Label("Record", systemImage: "mic.circle.fill")
                }
                .tag(1)
            
            // Templates
            TemplatesView()
                .tabItem {
                    Label("Templates", systemImage: "doc.text")
                }
                .tag(2)
            
            // Settings
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .accentColor(.green)
    }
}

#Preview {
    MainTabView()
        .environmentObject(ConsultationManager())
}
