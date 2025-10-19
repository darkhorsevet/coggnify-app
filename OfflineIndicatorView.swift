//
//  OfflineIndicatorView.swift
//  Notalyze
//
//  Shows offline mode status
//

import SwiftUI

struct OfflineIndicatorView: View {
    @ObservedObject var offlineManager: OfflineManager
    
    var body: some View {
        if !offlineManager.isOnline {
            HStack(spacing: 8) {
                Image(systemName: "wifi.slash")
                    .font(.caption)
                Text("Offline Mode")
                    .font(.caption.bold())
                
                if offlineManager.pendingSyncCount > 0 {
                    Text("• \(offlineManager.pendingSyncCount) pending")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange)
            .cornerRadius(16)
            .shadow(radius: 4)
        }
    }
}

// MARK: - Offline Banner (Full Width)

struct OfflineBanner: View {
    @ObservedObject var offlineManager: OfflineManager
    
    var body: some View {
        if !offlineManager.isOnline {
            HStack(spacing: 12) {
                Image(systemName: "wifi.slash")
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Offline Mode Active")
                        .font(.system(size: 14, weight: .bold))
                    Text("Emergency protocols available • Changes will sync when online")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                if offlineManager.pendingSyncCount > 0 {
                    VStack(spacing: 2) {
                        Text("\(offlineManager.pendingSyncCount)")
                            .font(.title3.bold())
                        Text("pending")
                            .font(.caption2)
                    }
                }
            }
            .foregroundColor(.white)
            .padding()
            .background(
                LinearGradient(
                    colors: [.orange, .orange.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
}
