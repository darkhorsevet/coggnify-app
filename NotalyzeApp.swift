//
//  NotalyzeApp.swift
//  Notalyze
//
//  AI-Powered Veterinary Consultation Notes for Equine Veterinarians
//

import SwiftUI

@main
struct NotalyzeApp: App {
    @StateObject private var consultationManager = ConsultationManager()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(consultationManager)
        }
    }
}
