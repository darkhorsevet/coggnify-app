//
//  FeedRecommendationEngine.swift
//  Horsimize
//
//  AI recommendation engine for matching feeds to horses
//

import Foundation

class FeedRecommendationEngine {
    
    // MARK: - Get Recommendations
    
    func getRecommendations(for horse: Horse, from feeds: [Feed]) -> [FeedRecommendation] {
        var recommendations: [FeedRecommendation] = []
        
        for feed in feeds {
            let (rating, reason, pros, cons) = evaluateFeed(feed, for: horse)
            let feedingGuideline = calculateFeedingAmount(for: horse, feed: feed)
            let monthlyCost = calculateMonthlyCost(for: horse, feed: feed)
            
            let recommendation = FeedRecommendation(
                feed: feed,
                rating: rating,
                matchReason: reason,
                pros: pros,
                cons: cons,
                feedingGuideline: feedingGuideline,
                monthlyCost: monthlyCost
            )
            
            recommendations.append(recommendation)
        }
        
        // Sort by rating (highest first)
        recommendations.sort { $0.rating > $1.rating }
        
        return recommendations
    }
    
    // MARK: - Feed Evaluation
    
    private func evaluateFeed(_ feed: Feed, for horse: Horse) -> (rating: Int, reason: String, pros: [String], cons: [String]) {
        var rating = 3 // Start with neutral
        var pros: [String] = []
        var cons: [String] = []
        var reason = ""
        
        // Check for metabolic/IR horses
        let hasMetabolic = horse.healthConditions.contains(.metabolic) || 
                          horse.healthConditions.contains(.cushing) ||
                          horse.healthConditions.contains(.laminitis)
        
        if hasMetabolic {
            if let nsc = feed.nsc, nsc <= 12.0 {
                rating += 2
                pros.append("Very low NSC (\(String(format: "%.1f", nsc))%) - safe for metabolic horses")
                reason = "Excellent choice for metabolic/IR horses"
            } else if let nsc = feed.nsc, nsc > 25.0 {
                rating -= 2
                cons.append("High NSC (\(String(format: "%.1f", nsc))%) - NOT safe for metabolic horses")
                reason = "Too high in sugar/starch for metabolic issues"
            } else if feed.feedType == .sweet || feed.feedType == .concentrate {
                rating -= 1
                cons.append("Traditional grain - likely high NSC")
            }
        }
        
        // Check for seniors
        if horse.activityLevel == .senior || horse.age >= 20 {
            if feed.feedType == .senior {
                rating += 2
                pros.append("Specifically formulated for senior horses")
                reason = "Perfect for senior horses"
            }
            
            if feed.crudeFiber >= 18.0 {
                rating += 1
                pros.append("High fiber for easy digestion")
            }
            
            if feed.crudeFat >= 8.0 {
                pros.append("High fat for weight maintenance")
            }
        }
        
        // Check for performance horses
        if horse.activityLevel == .performance || horse.activityLevel == .heavy {
            if feed.feedType == .performance {
                rating += 2
                pros.append("Formulated for high-performance horses")
                reason = "Ideal for intense work and competition"
            }
            
            if feed.crudeFat >= 10.0 {
                rating += 1
                pros.append("High fat for sustained energy")
            }
            
            if feed.crudeProtein >= 14.0 {
                pros.append("Adequate protein for muscle maintenance")
            }
        }
        
        // Check for maintenance/easy keepers
        if horse.activityLevel == .maintenance {
            if feed.feedType == .balancer {
                rating += 2
                pros.append("Ration balancer - perfect for easy keepers")
                reason = "Ideal for horses on good pasture"
            }
            
            if (feed.calories ?? 0) < 1200 {
                rating += 1
                pros.append("Lower calorie content")
            }
        }
        
        // Check BCS
        if horse.currentBCS <= 3 {
            // Thin horse - needs calories
            if feed.crudeFat >= 8.0 {
                rating += 1
                pros.append("High fat helps with weight gain")
            }
            
            if (feed.calories ?? 0) >= 1400 {
                pros.append("High calorie content for weight gain")
            }
        } else if horse.currentBCS >= 7 {
            // Overweight horse - needs restriction
            if feed.feedType == .balancer {
                rating += 1
                pros.append("Low feeding rate helps with weight control")
            }
            
            if (feed.calories ?? 0) <= 1200 {
                pros.append("Lower calories support weight loss")
            } else if (feed.calories ?? 0) >= 1500 {
                rating -= 1
                cons.append("High calorie - may promote weight gain")
            }
        }
        
        // Check for ulcers
        if horse.healthConditions.contains(.ulcers) {
            if feed.crudeFiber >= 18.0 {
                rating += 1
                pros.append("High fiber supports gastric health")
            }
            
            if feed.feedType == .sweet {
                rating -= 1
                cons.append("Sweet feed may irritate ulcers")
            }
        }
        
        // Check for tying up/EPSM
        if horse.healthConditions.contains(.tying_up) {
            if let nsc = feed.nsc, nsc <= 12.0 {
                rating += 2
                pros.append("Low NSC diet recommended for EPSM")
            }
            
            if feed.crudeFat >= 10.0 {
                rating += 1
                pros.append("High fat for energy without carbs")
            }
        }
        
        // Check for growing horses
        if horse.activityLevel == .growing || horse.age <= 3 {
            if feed.feedType == .pelleted && feed.crudeProtein >= 14.0 {
                rating += 1
                pros.append("Good protein for growth")
            }
            
            if feed.productName.lowercased().contains("growth") || 
               feed.productName.lowercased().contains("grow") {
                rating += 1
                pros.append("Formulated for growing horses")
            }
        }
        
        // Dental issues
        if horse.healthConditions.contains(.dental) {
            if feed.feedType == .pelleted || feed.feedType == .senior {
                rating += 1
                pros.append("Easy to chew for horses with dental issues")
            }
        }
        
        // Price considerations
        if let pricePerLb = feed.pricePerPound {
            if pricePerLb < 0.50 {
                pros.append("Budget-friendly option")
            } else if pricePerLb > 0.70 {
                cons.append("Premium price point")
            }
        }
        
        // General quality indicators
        if feed.brandName == "Triple Crown" || feed.brandName == "SafeChoice" {
            pros.append("Trusted premium brand")
        }
        
        // Clamp rating between 1-5
        rating = max(1, min(5, rating))
        
        // Generate default reason if none set
        if reason.isEmpty {
            reason = generateDefaultReason(rating: rating, feedType: feed.feedType)
        }
        
        return (rating, reason, pros, cons)
    }
    
    private func generateDefaultReason(rating: Int, feedType: FeedType) -> String {
        switch rating {
        case 5: return "Excellent match for your horse's needs"
        case 4: return "Very good option for your horse"
        case 3: return "Suitable option, consider alternatives"
        case 2: return "Not ideal for your horse's specific needs"
        default: return "Not recommended for your horse"
        }
    }
    
    // MARK: - Feeding Amount Calculation
    
    private func calculateFeedingAmount(for horse: Horse, feed: Feed) -> String {
        // Base feeding rate: 0.5-2% of body weight per day
        // Adjusted for activity level, BCS, and feed type
        
        let bodyWeight = Double(horse.weight)
        var feedingRate: Double = 1.5 // Default 1.5% body weight
        
        // Adjust for activity
        switch horse.activityLevel {
        case .maintenance: feedingRate = 1.5
        case .light: feedingRate = 1.75
        case .moderate: feedingRate = 2.0
        case .heavy: feedingRate = 2.25
        case .performance: feedingRate = 2.5
        case .breeding: feedingRate = 2.0
        case .growing: feedingRate = 2.5
        case .senior: feedingRate = 1.5
        }
        
        // Adjust for BCS
        if horse.currentBCS <= 3 {
            feedingRate += 0.5 // Need to gain weight
        } else if horse.currentBCS >= 7 {
            feedingRate -= 0.5 // Need to lose weight
        }
        
        // Calculate total daily feed needed
        let totalDailyFeed = (bodyWeight * feedingRate) / 100.0
        
        // Ration balancers are fed at much lower rates
        if feed.feedType == .balancer {
            let balancerAmount = bodyWeight / 500.0 // 1 lb per 500 lbs body weight
            return String(format: "%.1f lbs per day (%.1f lbs AM, %.1f lbs PM)", 
                         balancerAmount, balancerAmount / 2.0, balancerAmount / 2.0)
        }
        
        // Concentrates/supplements are typically 25-50% of ration
        let concentrateAmount = totalDailyFeed * 0.35 // ~35% as concentrate
        let halfAmount = concentrateAmount / 2.0
        
        return String(format: "%.1f lbs per day (%.1f lbs AM, %.1f lbs PM)", 
                     concentrateAmount, halfAmount, halfAmount)
    }
    
    // MARK: - Cost Calculation
    
    private func calculateMonthlyCost(for horse: Horse, feed: Feed) -> Double? {
        guard let pricePerLb = feed.pricePerPound else { return nil }
        
        // Estimate daily feeding amount
        let bodyWeight = Double(horse.weight)
        var dailyAmount: Double = 5.0 // Default 5 lbs/day
        
        if feed.feedType == .balancer {
            dailyAmount = bodyWeight / 500.0 // 1 lb per 500 lbs
        } else {
            // Adjust based on activity
            switch horse.activityLevel {
            case .maintenance: dailyAmount = 3.0
            case .light: dailyAmount = 4.0
            case .moderate: dailyAmount = 6.0
            case .heavy: dailyAmount = 8.0
            case .performance: dailyAmount = 10.0
            case .breeding: dailyAmount = 6.0
            case .growing: dailyAmount = 8.0
            case .senior: dailyAmount = 5.0
            }
        }
        
        // Monthly cost = daily amount * 30 days * price per pound
        return dailyAmount * 30.0 * pricePerLb
    }
}
