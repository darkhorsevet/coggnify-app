//
//  Models.swift
//  VetScribe
//
//  Data models for consultations and recordings
//

import Foundation
import SwiftUI

// MARK: - Consultation
struct Consultation: Identifiable, Hashable {
    let id: UUID
    var patientName: String
    var breed: String
    var age: Int
    var sex: String
    var color: String
    var ownerName: String
    var location: String
    var microchip: String
    var date: Date
    var type: ConsultationType
    
    var subjective: String
    var objective: String
    var assessment: String
    var plan: String
    
    var audioFileURL: URL?
    var transcript: String?
    
    init(
        id: UUID = UUID(),
        patientName: String,
        breed: String,
        age: Int,
        sex: String,
        color: String,
        ownerName: String,
        location: String,
        microchip: String,
        date: Date,
        type: ConsultationType,
        subjective: String = "",
        objective: String = "",
        assessment: String = "",
        plan: String = ""
    ) {
        self.id = id
        self.patientName = patientName
        self.breed = breed
        self.age = age
        self.sex = sex
        self.color = color
        self.ownerName = ownerName
        self.location = location
        self.microchip = microchip
        self.date = date
        self.type = type
        self.subjective = subjective
        self.objective = objective
        self.assessment = assessment
        self.plan = plan
    }
}

// MARK: - Consultation Type
enum ConsultationType: String, CaseIterable {
    case lamenessExam = "Lameness Exam"
    case routineCheckup = "Routine Checkup"
    case colicevaluation = "Colic Evaluation"
    case dentalExam = "Dental Exam"
    case reproductiveCheck = "Reproductive Check"
    case prePurchaseExam = "Pre-Purchase Exam"
    case woundCare = "Wound Care"
    case emergency = "Emergency"
    case followUp = "Follow-up"
    
    var icon: String {
        switch self {
        case .lamenessExam: return "figure.walk"
        case .routineCheckup: return "stethoscope"
        case .colicevaluation: return "heart.text.square"
        case .dentalExam: return "cross.case.fill"
        case .reproductiveCheck: return "waveform.path.ecg"
        case .prePurchaseExam: return "doc.text.magnifyingglass"
        case .woundCare: return "bandage.fill"
        case .emergency: return "exclamationmark.triangle.fill"
        case .followUp: return "arrow.clockwise"
        }
    }
    
    var color: Color {
        switch self {
        case .lamenessExam: return .orange
        case .routineCheckup: return .green
        case .colicevaluation: return .red
        case .dentalExam: return .blue
        case .reproductiveCheck: return .pink
        case .prePurchaseExam: return .purple
        case .woundCare: return .yellow
        case .emergency: return .red
        case .followUp: return .cyan
        }
    }
}

// MARK: - Template Type
enum TemplateType: String, CaseIterable {
    case physicalExam = "Physical Exam"
    case lamenessExam = "Lameness Exam"
    case colicevaluation = "Colic Assessment"
    case dentalExam = "Dental Exam"
    case reproductiveCheck = "Reproductive Check"
    case prePurchaseExam = "Pre-Purchase Exam"
    
    var icon: String {
        switch self {
        case .physicalExam: return "stethoscope"
        case .lamenessExam: return "figure.walk"
        case .colicevaluation: return "heart.text.square"
        case .dentalExam: return "cross.case.fill"
        case .reproductiveCheck: return "waveform.path.ecg"
        case .prePurchaseExam: return "doc.text.magnifyingglass"
        }
    }
}

// MARK: - Sample Data
extension Consultation {
    static let sampleData: [Consultation] = [
        Consultation(
            patientName: "Thunder",
            breed: "Thoroughbred",
            age: 8,
            sex: "Gelding",
            color: "Bay",
            ownerName: "Sarah Johnson",
            location: "Meadowbrook Farm",
            microchip: "981234567890123",
            date: Date(),
            type: .lamenessExam,
            subjective: """
            Chief Complaint: Right front limb lameness, grade 2/5, noticed 3 days ago after training session.
            
            History: Owner reports Thunder was working well during dressage training when he suddenly became reluctant to extend the right front leg. No witnessed trauma. Horse has been resting in paddock since onset. No previous history of lameness.
            
            Recent Changes: Increased training intensity two weeks prior to event. New farrier visit 10 days ago.
            """,
            objective: """
            Visual Examination:
            • No visible swelling or heat in distal limb
            • Mild sensitivity on digital palpation of flexor tendons
            • No increased digital pulse
            • Normal hoof temperature
            
            Gait Analysis:
            • Lameness grade 2/5 at walk, more pronounced at trot
            • Positive response to flexion test (right front fetlock)
            • Lameness improves on soft ground
            
            Vital Signs: TPR within normal limits. General body condition score 6/9.
            """,
            assessment: """
            Primary Diagnosis: Suspected superficial digital flexor tendon strain (right front limb)
            
            Differential Diagnoses:
            • Suspensory ligament desmitis
            • Fetlock joint pathology
            • Distal limb soft tissue injury
            
            Recommended Diagnostics: Ultrasound examination of flexor tendons and suspensory ligament recommended to confirm diagnosis and assess severity.
            """,
            plan: """
            Immediate Treatment:
            • Stall rest with hand walking only (10 minutes 2x daily)
            • Cold therapy: 20 minutes 3x daily for 5 days
            • NSAIDs: Phenylbutazone 2g PO q12h for 7 days
            • Support bandaging when not being cold-hosed
            
            Follow-up Care:
            • Schedule ultrasound examination in 3 days
            • Re-evaluation in 2 weeks
            • Rehabilitation protocol to be determined based on ultrasound findings
            
            Client Education: Discussed importance of rest period, monitoring for progression, and realistic timeline for return to work (likely 6-12 weeks depending on severity).
            
            Prognosis: Good to guarded depending on ultrasound findings.
            """
        ),
        Consultation(
            patientName: "Bella",
            breed: "Quarter Horse",
            age: 5,
            sex: "Mare",
            color: "Chestnut",
            ownerName: "Mike Davis",
            location: "Sunset Stables",
            microchip: "981234567890124",
            date: Date().addingTimeInterval(-14400),
            type: .routineCheckup,
            subjective: "Annual wellness examination. No current concerns reported by owner.",
            objective: "Physical examination within normal limits. Body condition score 5/9. Vaccination records up to date.",
            assessment: "Healthy adult horse. No abnormalities detected.",
            plan: "Continue current care. Schedule dental exam in 6 months. Annual wellness exam in 1 year."
        ),
        Consultation(
            patientName: "Shadow",
            breed: "Arabian",
            age: 12,
            sex: "Gelding",
            color: "Grey",
            ownerName: "Jennifer Martinez",
            location: "Riverside Ranch",
            microchip: "981234567890125",
            date: Date().addingTimeInterval(-86400),
            type: .followUp,
            subjective: "Follow-up examination for colic episode 5 days ago. Owner reports horse is eating normally and manure production has returned to normal.",
            objective: "Gastrointestinal sounds present in all quadrants. Appetite normal. No signs of abdominal discomfort.",
            assessment: "Resolved simple colic. No residual concerns.",
            plan: "Resume normal activity. Monitor for any signs of recurrence. No medication needed at this time."
        )
    ]
}
