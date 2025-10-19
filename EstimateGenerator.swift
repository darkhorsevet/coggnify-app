//
//  EstimateGenerator.swift
//  Notalyze
//
//  Generates estimates/invoices from conversations with Echo
//

import Foundation
import SwiftUI

class EstimateGenerator: ObservableObject {
    @Published var currentEstimate: VetEstimate?
    @Published var isGenerating = false
    
    // Common procedure pricing (customizable per practice)
    private let procedurePricing: [String: ProcedureItem] = [
        // Emergency Visits
        "emergency_call": ProcedureItem(name: "Emergency Farm Call", price: 150.00, category: .visit),
        "routine_call": ProcedureItem(name: "Routine Farm Call", price: 85.00, category: .visit),
        "after_hours": ProcedureItem(name: "After Hours Fee", price: 100.00, category: .visit),
        
        // Examinations
        "physical_exam": ProcedureItem(name: "Physical Examination", price: 75.00, category: .examination),
        "lameness_exam": ProcedureItem(name: "Lameness Examination", price: 125.00, category: .examination),
        "colic_exam": ProcedureItem(name: "Colic Examination", price: 150.00, category: .examination),
        "prepurchase_exam": ProcedureItem(name: "Pre-Purchase Examination", price: 350.00, category: .examination),
        
        // Diagnostics
        "radiographs": ProcedureItem(name: "Radiographs (per view)", price: 85.00, category: .diagnostics),
        "ultrasound": ProcedureItem(name: "Ultrasound Examination", price: 150.00, category: .diagnostics),
        "blood_work": ProcedureItem(name: "Blood Work - CBC", price: 65.00, category: .diagnostics),
        "chemistry_panel": ProcedureItem(name: "Chemistry Panel", price: 95.00, category: .diagnostics),
        "fecal_exam": ProcedureItem(name: "Fecal Examination", price: 35.00, category: .diagnostics),
        
        // Treatments & Procedures
        "iv_fluids": ProcedureItem(name: "IV Fluids (per liter)", price: 25.00, category: .treatment),
        "ng_tube": ProcedureItem(name: "Nasogastric Intubation", price: 65.00, category: .treatment),
        "wound_treatment": ProcedureItem(name: "Wound Treatment/Cleaning", price: 95.00, category: .treatment),
        "joint_injection": ProcedureItem(name: "Joint Injection", price: 125.00, category: .treatment),
        "laceration_repair": ProcedureItem(name: "Laceration Repair/Suturing", price: 200.00, category: .treatment),
        "bandaging": ProcedureItem(name: "Bandaging/Splinting", price: 45.00, category: .treatment),
        
        // Dental
        "dental_exam": ProcedureItem(name: "Dental Examination", price: 85.00, category: .dental),
        "dental_float": ProcedureItem(name: "Dental Float", price: 175.00, category: .dental),
        "wolf_tooth": ProcedureItem(name: "Wolf Tooth Extraction", price: 125.00, category: .dental),
        
        // Medications (common ones)
        "banamine": ProcedureItem(name: "Flunixin (Banamine)", price: 15.00, category: .medication),
        "bute": ProcedureItem(name: "Phenylbutazone", price: 12.00, category: .medication),
        "penicillin": ProcedureItem(name: "Penicillin Injection", price: 18.00, category: .medication),
        "gentamicin": ProcedureItem(name: "Gentamicin", price: 35.00, category: .medication),
        "xylazine": ProcedureItem(name: "Xylazine Sedation", price: 25.00, category: .medication),
        "tetanus": ProcedureItem(name: "Tetanus Toxoid", price: 20.00, category: .medication),
        
        // Vaccinations
        "rabies": ProcedureItem(name: "Rabies Vaccine", price: 25.00, category: .vaccination),
        "ewt": ProcedureItem(name: "EWT Vaccine", price: 35.00, category: .vaccination),
        "flu_rhino": ProcedureItem(name: "Flu/Rhino Vaccine", price: 30.00, category: .vaccination),
        "west_nile": ProcedureItem(name: "West Nile Vaccine", price: 28.00, category: .vaccination),
        
        // Reproduction
        "pregnancy_check": ProcedureItem(name: "Pregnancy Check (Ultrasound)", price: 75.00, category: .reproduction),
        "breeding_soundness": ProcedureItem(name: "Breeding Soundness Exam", price: 200.00, category: .reproduction),
    ]
    
    // MARK: - Generate Estimate from Conversation
    
    func generateEstimate(from transcript: String, clientName: String, patientName: String) async throws -> VetEstimate {
        isGenerating = true
        defer { isGenerating = false }
        
        // Use AI to extract procedures from conversation
        let extractedItems = try await extractProceduresFromTranscript(transcript)
        
        let estimate = VetEstimate(
            id: UUID(),
            clientName: clientName,
            patientName: patientName,
            date: Date(),
            items: extractedItems,
            notes: "Based on consultation discussion",
            status: .draft
        )
        
        currentEstimate = estimate
        return estimate
    }
    
    // MARK: - AI Extraction
    
    private func extractProceduresFromTranscript(_ transcript: String) async throws -> [EstimateLineItem] {
        // TODO: Integrate with OpenAI GPT-4 to extract procedures
        // Example prompt:
        /*
        let prompt = """
        You are analyzing a veterinary consultation transcript to create an estimate.
        
        Extract all procedures, treatments, medications, and services discussed.
        For each item found, identify:
        - The procedure/service name
        - Quantity (if mentioned)
        - Any specific details
        
        Match to these standard procedures if possible: \(procedurePricing.keys)
        
        Transcript:
        \(transcript)
        
        Return as JSON array with fields: procedureKey, quantity, customName (if not in standard list)
        """
        */
        
        // Mock extraction for development
        return mockExtractProcedures(from: transcript)
    }
    
    private func mockExtractProcedures(from transcript: String) -> [EstimateLineItem] {
        var items: [EstimateLineItem] = []
        let lowercased = transcript.lowercased()
        
        // Emergency call detection
        if lowercased.contains("emergency") || lowercased.contains("urgent") {
            if let procedure = procedurePricing["emergency_call"] {
                items.append(EstimateLineItem(procedure: procedure, quantity: 1))
            }
        } else {
            if let procedure = procedurePricing["routine_call"] {
                items.append(EstimateLineItem(procedure: procedure, quantity: 1))
            }
        }
        
        // Colic examination
        if lowercased.contains("colic") {
            if let procedure = procedurePricing["colic_exam"] {
                items.append(EstimateLineItem(procedure: procedure, quantity: 1))
            }
            if let procedure = procedurePricing["ng_tube"] {
                items.append(EstimateLineItem(procedure: procedure, quantity: 1))
            }
        }
        
        // Lameness
        if lowercased.contains("lame") || lowercased.contains("limping") {
            if let procedure = procedurePricing["lameness_exam"] {
                items.append(EstimateLineItem(procedure: procedure, quantity: 1))
            }
        }
        
        // Laceration/wound
        if lowercased.contains("laceration") || lowercased.contains("wound") || lowercased.contains("cut") {
            if let procedure = procedurePricing["wound_treatment"] {
                items.append(EstimateLineItem(procedure: procedure, quantity: 1))
            }
            if lowercased.contains("suture") || lowercased.contains("stitch") {
                if let procedure = procedurePricing["laceration_repair"] {
                    items.append(EstimateLineItem(procedure: procedure, quantity: 1))
                }
            }
            if let procedure = procedurePricing["bandaging"] {
                items.append(EstimateLineItem(procedure: procedure, quantity: 1))
            }
        }
        
        // Medications
        if lowercased.contains("banamine") || lowercased.contains("flunixin") {
            if let procedure = procedurePricing["banamine"] {
                items.append(EstimateLineItem(procedure: procedure, quantity: 1))
            }
        }
        
        if lowercased.contains("bute") || lowercased.contains("phenylbutazone") {
            if let procedure = procedurePricing["bute"] {
                items.append(EstimateLineItem(procedure: procedure, quantity: 1))
            }
        }
        
        if lowercased.contains("penicillin") {
            if let procedure = procedurePricing["penicillin"] {
                items.append(EstimateLineItem(procedure: procedure, quantity: 3))
            }
        }
        
        if lowercased.contains("tetanus") {
            if let procedure = procedurePricing["tetanus"] {
                items.append(EstimateLineItem(procedure: procedure, quantity: 1))
            }
        }
        
        // X-rays/radiographs
        if lowercased.contains("x-ray") || lowercased.contains("radiograph") {
            if let procedure = procedurePricing["radiographs"] {
                // Default to 4 views
                items.append(EstimateLineItem(procedure: procedure, quantity: 4))
            }
        }
        
        // Ultrasound
        if lowercased.contains("ultrasound") {
            if let procedure = procedurePricing["ultrasound"] {
                items.append(EstimateLineItem(procedure: procedure, quantity: 1))
            }
        }
        
        // Blood work
        if lowercased.contains("blood work") || lowercased.contains("blood test") {
            if let procedure = procedurePricing["blood_work"] {
                items.append(EstimateLineItem(procedure: procedure, quantity: 1))
            }
        }
        
        return items
    }
    
    // MARK: - Manual Estimate Building
    
    func createBlankEstimate(clientName: String, patientName: String) -> VetEstimate {
        let estimate = VetEstimate(
            id: UUID(),
            clientName: clientName,
            patientName: patientName,
            date: Date(),
            items: [],
            notes: "",
            status: .draft
        )
        currentEstimate = estimate
        return estimate
    }
    
    func addItem(to estimate: VetEstimate, procedureKey: String, quantity: Int) -> VetEstimate {
        var updatedEstimate = estimate
        if let procedure = procedurePricing[procedureKey] {
            let item = EstimateLineItem(procedure: procedure, quantity: quantity)
            updatedEstimate.items.append(item)
        }
        currentEstimate = updatedEstimate
        return updatedEstimate
    }
}

// MARK: - Models

struct VetEstimate: Identifiable, Codable {
    let id: UUID
    var clientName: String
    var patientName: String
    var date: Date
    var items: [EstimateLineItem]
    var notes: String
    var status: EstimateStatus
    
    var subtotal: Double {
        items.reduce(0) { $0 + $1.total }
    }
    
    var tax: Double {
        subtotal * 0.0 // Adjust tax rate as needed
    }
    
    var total: Double {
        subtotal + tax
    }
    
    func formatted() -> String {
        """
        ESTIMATE
        
        Client: \(clientName)
        Patient: \(patientName)
        Date: \(date.formatted(date: .long, time: .omitted))
        
        SERVICES:
        \(items.map { "• \($0.procedure.name) x\($0.quantity) - $\(String(format: "%.2f", $0.total))" }.joined(separator: "\n"))
        
        Subtotal: $\(String(format: "%.2f", subtotal))
        Tax: $\(String(format: "%.2f", tax))
        
        TOTAL: $\(String(format: "%.2f", total))
        
        Notes: \(notes)
        
        This is an estimate only. Final charges may vary based on actual services provided.
        """
    }
}

struct EstimateLineItem: Identifiable, Codable, Hashable {
    let id: UUID
    var procedure: ProcedureItem
    var quantity: Int
    var customPrice: Double?
    
    init(id: UUID = UUID(), procedure: ProcedureItem, quantity: Int, customPrice: Double? = nil) {
        self.id = id
        self.procedure = procedure
        self.quantity = quantity
        self.customPrice = customPrice
    }
    
    var unitPrice: Double {
        customPrice ?? procedure.price
    }
    
    var total: Double {
        unitPrice * Double(quantity)
    }
}

struct ProcedureItem: Codable, Hashable {
    let name: String
    let price: Double
    let category: ProcedureCategory
}

enum ProcedureCategory: String, Codable, CaseIterable {
    case visit = "Farm Visit"
    case examination = "Examination"
    case diagnostics = "Diagnostics"
    case treatment = "Treatment"
    case dental = "Dental"
    case medication = "Medication"
    case vaccination = "Vaccination"
    case reproduction = "Reproduction"
    case surgery = "Surgery"
    case other = "Other"
}

enum EstimateStatus: String, Codable {
    case draft = "Draft"
    case sent = "Sent"
    case approved = "Approved"
    case invoiced = "Invoiced"
}
