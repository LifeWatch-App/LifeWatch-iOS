//
//  DashboardLocationService.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 14/11/23.
//

import Foundation
import Firebase

final class DashboardLocationService {
    static let shared = DashboardLocationService()
    @Published var latestLocationDocumentChanges = [DocumentChange]()

    func observeLiveLocationSpecific() {
        //        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let currentUid = UserDefaults.standard.string(forKey: "selectedSenior") else { return }

        let query = FirestoreConstants.liveLocationsCollection
            .whereField("seniorId", isEqualTo: currentUid)
            .order(by: "createdAt", descending: true)
            .limit(to: 1)

        query.addSnapshotListener { querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            self.latestLocationDocumentChanges = changes
        }
    }
}
