//
//  VetScribeApp.swift
//  VetScribe
//
//  AI-Powered Veterinary Consultation Notes for Equine Veterinarians
//

import SwiftUI

@main
struct VetScribeApp: App {
    @StateObject private var consultationManager = ConsultationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(consultationManager)
                .frame(minWidth: 1200, minHeight: 800)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Consultation") {
                    consultationManager.createNewConsultation()
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        
        Settings {
            SettingsView()
        }
    }
}
