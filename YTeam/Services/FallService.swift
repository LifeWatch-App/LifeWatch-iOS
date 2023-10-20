//
//  FallService.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 17/10/23.
//

import Foundation
import Firebase

class FallService {
    @Published var falls: [Fall] = []
    
    init() {
        Task{try? await observeAllFalls()}
    }
    
    /// Observes all falls by adding a snapshot listener to the firebase and updates the `falls` properties only if user is `logged in`.
    ///
    /// ```
    /// FallService.observeAllFalls().
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: If user is logged in, add a snapshot listener to the database and filter it based on the UID.
    func observeAllFalls() async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let query = FirestoreConstants.fallsCollection
                                    .whereField("seniorId", isEqualTo: userId)
    
        query.addSnapshotListener { [weak self] snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            var falls = changes.compactMap({ try? $0.document.data(as: Fall.self) })
            self?.falls = falls
        }
    }
    
}
