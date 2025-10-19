//
//  FeedDatabase.swift
//  Horsimize
//
//  Database of common horse feeds with nutritional info
//

import Foundation
import SwiftUI

class FeedDatabase: ObservableObject {
    @Published var feeds: [Feed] = []
    
    init() {
        loadFeedDatabase()
    }
    
    // MARK: - Search & Filter
    
    func searchFeeds(query: String) -> [Feed] {
        if query.isEmpty { return feeds }
        return feeds.filter {
            $0.brandName.localizedCaseInsensitiveContains(query) ||
            $0.productName.localizedCaseInsensitiveContains(query)
        }
    }
    
    func filterByType(_ type: FeedType) -> [Feed] {
        feeds.filter { $0.feedType == type }
    }
    
    func matchFeed(protein: Double, fat: Double, fiber: Double) -> Feed? {
        // Find closest match based on guaranteed analysis
        feeds.min(by: { feed1, feed2 in
            let diff1 = abs(feed1.crudeProtein - protein) +
                       abs(feed1.crudeFat - fat) +
                       abs(feed1.crudeFiber - fiber)
            let diff2 = abs(feed2.crudeProtein - protein) +
                       abs(feed2.crudeFat - fat) +
                       abs(feed2.crudeFiber - fiber)
            return diff1 < diff2
        })
    }
    
    // MARK: - Feed Database
    
    private func loadFeedDatabase() {
        feeds = [
            // PURINA FEEDS
            Feed(
                brandName: "Purina",
                productName: "Strategy Professional",
                feedType: .complete,
                crudeProtein: 12.0,
                crudeFat: 6.0,
                crudeFiber: 14.0,
                nsc: 22.0,
                calories: 1450,
                ingredients: ["Dehulled Soybean Meal", "Ground Corn", "Wheat Middlings", "Oats"],
                price: 23.99,
                bagWeight: 50,
                manufacturer: "Purina Mills",
                notes: "All-life-stages formula. Good for backyard horses with light work."
            ),
            
            Feed(
                brandName: "Purina",
                productName: "Omolene 200",
                feedType: .sweet,
                crudeProtein: 12.0,
                crudeFat: 4.0,
                crudeFiber: 10.0,
                nsc: 38.0,
                calories: 1350,
                ingredients: ["Cracked Corn", "Oats", "Molasses", "Wheat Middlings"],
                price: 21.99,
                bagWeight: 50,
                manufacturer: "Purina Mills",
                notes: "Classic sweet feed. HIGH NSC - not for IR/metabolic horses!"
            ),
            
            Feed(
                brandName: "Purina",
                productName: "Equine Senior",
                feedType: .senior,
                crudeProtein: 14.0,
                crudeFat: 6.0,
                crudeFiber: 18.0,
                nsc: 21.0,
                calories: 1250,
                ingredients: ["Soybean Hulls", "Beet Pulp", "Soybean Meal", "Rice Bran"],
                price: 26.99,
                bagWeight: 50,
                manufacturer: "Purina Mills",
                notes: "Easy to chew, highly digestible. Perfect for seniors 20+ years."
            ),
            
            // TRIPLE CROWN FEEDS
            Feed(
                brandName: "Triple Crown",
                productName: "Low Starch",
                feedType: .lowStarch,
                crudeProtein: 12.0,
                crudeFat: 6.0,
                crudeFiber: 20.0,
                nsc: 11.5,
                calories: 1200,
                ingredients: ["Beet Pulp", "Soybean Hulls", "Rice Bran", "Flaxseed"],
                price: 28.99,
                bagWeight: 50,
                manufacturer: "Triple Crown Nutrition",
                notes: "EXCELLENT for metabolic/IR horses. Very low NSC."
            ),
            
            Feed(
                brandName: "Triple Crown",
                productName: "Senior",
                feedType: .senior,
                crudeProtein: 12.0,
                crudeFat: 10.0,
                crudeFiber: 20.0,
                nsc: 13.0,
                calories: 1450,
                ingredients: ["Beet Pulp", "Rice Bran", "Soybean Hulls", "Ground Flaxseed"],
                price: 29.99,
                bagWeight: 50,
                manufacturer: "Triple Crown Nutrition",
                notes: "High fat for weight gain in seniors. Low NSC."
            ),
            
            Feed(
                brandName: "Triple Crown",
                productName: "Growth",
                feedType: .pelleted,
                crudeProtein: 16.0,
                crudeFat: 6.0,
                crudeFiber: 18.0,
                nsc: 18.0,
                calories: 1350,
                ingredients: ["Soybean Meal", "Beet Pulp", "Rice Bran", "Alfalfa Meal"],
                price: 32.99,
                bagWeight: 50,
                manufacturer: "Triple Crown Nutrition",
                notes: "For growing horses (weanlings to 3 years). High protein."
            ),
            
            // SAFECHOICE FEEDS
            Feed(
                brandName: "SafeChoice",
                productName: "Original",
                feedType: .pelleted,
                crudeProtein: 14.0,
                crudeFat: 7.0,
                crudeFiber: 16.0,
                nsc: 19.0,
                calories: 1400,
                ingredients: ["Soybean Hulls", "Beet Pulp", "Ground Corn", "Rice Bran"],
                price: 26.99,
                bagWeight: 50,
                manufacturer: "Nutrena",
                notes: "Moderate NSC. Good all-around feed."
            ),
            
            Feed(
                brandName: "SafeChoice",
                productName: "Special Care",
                feedType: .lowStarch,
                crudeProtein: 12.0,
                crudeFat: 10.0,
                crudeFiber: 22.0,
                nsc: 11.0,
                calories: 1500,
                ingredients: ["Beet Pulp", "Soybean Hulls", "Rice Bran", "Vegetable Oil"],
                price: 31.99,
                bagWeight: 50,
                manufacturer: "Nutrena",
                notes: "Low NSC, high fat. Great for metabolic horses."
            ),
            
            Feed(
                brandName: "SafeChoice",
                productName: "Senior",
                feedType: .senior,
                crudeProtein: 14.0,
                crudeFat: 8.0,
                crudeFiber: 20.0,
                nsc: 16.0,
                calories: 1350,
                ingredients: ["Beet Pulp", "Rice Bran", "Soybean Meal", "Ground Flaxseed"],
                price: 28.99,
                bagWeight: 50,
                manufacturer: "Nutrena",
                notes: "Easy to chew, digestible. Good for seniors."
            ),
            
            // BUCKEYE FEEDS
            Feed(
                brandName: "Buckeye",
                productName: "Safe 'N Easy Senior",
                feedType: .senior,
                crudeProtein: 14.0,
                crudeFat: 8.0,
                crudeFiber: 18.0,
                nsc: 17.0,
                calories: 1400,
                ingredients: ["Beet Pulp", "Soybean Hulls", "Rice Bran", "Ground Flaxseed"],
                price: 27.99,
                bagWeight: 50,
                manufacturer: "Buckeye Nutrition",
                notes: "Complete senior feed. Can replace forage if needed."
            ),
            
            Feed(
                brandName: "Buckeye",
                productName: "Gro 'N Win",
                feedType: .pelleted,
                crudeProtein: 16.0,
                crudeFat: 7.0,
                crudeFiber: 12.0,
                nsc: 24.0,
                calories: 1500,
                ingredients: ["Soybean Meal", "Ground Corn", "Oats", "Rice Bran"],
                price: 29.99,
                bagWeight: 50,
                manufacturer: "Buckeye Nutrition",
                notes: "For growing horses and performance horses."
            ),
            
            // RATION BALANCERS
            Feed(
                brandName: "Triple Crown",
                productName: "30% Ration Balancer",
                feedType: .balancer,
                crudeProtein: 30.0,
                crudeFat: 6.0,
                crudeFiber: 12.0,
                nsc: 15.0,
                calories: 1400,
                ingredients: ["Soybean Meal", "Wheat Middlings", "Rice Bran"],
                price: 39.99,
                bagWeight: 50,
                manufacturer: "Triple Crown Nutrition",
                notes: "Feed only 1-2 lbs/day. Perfect for easy keepers on pasture."
            ),
            
            Feed(
                brandName: "Purina",
                productName: "Enrich Plus Ration Balancer",
                feedType: .balancer,
                crudeProtein: 32.0,
                crudeFat: 6.0,
                crudeFiber: 10.0,
                nsc: 18.0,
                calories: 1500,
                ingredients: ["Soybean Meal", "Wheat Middlings", "Ground Flaxseed"],
                price: 42.99,
                bagWeight: 50,
                manufacturer: "Purina Mills",
                notes: "High protein balancer. Feed 1 lb per 500 lbs body weight."
            ),
            
            // PERFORMANCE FEEDS
            Feed(
                brandName: "Purina",
                productName: "Ultium Competition",
                feedType: .performance,
                crudeProtein: 14.0,
                crudeFat: 14.0,
                crudeFiber: 14.0,
                nsc: 18.0,
                calories: 1650,
                ingredients: ["Rice Bran", "Vegetable Oil", "Ground Corn", "Soybean Meal"],
                price: 34.99,
                bagWeight: 50,
                manufacturer: "Purina Mills",
                notes: "High fat for energy. For performance horses in heavy work."
            ),
            
            Feed(
                brandName: "Triple Crown",
                productName: "Competitor",
                feedType: .performance,
                crudeProtein: 14.0,
                crudeFat: 12.0,
                crudeFiber: 18.0,
                nsc: 20.0,
                calories: 1600,
                ingredients: ["Rice Bran", "Beet Pulp", "Ground Flaxseed", "Soybean Meal"],
                price: 36.99,
                bagWeight: 50,
                manufacturer: "Triple Crown Nutrition",
                notes: "High fat, controlled NSC. For working horses."
            ),
            
            // CLASSIC GRAINS
            Feed(
                brandName: "Generic",
                productName: "Whole Oats",
                feedType: .concentrate,
                crudeProtein: 11.0,
                crudeFat: 4.0,
                crudeFiber: 12.0,
                nsc: 42.0,
                calories: 1300,
                ingredients: ["Whole Oats"],
                price: 16.99,
                bagWeight: 50,
                manufacturer: "Various",
                notes: "Traditional grain. HIGH NSC - use caution with metabolic horses."
            ),
            
            Feed(
                brandName: "Generic",
                productName: "Cracked Corn",
                feedType: .concentrate,
                crudeProtein: 8.0,
                crudeFat: 4.0,
                crudeFiber: 3.0,
                nsc: 65.0,
                calories: 1500,
                ingredients: ["Cracked Corn"],
                price: 12.99,
                bagWeight: 50,
                manufacturer: "Various",
                notes: "VERY HIGH NSC. Use sparingly. Good for weight gain."
            ),
            
            // LOW NSC OPTIONS
            Feed(
                brandName: "Timothy Balance",
                productName: "Cubes",
                feedType: .complete,
                crudeProtein: 10.0,
                crudeFat: 2.0,
                crudeFiber: 30.0,
                nsc: 10.0,
                calories: 900,
                ingredients: ["Timothy Hay"],
                price: 24.99,
                bagWeight: 50,
                manufacturer: "Various",
                notes: "Essentially compressed timothy hay. VERY low NSC. Great for metabolic horses."
            ),
            
            Feed(
                brandName: "Alfalfa",
                productName: "Pellets",
                feedType: .pelleted,
                crudeProtein: 16.0,
                crudeFat: 2.0,
                crudeFiber: 25.0,
                nsc: 12.0,
                calories: 1000,
                ingredients: ["Alfalfa Hay"],
                price: 19.99,
                bagWeight: 50,
                manufacturer: "Various",
                notes: "High protein, low NSC. Good for weight gain without sugar."
            ),
            
            // BEET PULP
            Feed(
                brandName: "Generic",
                productName: "Beet Pulp Shreds",
                feedType: .supplement,
                crudeProtein: 9.0,
                crudeFat: 0.5,
                crudeFiber: 18.0,
                nsc: 8.0,
                calories: 950,
                ingredients: ["Sugar Beet Pulp"],
                price: 21.99,
                bagWeight: 40,
                manufacturer: "Various",
                notes: "Must be soaked before feeding. Excellent fiber source. Very low NSC."
            )
        ]
    }
}
