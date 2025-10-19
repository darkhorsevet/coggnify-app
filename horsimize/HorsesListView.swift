//
//  HorsesListView.swift
//  Horsimize
//
//  Display list of user's horses
//

import SwiftUI

struct HorsesListView: View {
    @EnvironmentObject var horseManager: HorseManager
    @State private var showingAddHorse = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if horseManager.horses.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "figure.equestrian.sports")
                            .font(.system(size: 80))
                            .foregroundColor(.green.opacity(0.5))
                        
                        Text("No Horses Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Add your first horse to get personalized\nfeed recommendations")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button(action: { showingAddHorse = true }) {
                            Label("Add Your First Horse", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                        .padding(.top)
                    }
                    .padding()
                } else {
                    // Horse list
                    List {
                        ForEach(horseManager.horses) { horse in
                            NavigationLink(destination: HorseDetailView(horse: horse)) {
                                HorseRowView(horse: horse)
                            }
                        }
                        .onDelete(perform: deleteHorses)
                    }
                }
            }
            .navigationTitle("My Horses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddHorse = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHorse) {
                AddHorseView()
            }
        }
    }
    
    private func deleteHorses(at offsets: IndexSet) {
        for index in offsets {
            horseManager.deleteHorse(horseManager.horses[index])
        }
    }
}

// MARK: - Horse Row

struct HorseRowView: View {
    let horse: Horse
    
    var body: some View {
        HStack(spacing: 15) {
            // Horse icon/avatar
            ZStack {
                Circle()
                    .fill(bcsColor)
                    .frame(width: 60, height: 60)
                
                Text("🐴")
                    .font(.system(size: 30))
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(horse.name)
                    .font(.headline)
                
                Text("\(horse.breed) • \(horse.age) yrs • \(horse.weight) lbs")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Label("BCS \(horse.currentBCS)", systemImage: "ruler")
                        .font(.caption)
                        .foregroundColor(bcsTextColor)
                    
                    Text(horse.activityLevel.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private var bcsColor: Color {
        switch horse.currentBCS {
        case 1...3: return .red.opacity(0.3)
        case 4...6: return .green.opacity(0.3)
        case 7...9: return .orange.opacity(0.3)
        default: return .gray.opacity(0.3)
        }
    }
    
    private var bcsTextColor: Color {
        switch horse.currentBCS {
        case 1...3: return .red
        case 4...6: return .green
        case 7...9: return .orange
        default: return .gray
        }
    }
}
