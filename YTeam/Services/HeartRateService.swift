//
//  HeartRateLocationService.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 14/11/23.
//

import Foundation
import Firebase

final class HeartRateService {
    @Published var heartRateDocumentChanges = [DocumentChange]()
    static let shared = HeartRateService()

    func observeHeartRateSpecific(userData: UserData?) {
        guard let currentUid = UserDefaults.standard.string(forKey: "selectedSenior") else { return }

        let query = FirestoreConstants.heartbeatCollection
            .whereField("seniorId", isEqualTo: currentUid)
            .order(by: "time", descending: true)
            .limit(to: 1)

        query.addSnapshotListener { querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            self.heartRateDocumentChanges = changes
        }
    }
}
