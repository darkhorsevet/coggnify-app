//
//  HorseManager.swift
//  Horsimize
//
//  Manages horse profiles and data persistence
//

import Foundation
import SwiftUI

class HorseManager: ObservableObject {
    @Published var horses: [Horse] = []
    
    init() {
        // Load saved horses or use sample data
        loadSampleData()
    }
    
    // MARK: - CRUD Operations
    
    func addHorse(_ horse: Horse) {
        horses.append(horse)
        saveHorses()
    }
    
    func updateHorse(_ horse: Horse) {
        if let index = horses.firstIndex(where: { $0.id == horse.id }) {
            horses[index] = horse
            saveHorses()
        }
    }
    
    func deleteHorse(_ horse: Horse) {
        horses.removeAll { $0.id == horse.id }
        saveHorses()
    }
    
    func addBCSEntry(for horseId: UUID, entry: BCSEntry) {
        if let index = horses.firstIndex(where: { $0.id == horseId }) {
            horses[index].bcsHistory.append(entry)
            horses[index].currentBCS = entry.score
            saveHorses()
        }
    }
    
    // MARK: - Persistence
    
    private func saveHorses() {
        // TODO: Implement UserDefaults or CoreData persistence
        // For MVP, data will reset on app restart (fine for demo)
    }
    
    private func loadHorses() {
        // TODO: Load from UserDefaults/CoreData
    }
    
    // MARK: - Sample Data
    
    private func loadSampleData() {
        let sampleHorse = Horse(
            name: "Buddy",
            breed: "Quarter Horse",
            age: 12,
            weight: 1100,
            activityLevel: .light,
            healthConditions: [.none],
            currentBCS: 5,
            feedingAmount: "2 lbs twice daily"
        )
        
        horses = [sampleHorse]
    }
}
