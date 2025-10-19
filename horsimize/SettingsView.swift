//
//  SettingsView.swift
//  Horsimize
//
//  App settings and information
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("measurementUnit") private var measurementUnit = "Imperial"
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("darkMode") private var darkMode = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    Picker("Measurement Unit", selection: $measurementUnit) {
                        Text("Imperial (lbs)").tag("Imperial")
                        Text("Metric (kg)").tag("Metric")
                    }
                    
                    Toggle("Enable Notifications", isOn: $enableNotifications)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (MVP)")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://horsimize.com/support")!) {
                        HStack {
                            Text("Support")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                    }
                    
                    Link(destination: URL(string: "https://horsimize.com/privacy")!) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                    }
                }
                
                Section("Data") {
                    Button(role: .destructive) {
                        // TODO: Clear all data
                    } label: {
                        Text("Clear All Data")
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🐴 Horsimize")
                            .font(.headline)
                        
                        Text("AI-powered equine nutrition assistant for horse owners. Scan feed tags, assess body condition, and get expert recommendations.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Built by an equine veterinarian who understands your horse's needs.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
