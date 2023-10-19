//
//  ChargeService.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 18/10/23.
//

import Foundation
import Firebase

class ChargeService {
    
    /// `Fetches all charges with the filter of the logged in id from FireStore`.
    ///
    /// ```
    /// ChargeService.fetchAllCharges(userId: "abcdefghijklnmnop23").
    /// ```
    ///
    /// - Parameters:
    ///     - userId: The logged in user's id (String)
    /// - Returns: Array of `Charges`
    static func fetchAllCharges(userId: String) async throws -> [Charge] {
        let snapshot = try await FirestoreConstants.chargesCollection
                                    .whereField("seniorId", isEqualTo: userId)
                                    .getDocuments()
        
        return snapshot.documents.compactMap({ try? $0.data(as: Charge.self) })
    }
    
}
