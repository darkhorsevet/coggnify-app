//
//  OfflineManager.swift
//  Notalyze
//
//  Manages offline mode and data synchronization
//

import Foundation
import Network
import Combine

class OfflineManager: ObservableObject {
    @Published var isOnline = true
    @Published var hasCachedData = false
    @Published var pendingSyncCount = 0
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private let storage = OfflineStorage.shared
    
    init() {
        setupNetworkMonitoring()
        checkCachedData()
    }
    
    // MARK: - Network Monitoring
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let wasOffline = !(self?.isOnline ?? true)
                self?.isOnline = path.status == .satisfied
                
                // If we just came back online, sync
                if wasOffline && (self?.isOnline ?? false) {
                    self?.syncPendingData()
                }
                
                print(self?.isOnline ?? false ? "📶 Online" : "📡 Offline mode")
            }
        }
        monitor.start(queue: queue)
    }
    
    private func checkCachedData() {
        hasCachedData = storage.hasOfflineData()
        pendingSyncCount = storage.pendingSyncCount()
    }
    
    // MARK: - Offline Data Access
    
    func getOfflineProtocols() -> [EmergencyProtocol: String] {
        return storage.loadProtocols()
    }
    
    func getOfflineDrugDatabase() -> DrugDatabase {
        return storage.loadDrugDatabase()
    }
    
    func getOfflineVitalRanges() -> VitalRanges {
        return storage.loadVitalRanges()
    }
    
    func getCachedConsultations() -> [Consultation] {
        return storage.loadCachedConsultations()
    }
    
    // MARK: - Queue for Sync
    
    func queueForSync(_ item: SyncItem) {
        storage.addToSyncQueue(item)
        pendingSyncCount += 1
    }
    
    private func syncPendingData() {
        Task {
            let items = storage.getSyncQueue()
            
            for item in items {
                do {
                    try await syncItem(item)
                    storage.removeFromSyncQueue(item)
                    await MainActor.run {
                        pendingSyncCount -= 1
                    }
                } catch {
                    print("Failed to sync item: \(error)")
                }
            }
        }
    }
    
    private func syncItem(_ item: SyncItem) async throws {
        // Sync with backend/cloud when online
        switch item.type {
        case .consultation:
            print("Syncing consultation: \(item.id)")
        case .estimate:
            print("Syncing estimate: \(item.id)")
        case .recording:
            print("Syncing recording: \(item.id)")
        }
    }
    
    // MARK: - Cache Management
    
    func updateOfflineCache() async {
        // Download and cache essential data when online
        guard isOnline else { return }
        
        await storage.cacheProtocols()
        await storage.cacheDrugDatabase()
        await storage.cacheVitalRanges()
        
        await MainActor.run {
            hasCachedData = true
        }
    }
    
    func clearCache() {
        storage.clearCache()
        hasCachedData = false
    }
}

// MARK: - Offline Storage

class OfflineStorage {
    static let shared = OfflineStorage()
    
    private let fileManager = FileManager.default
    private var offlineDirectory: URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("OfflineData", isDirectory: true)
    }
    
    init() {
        createOfflineDirectory()
    }
    
    private func createOfflineDirectory() {
        try? fileManager.createDirectory(at: offlineDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Emergency Protocols (Always Available Offline)
    
    func loadProtocols() -> [EmergencyProtocol: String] {
        return [
            .colic: """
            COLIC EMERGENCY PROTOCOL (Offline)
            
            VITAL SIGNS:
            • Normal HR: 28-44 bpm
            • Normal RR: 8-16 bpm  
            • Normal Temp: 99-101°F
            
            PAIN SCALE:
            Grade 1: Mild discomfort
            Grade 2: Pawing, lying down
            Grade 3: Rolling, thrashing
            Grade 4: Violent
            
            RED FLAGS (REFER):
            🚨 HR >60 and rising
            🚨 No gut sounds
            🚨 Dark/toxic membranes
            🚨 >2L reflux on tube
            🚨 Severe unrelenting pain
            
            IMMEDIATE ACTIONS:
            1. Pass NG tube
            2. Rectal exam
            3. Assess cardiovascular
            4. Pain control if appropriate
            
            MEDICATIONS:
            • Flunixin: 1.1 mg/kg IV
            • Xylazine: 0.5-1.0 mg/kg IV
            • Buscopan: 0.3 mg/kg IV
            """,
            
            .laceration: """
            LACERATION PROTOCOL (Offline)
            
            ASSESSMENT:
            1. Depth and location
            2. Synovial involvement?
            3. Neurovascular damage?
            4. Contamination level
            5. Time since injury
            
            SYNOVIAL TEST:
            • Joint effusion present?
            • Needle test for communication
            • Tendon sheath involvement?
            
            TREATMENT:
            Clean (<6hrs):
            - Primary closure candidate
            - Clip, clean, lavage
            - Primary sutures
            
            Contaminated (>6hrs):
            - Delayed closure
            - Debride tissue
            - Second intention
            
            MEDICATIONS:
            • Tetanus prophylaxis
            • Penicillin: 22,000 IU/kg IM q12h
            • Gentamicin: 6.6 mg/kg IV q24h
            • NSAIDs for inflammation
            
            REFER IF:
            - Synovial structure involved
            - Major vessel damage
            - Extensive tissue loss
            """,
            
            .choke: """
            CHOKE PROTOCOL (Offline)
            
            SIGNS:
            • Food/water from nostrils
            • Repeated swallowing
            • Distress
            • Coughing
            
            IMMEDIATE:
            1. REMOVE all feed/water
            2. Keep calm and still
            3. Lower head for drainage
            4. DO NOT force tube initially
            
            TREATMENT:
            1. Sedate first:
               - Xylazine 0.5-1.0 mg/kg IV
               
            2. Wait 15-30 minutes
            
            3. Gentle NG tube:
               - Warm water flush
               - Gentle steady pressure
               - NEVER force
               
            4. Medications:
               - Buscopan 0.3 mg/kg IV
               - NSAIDs after resolution
               - Antibiotics if aspiration risk
            
            POST-RESOLUTION:
            • NPO 24 hours
            • Introduce water slowly
            • Start wet feed
            • Monitor for pneumonia
            
            REFER IF:
            - >2 hours duration
            - Respiratory compromise
            - Cannot pass tube
            """,
            
            .lameness: """
            LAMENESS EVALUATION (Offline)
            
            GRADING (0-5):
            0: Sound
            1: Difficult to observe
            2: Visible at trot
            3: Visible at walk
            4: Minimal weight bearing
            5: Non-weight bearing
            
            SYSTEMATIC EXAM:
            1. Visual observation
            2. Palpation (heat/swelling)
            3. Hoof testers
            4. Flexion tests
            5. Gait analysis
            
            FLEXION TESTS:
            • Lower limb: 60 seconds
            • Upper limb: 90 seconds
            • Positive: lameness worsens
            
            COMMON CAUSES:
            Front:
            - Navicular
            - Laminitis
            - Sole abscess
            
            Hind:
            - Hock arthritis
            - Stifle issues
            - Suspensory
            
            MEDICATIONS:
            • Bute: 2-4 mg/kg PO q12h
            • Firocoxib: 0.1 mg/kg PO q24h
            """,
            
            .eyeEmergency: """
            EYE EMERGENCY (Offline)
            
            EXAMINATION:
            1. Menace response
            2. Pupillary light reflex
            3. Fluorescein stain (ulcers)
            4. Tonometry (pressure)
            
            ULCER:
            • Green stain uptake
            • Treatment:
              - Atropine 1% q6-12h
              - Antibiotic (triple abx)
              - Serum if deep
            
            UVEITIS:
            • Miotic pupil
            • Cloudy anterior chamber
            • Treatment:
              - Atropine 1%
              - NSAIDs systemic
              - Banamine 1.1 mg/kg
            
            TRAUMA:
            • Assess globe integrity
            • NO pressure if ruptured
            • Immediate referral
            
            REFER IF:
            - Deep/melting ulcer
            - Penetrating injury
            - Vision threatened
            - Not improving 48hrs
            """,
            
            .drugCalculator: """
            DRUG DOSAGE CALCULATOR (Offline)
            
            NSAIDS:
            • Flunixin: 1.1 mg/kg IV/IM/PO q12-24h
            • Phenylbutazone: 2-4 mg/kg PO/IV q12h
            • Firocoxib: 0.1 mg/kg PO q24h
            
            ANTIBIOTICS:
            • Penicillin: 22,000 IU/kg IM q12h
            • Gentamicin: 6.6 mg/kg IV q24h
            • Trimeth-Sulfa: 30 mg/kg PO q12h
            
            SEDATION:
            • Xylazine: 0.5-1.1 mg/kg IV
            • Detomidine: 10-20 mcg/kg IV
            • Acepromazine: 0.02-0.05 mg/kg IV
            
            CONVERSIONS:
            • 1 lb = 0.453 kg
            • 1000 lbs ≈ 454 kg
            • Average horse: 450-550 kg
            
            EXAMPLE:
            500 kg horse needs flunixin:
            500 × 1.1 = 550 mg
            = 11 mL of 50mg/mL solution
            """
        ]
    }
    
    func loadDrugDatabase() -> DrugDatabase {
        return DrugDatabase(drugs: [
            Drug(name: "Flunixin (Banamine)", dose: "1.1 mg/kg", route: "IV/IM/PO", frequency: "q12-24h", notes: "GI ulcer risk with prolonged use"),
            Drug(name: "Phenylbutazone (Bute)", dose: "2-4 mg/kg", route: "PO/IV", frequency: "q12h", notes: "Max 5 days consecutive"),
            Drug(name: "Penicillin G", dose: "22,000 IU/kg", route: "IM", frequency: "q12h", notes: "Avoid IV - fatal reaction risk"),
            Drug(name: "Gentamicin", dose: "6.6 mg/kg", route: "IV", frequency: "q24h", notes: "Monitor renal function"),
            Drug(name: "Xylazine", dose: "0.5-1.1 mg/kg", route: "IV", frequency: "PRN", notes: "Alpha-2 agonist sedation"),
            Drug(name: "Detomidine", dose: "10-20 mcg/kg", route: "IV", frequency: "PRN", notes: "Longer acting than xylazine"),
        ])
    }
    
    func loadVitalRanges() -> VitalRanges {
        return VitalRanges(
            heartRate: "28-44 bpm",
            respiratoryRate: "8-16 bpm",
            temperature: "99-101°F (37.2-38.3°C)",
            capillaryRefillTime: "<2 seconds",
            mucousMembranes: "Pink and moist",
            gutSounds: "Present all 4 quadrants",
            notes: "Vary by age, fitness, environment"
        )
    }
    
    // MARK: - Cached Consultations
    
    func loadCachedConsultations() -> [Consultation] {
        let url = offlineDirectory.appendingPathComponent("consultations.json")
        guard let data = try? Data(contentsOf: url),
              let consultations = try? JSONDecoder().decode([Consultation].self, from: data) else {
            return []
        }
        return consultations
    }
    
    func cacheConsultations(_ consultations: [Consultation]) {
        let url = offlineDirectory.appendingPathComponent("consultations.json")
        if let data = try? JSONEncoder().encode(consultations) {
            try? data.write(to: url)
        }
    }
    
    // MARK: - Sync Queue
    
    private var syncQueueURL: URL {
        offlineDirectory.appendingPathComponent("syncQueue.json")
    }
    
    func getSyncQueue() -> [SyncItem] {
        guard let data = try? Data(contentsOf: syncQueueURL),
              let items = try? JSONDecoder().decode([SyncItem].self, from: data) else {
            return []
        }
        return items
    }
    
    func addToSyncQueue(_ item: SyncItem) {
        var queue = getSyncQueue()
        queue.append(item)
        if let data = try? JSONEncoder().encode(queue) {
            try? data.write(to: syncQueueURL)
        }
    }
    
    func removeFromSyncQueue(_ item: SyncItem) {
        var queue = getSyncQueue()
        queue.removeAll { $0.id == item.id }
        if let data = try? JSONEncoder().encode(queue) {
            try? data.write(to: syncQueueURL)
        }
    }
    
    func pendingSyncCount() -> Int {
        return getSyncQueue().count
    }
    
    // MARK: - Data Management
    
    func hasOfflineData() -> Bool {
        return fileManager.fileExists(atPath: offlineDirectory.path)
    }
    
    func clearCache() {
        try? fileManager.removeItem(at: offlineDirectory)
        createOfflineDirectory()
    }
    
    func cacheProtocols() async {
        // Protocols are hardcoded above, always available
    }
    
    func cacheDrugDatabase() async {
        // Drug database is hardcoded above, always available
    }
    
    func cacheVitalRanges() async {
        // Vital ranges are hardcoded above, always available
    }
}

// MARK: - Models

struct Drug: Codable {
    let name: String
    let dose: String
    let route: String
    let frequency: String
    let notes: String
}

struct DrugDatabase: Codable {
    let drugs: [Drug]
}

struct VitalRanges: Codable {
    let heartRate: String
    let respiratoryRate: String
    let temperature: String
    let capillaryRefillTime: String
    let mucousMembranes: String
    let gutSounds: String
    let notes: String
}

struct SyncItem: Identifiable, Codable {
    let id: UUID
    let type: SyncType
    let data: Data
    let timestamp: Date
    
    enum SyncType: String, Codable {
        case consultation
        case estimate
        case recording
    }
}
