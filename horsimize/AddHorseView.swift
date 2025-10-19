//
//  AddHorseView.swift
//  Horsimize
//
//  Form to add a new horse profile
//

import SwiftUI

struct AddHorseView: View {
    @EnvironmentObject var horseManager: HorseManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var breed = ""
    @State private var age = 10
    @State private var weight = 1000
    @State private var activityLevel: ActivityLevel = .light
    @State private var currentBCS = 5
    @State private var selectedHealthConditions: Set<HealthCondition> = [.none]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Horse Name", text: $name)
                    
                    TextField("Breed", text: $breed)
                    
                    Stepper("Age: \(age) years", value: $age, in: 1...40)
                    
                    Stepper("Weight: \(weight) lbs", value: $weight, in: 200...2500, step: 50)
                }
                
                Section("Activity Level") {
                    Picker("Activity", selection: $activityLevel) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    Text(activityLevel.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Body Condition Score") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Current BCS:")
                            Spacer()
                            Text("\(currentBCS)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(bcsColor)
                        }
                        
                        Slider(value: Binding(
                            get: { Double(currentBCS) },
                            set: { currentBCS = Int($0) }
                        ), in: 1...9, step: 1)
                        
                        Text(bcsDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Health Conditions") {
                    ForEach(HealthCondition.allCases, id: \.self) { condition in
                        Button(action: {
                            toggleHealthCondition(condition)
                        }) {
                            HStack {
                                Text("\(condition.icon) \(condition.rawValue)")
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedHealthConditions.contains(condition) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Horse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveHorse()
                    }
                    .disabled(name.isEmpty || breed.isEmpty)
                }
            }
        }
    }
    
    private func toggleHealthCondition(_ condition: HealthCondition) {
        if condition == .none {
            // If selecting "none", clear all others
            selectedHealthConditions = [.none]
        } else {
            // Remove "none" if selecting any other condition
            selectedHealthConditions.remove(.none)
            
            if selectedHealthConditions.contains(condition) {
                selectedHealthConditions.remove(condition)
                // If nothing selected, add "none" back
                if selectedHealthConditions.isEmpty {
                    selectedHealthConditions.insert(.none)
                }
            } else {
                selectedHealthConditions.insert(condition)
            }
        }
    }
    
    private func saveHorse() {
        let newHorse = Horse(
            name: name,
            breed: breed,
            age: age,
            weight: weight,
            activityLevel: activityLevel,
            healthConditions: Array(selectedHealthConditions),
            currentBCS: currentBCS
        )
        
        horseManager.addHorse(newHorse)
        dismiss()
    }
    
    private var bcsColor: Color {
        switch currentBCS {
        case 1...3: return .red
        case 4...6: return .green
        case 7...9: return .orange
        default: return .gray
        }
    }
    
    private var bcsDescription: String {
        switch currentBCS {
        case 1: return "Poor - Emaciated"
        case 2: return "Very Thin"
        case 3: return "Thin"
        case 4: return "Moderately Thin"
        case 5: return "Ideal - Moderate"
        case 6: return "Moderately Fleshy"
        case 7: return "Fleshy"
        case 8: return "Fat"
        case 9: return "Extremely Fat - Obese"
        default: return "Ideal"
        }
    }
}
