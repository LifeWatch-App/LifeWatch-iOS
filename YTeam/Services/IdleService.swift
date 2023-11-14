//
//  IdleLocationService.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 14/11/23.
//

import Foundation
import Firebase

final class IdleService {
    static let shared = IdleService()
    @Published var idleDocumentChanges = [DocumentChange]()

    func observeIdleSpecific() {
        //        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let currentUid = UserDefaults.standard.string(forKey: "selectedSenior") else { return }

        let query = FirestoreConstants.idlesCollection
            .whereField("seniorId", isEqualTo: currentUid)

        query.addSnapshotListener { querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            self.idleDocumentChanges = changes
        }
    }
}
