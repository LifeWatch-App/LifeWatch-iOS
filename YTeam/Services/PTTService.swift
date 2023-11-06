//
//  PTTService.swift
//  YTeam
//
//  Created by Yap Justin on 04/11/23.
//

import Foundation
import FirebaseAuth

class PTTService {
    static let shared: PTTService = PTTService()

    @MainActor
    func sendPTTNotification() async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        try? await FirestoreConstants.pttCollection.document().setData([
            "speakerId": Auth.auth().currentUser?.uid
        ])
    }
}
