//
//  SettingsView.swift
//  VetScribe
//
//  App settings and preferences
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("aiProvider") private var aiProvider = "OpenAI Whisper"
    @AppStorage("autoSave") private var autoSave = true
    @AppStorage("medicalTerminology") private var medicalTerminology = "Equine Veterinary"
    @AppStorage("exportFormat") private var exportFormat = "PDF"
    @AppStorage("autoRecordCalls") private var autoRecordCalls = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("AI Transcription") {
                    Picker("Provider", selection: $aiProvider) {
                        Text("OpenAI Whisper").tag("OpenAI Whisper")
                        Text("AssemblyAI").tag("AssemblyAI")
                        Text("Google Speech-to-Text").tag("Google Speech-to-Text")
                        Text("AWS Transcribe Medical").tag("AWS Transcribe Medical")
                    }
                    
                    Picker("Medical Terminology", selection: $medicalTerminology) {
                        Text("Equine Veterinary").tag("Equine Veterinary")
                        Text("General Veterinary").tag("General Veterinary")
                        Text("Small Animal").tag("Small Animal")
                    }
                }
                
                Section("Phone Call Recording") {
                    Toggle("Auto-record calls", isOn: $autoRecordCalls)
                    
                    Text("⚠️ Recording laws vary by location. Always inform callers they're being recorded.")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                Section("Recording") {
                    Toggle("Auto-save recordings", isOn: $autoSave)
                    Text("Automatically save audio recordings after transcription")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Export") {
                    Picker("Default Format", selection: $exportFormat) {
                        Text("PDF").tag("PDF")
                        Text("SOAP Text").tag("SOAP")
                        Text("Microsoft Word").tag("DOCX")
                        Text("Plain Text").tag("TXT")
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - General Settings
struct GeneralSettingsView: View {
    @Binding var aiProvider: String
    @Binding var autoSave: Bool
    @Binding var medicalTerminology: String
    
    var body: some View {
        Form {
            Section("AI Transcription") {
                Picker("Provider:", selection: $aiProvider) {
                    Text("OpenAI Whisper").tag("OpenAI Whisper")
                    Text("AssemblyAI").tag("AssemblyAI")
                    Text("Google Speech-to-Text").tag("Google Speech-to-Text")
                    Text("AWS Transcribe Medical").tag("AWS Transcribe Medical")
                }
                
                Picker("Medical Terminology:", selection: $medicalTerminology) {
                    Text("Equine Veterinary").tag("Equine Veterinary")
                    Text("General Veterinary").tag("General Veterinary")
                    Text("Small Animal").tag("Small Animal")
                }
            }
            
            Section("Recording") {
                Toggle("Auto-save recordings", isOn: $autoSave)
                Text("Automatically save audio recordings after transcription")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Integration Settings
struct IntegrationSettingsView: View {
    @State private var emrConnected = false
    @State private var apiKey = ""
    
    var body: some View {
        Form {
            Section("Practice Management Software") {
                Toggle("Connect to EMR", isOn: $emrConnected)
                
                if emrConnected {
                    SecureField("API Key:", text: $apiKey)
                    Button("Test Connection") {
                        // Test EMR connection
                    }
                }
            }
            
            Section("Cloud Sync") {
                Text("iCloud sync enabled by default")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Export Settings
struct ExportSettingsView: View {
    @Binding var exportFormat: String
    
    var body: some View {
        Form {
            Section("Default Export Format") {
                Picker("Format:", selection: $exportFormat) {
                    Text("PDF").tag("PDF")
                    Text("SOAP Text").tag("SOAP")
                    Text("Microsoft Word").tag("DOCX")
                    Text("Plain Text").tag("TXT")
                }
            }
            
            Section("PDF Options") {
                Toggle("Include practice logo", isOn: .constant(true))
                Toggle("Include timestamp", isOn: .constant(true))
                Toggle("Include audio duration", isOn: .constant(true))
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

#Preview {
    SettingsView()
}
