//
//  HeartAnomalyService.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 05/11/23.
//

import Foundation
import Firebase

class HeartbeatService {
    static let shared: HeartbeatService = HeartbeatService()
    
    @Published var heartbeats: [Heartbeat] = []
    
    init() {
        Task{try? await observeAllHeartbeats()}
    }
    
    /// Observes all falls by adding a snapshot listener to the firebase and updates the `heartAnomalies` properties only if user is `logged in`.
    ///
    /// ```
    /// HeartAnomalyService.observeAllAnomalies().
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: If user is logged in, add a snapshot listener to the database and filter it based on the UID.
    @MainActor
    func observeAllHeartbeats() async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let query = FirestoreConstants.heartbeatCollection
                                    .whereField("seniorId", isEqualTo: userId)
        
        query.addSnapshotListener { [weak self] snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            let heartbeats = changes.compactMap({ try? $0.document.data(as: Heartbeat.self) })
            self?.heartbeats = heartbeats
        }
    }
}
