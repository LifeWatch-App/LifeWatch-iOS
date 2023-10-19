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
    /// `Fetches all fall with the filter of the logged in id from FireStore`.
    ///
    /// ```
    /// FallService.fetchAllFalls(userId: "abcdefghijklnmnop23").
    /// ```
    ///
    /// - Parameters:
    ///     - userId: The logged in user's id (String)
    /// - Returns: Array of `Falls`
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
