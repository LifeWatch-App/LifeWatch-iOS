//
//  InactivityService.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 23/10/23.
//

import Foundation
import Firebase

class InactivityService {
    static let shared: InactivityService = InactivityService()
    
    @Published var idles: [Idle] = []
    @Published var charges: [Charge] = []
    
    init() {
        Task{try? await observeAllIdles()}
        Task{try? await observeAllCharges()}
    }
    
    /// Observes all falls by adding a snapshot listener to the firebase and updates the `inactivities` properties only if user is `logged in`.
    ///
    /// ```
    /// FallService.observeAllFalls().
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: If user is logged in, add a snapshot listener to the database and filter it based on the UID.
    @MainActor
    func observeAllIdles() async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let query = FirestoreConstants.idlesCollection
                                    .whereField("seniorId", isEqualTo: userId)
        
        query.addSnapshotListener { [weak self] snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            let idles = changes.compactMap({ try? $0.document.data(as: Idle.self) })
            self?.idles = idles
        }
    }
    
    @MainActor
    func observeAllCharges() async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let query = FirestoreConstants.chargesCollection
                                    .whereField("seniorId", isEqualTo: userId)
        
        query.addSnapshotListener { [weak self] snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            let charges = changes.compactMap({ try? $0.document.data(as: Charge.self) })
            debugPrint("Charges ", charges)
            self?.charges = charges
        }
    }
}
