//
//  NewConsultationSheet.swift
//  Notalyze
//
//  Sheet for creating a new consultation
//

import SwiftUI

struct NewConsultationSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var consultationManager: ConsultationManager
    
    @State private var patientName = ""
    @State private var breed = ""
    @State private var age = ""
    @State private var sex = "Gelding"
    @State private var color = ""
    @State private var ownerName = ""
    @State private var location = ""
    @State private var microchip = ""
    @State private var consultationType: ConsultationType = .routineCheckup
    
    let sexOptions = ["Stallion", "Mare", "Gelding"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Patient Information") {
                    TextField("Patient Name", text: $patientName)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Breed", text: $breed)
                        .textInputAutocapitalization(.words)
                    
                    HStack {
                        Text("Age")
                        Spacer()
                        TextField("Years", text: $age)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    Picker("Sex", selection: $sex) {
                        ForEach(sexOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    
                    TextField("Color/Markings", text: $color)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Microchip (Optional)", text: $microchip)
                        .keyboardType(.numberPad)
                }
                
                Section("Owner Information") {
                    TextField("Owner Name", text: $ownerName)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Location/Farm", text: $location)
                        .textInputAutocapitalization(.words)
                }
                
                Section("Consultation Type") {
                    Picker("Type", selection: $consultationType) {
                        ForEach(ConsultationType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
            }
            .navigationTitle("New Consultation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createConsultation()
                    }
                    .fontWeight(.semibold)
                    .disabled(patientName.isEmpty || ownerName.isEmpty)
                }
            }
        }
    }
    
    private func createConsultation() {
        let newConsultation = Consultation(
            patientName: patientName,
            breed: breed.isEmpty ? "Unknown" : breed,
            age: Int(age) ?? 0,
            sex: sex,
            color: color.isEmpty ? "Unknown" : color,
            ownerName: ownerName,
            location: location.isEmpty ? "Unknown" : location,
            microchip: microchip.isEmpty ? "Not set" : microchip,
            date: Date(),
            type: consultationType
        )
        
        consultationManager.consultations.insert(newConsultation, at: 0)
        consultationManager.saveConsultations()
        
        dismiss()
    }
}

#Preview {
    NewConsultationSheet()
        .environmentObject(ConsultationManager())
}
