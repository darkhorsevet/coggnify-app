//
//  MainTabView.swift
//  Horsimize
//
//  Main navigation with tabs for horses, scanning, and BCS
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var horseManager: HorseManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // My Horses
            HorsesListView()
                .tabItem {
                    Label("My Horses", systemImage: "figure.equestrian.sports")
                }
                .tag(0)
            
            // Scan Feed Tag
            FeedScannerView()
                .tabItem {
                    Label("Scan Feed", systemImage: "barcode.viewfinder")
                }
                .tag(1)
            
            // Body Condition Score
            BCSAnalyzerView()
                .tabItem {
                    Label("Body Score", systemImage: "camera.fill")
                }
                .tag(2)
            
            // Feed Library
            FeedLibraryView()
                .tabItem {
                    Label("Feed Library", systemImage: "books.vertical.fill")
                }
                .tag(3)
            
            // Settings
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .accentColor(.green)
    }
}
