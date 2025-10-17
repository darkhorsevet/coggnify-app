//
//  ConsultationManager.swift
//  VetScribe
//
//  Manages consultation data and persistence
//

import Foundation
import SwiftUI

@MainActor
class ConsultationManager: ObservableObject {
    @Published var consultations: [Consultation] = []
    
    private let saveKey = "SavedConsultations"
    
    init() {
        loadConsultations()
    }
    
    func createNewConsultation() {
        let newConsultation = Consultation(
            patientName: "New Patient",
            breed: "Unknown",
            age: 0,
            sex: "Unknown",
            color: "Unknown",
            ownerName: "Unknown",
            location: "Unknown",
            microchip: "Not set",
            date: Date(),
            type: .routineCheckup
        )
        consultations.insert(newConsultation, at: 0)
        saveConsultations()
    }
    
    func updateConsultation(_ consultation: Consultation) {
        if let index = consultations.firstIndex(where: { $0.id == consultation.id }) {
            consultations[index] = consultation
            saveConsultations()
        }
    }
    
    func deleteConsultation(_ consultation: Consultation) {
        consultations.removeAll { $0.id == consultation.id }
        saveConsultations()
    }
    
    private func saveConsultations() {
        // In a real app, implement proper persistence (Core Data, SwiftData, or file-based)
        // For now, we'll use sample data
    }
    
    private func loadConsultations() {
        // Load sample data
        consultations = Consultation.sampleData
    }
}
