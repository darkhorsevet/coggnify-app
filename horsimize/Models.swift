//
//  Models.swift
//  Horsimize
//
//  Data models for horses, feeds, and nutrition
//

import Foundation
import SwiftUI

// MARK: - Horse Model

struct Horse: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var breed: String
    var age: Int // years
    var weight: Int // pounds
    var activityLevel: ActivityLevel
    var healthConditions: [HealthCondition]
    var currentBCS: Int // 1-9 scale
    var currentFeed: Feed?
    var feedingAmount: String // e.g., "2 lbs twice daily"
    var photos: [String] // Photo URLs/paths
    var bcsHistory: [BCSEntry]
    var dateAdded: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        breed: String,
        age: Int,
        weight: Int,
        activityLevel: ActivityLevel,
        healthConditions: [HealthCondition] = [],
        currentBCS: Int = 5,
        currentFeed: Feed? = nil,
        feedingAmount: String = "",
        photos: [String] = [],
        bcsHistory: [BCSEntry] = [],
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.breed = breed
        self.age = age
        self.weight = weight
        self.activityLevel = activityLevel
        self.healthConditions = healthConditions
        self.currentBCS = currentBCS
        self.currentFeed = currentFeed
        self.feedingAmount = feedingAmount
        self.photos = photos
        self.bcsHistory = bcsHistory
        self.dateAdded = dateAdded
    }
}

// MARK: - Activity Level

enum ActivityLevel: String, Codable, CaseIterable {
    case maintenance = "Maintenance"
    case light = "Light Work"
    case moderate = "Moderate Work"
    case heavy = "Heavy Work"
    case performance = "Performance"
    case breeding = "Breeding"
    case growing = "Growing"
    case senior = "Senior"
    
    var description: String {
        switch self {
        case .maintenance: return "Pasture pet, minimal activity"
        case .light: return "Trail riding 1-2x/week"
        case .moderate: return "Regular riding/training"
        case .heavy: return "Intense work, competitions"
        case .performance: return "Racing, high-level competition"
        case .breeding: return "Pregnant or lactating mare"
        case .growing: return "Weanling to 3 years old"
        case .senior: return "20+ years old"
        }
    }
}

// MARK: - Health Conditions

enum HealthCondition: String, Codable, CaseIterable {
    case metabolic = "Metabolic/IR"
    case cushing = "Cushing's/PPID"
    case laminitis = "Laminitis History"
    case ulcers = "Gastric Ulcers"
    case tying_up = "Tying Up/EPSM"
    case dental = "Dental Issues"
    case respiratory = "Respiratory Issues"
    case arthritis = "Arthritis"
    case none = "No Health Issues"
    
    var icon: String {
        switch self {
        case .metabolic: return "⚠️"
        case .cushing: return "💊"
        case .laminitis: return "🦵"
        case .ulcers: return "🔥"
        case .tying_up: return "💪"
        case .dental: return "🦷"
        case .respiratory: return "💨"
        case .arthritis: return "🦴"
        case .none: return "✅"
        }
    }
}

// MARK: - Body Condition Score Entry

struct BCSEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var score: Int // 1-9
    var weight: Int? // Optional weight in pounds
    var notes: String
    var photoPath: String?
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        score: Int,
        weight: Int? = nil,
        notes: String = "",
        photoPath: String? = nil
    ) {
        self.id = id
        self.date = date
        self.score = score
        self.weight = weight
        self.notes = notes
        self.photoPath = photoPath
    }
}

// MARK: - Feed Model

struct Feed: Identifiable, Codable, Hashable {
    let id: UUID
    var brandName: String
    var productName: String
    var feedType: FeedType
    
    // Guaranteed Analysis
    var crudeProtein: Double // %
    var crudeFat: Double // %
    var crudeFiber: Double // %
    var nsc: Double? // Non-Structural Carbohydrates (starch + sugar) %
    var calories: Int? // per pound (kcal/lb)
    
    // Additional info
    var ingredients: [String]
    var price: Double? // per bag
    var bagWeight: Int? // pounds
    var pricePerPound: Double? // calculated
    var manufacturer: String
    var imageURL: String?
    var notes: String
    
    init(
        id: UUID = UUID(),
        brandName: String,
        productName: String,
        feedType: FeedType,
        crudeProtein: Double,
        crudeFat: Double,
        crudeFiber: Double,
        nsc: Double? = nil,
        calories: Int? = nil,
        ingredients: [String] = [],
        price: Double? = nil,
        bagWeight: Int? = nil,
        manufacturer: String,
        imageURL: String? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.brandName = brandName
        self.productName = productName
        self.feedType = feedType
        self.crudeProtein = crudeProtein
        self.crudeFat = crudeFat
        self.crudeFiber = crudeFiber
        self.nsc = nsc
        self.calories = calories
        self.ingredients = ingredients
        self.price = price
        self.bagWeight = bagWeight
        self.manufacturer = manufacturer
        self.imageURL = imageURL
        self.notes = notes
        
        // Calculate price per pound
        if let price = price, let weight = bagWeight, weight > 0 {
            self.pricePerPound = price / Double(weight)
        } else {
            self.pricePerPound = nil
        }
    }
}

// MARK: - Feed Type

enum FeedType: String, Codable, CaseIterable {
    case complete = "Complete Feed"
    case concentrate = "Concentrate/Grain"
    case pelleted = "Pelleted Feed"
    case sweet = "Sweet Feed"
    case senior = "Senior Feed"
    case performance = "Performance Feed"
    case lowStarch = "Low Starch/NSC"
    case balancer = "Ration Balancer"
    case supplement = "Supplement"
    
    var icon: String {
        switch self {
        case .complete: return "🌾"
        case .concentrate: return "🥣"
        case .pelleted: return "⚫️"
        case .sweet: return "🍯"
        case .senior: return "👴"
        case .performance: return "⚡️"
        case .lowStarch: return "🥬"
        case .balancer: return "⚖️"
        case .supplement: return "💊"
        }
    }
}

// MARK: - Feed Recommendation

struct FeedRecommendation: Identifiable {
    let id = UUID()
    var feed: Feed
    var rating: Int // 1-5 stars
    var matchReason: String
    var pros: [String]
    var cons: [String]
    var feedingGuideline: String
    var monthlyCost: Double?
}

// MARK: - Scanned Feed Result

struct ScannedFeedResult {
    var recognizedText: String
    var extractedProtein: Double?
    var extractedFat: Double?
    var extractedFiber: Double?
    var extractedNSC: Double?
    var matchedFeed: Feed?
    var confidence: Double // 0-1
}
