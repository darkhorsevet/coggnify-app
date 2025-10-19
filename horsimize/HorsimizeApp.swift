//
//  HorsimizeApp.swift
//  Horsimize
//
//  AI-Powered Equine Nutrition Assistant
//  Scan feed tags, assess body condition, get expert recommendations
//

import SwiftUI

@main
struct HorsimizeApp: App {
    @StateObject private var horseManager = HorseManager()
    @StateObject private var feedDatabase = FeedDatabase()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(horseManager)
                .environmentObject(feedDatabase)
        }
    }
}
