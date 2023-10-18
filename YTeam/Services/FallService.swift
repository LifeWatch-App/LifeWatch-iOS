//
//  FallService.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 17/10/23.
//

import Foundation
import Firebase

class FallService {
    
    /// `Fetches all fall without filter from FireStore`.
    ///
    /// ```
    /// FallService.fetchAllFalls().
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: Array of `Falls`
    static func fetchAllFalls() async throws -> [Fall] {
        let snapshot = try await FirestoreConstants.fallsCollection.getDocuments()
        return snapshot.documents.compactMap({ try? $0.data(as: Fall.self) })
    }
    
}
