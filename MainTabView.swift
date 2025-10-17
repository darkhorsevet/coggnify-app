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
    @StateObject private var callManager = CallManager()
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
            
            // Echo AI Assistant
            AIAssistantView()
                .tabItem {
                    Label("Echo", systemImage: "waveform.circle.fill")
                }
                .tag(2)
            
            // Phone Calls
            CallRecordingView(callManager: callManager)
                .tabItem {
                    Label("Phone Calls", systemImage: "phone.fill")
                }
                .badge(callManager.isInCall ? "•" : nil)
                .tag(3)
            
            // Templates
            TemplatesView()
                .tabItem {
                    Label("Templates", systemImage: "doc.text")
                }
                .tag(4)
            
            // Settings
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(5)
        }
        .accentColor(.green)
        .onAppear {
            callManager.requestNotificationPermission()
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(ConsultationManager())
}
