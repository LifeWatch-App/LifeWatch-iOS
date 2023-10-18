//
//  FallService.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 17/10/23.
//

import Foundation
import Firebase

class FallService {
    
    /// `Fetches all fall with the filter of the logged in id from FireStore`.
    ///
    /// ```
    /// FallService.fetchAllFalls(userId: "abcdefghijklnmnop23").
    /// ```
    ///
    /// - Parameters:
    ///     - userId: The logged in user's id (String)
    /// - Returns: Array of `Falls`
    static func fetchAllFalls(userId: String) async throws -> [Fall] {
        let snapshot = try await FirestoreConstants.fallsCollection
                                    .whereField("seniorId", isEqualTo: userId)
                                    .getDocuments()
        
        return snapshot.documents.compactMap({ try? $0.data(as: Fall.self) })
    }
    
}
