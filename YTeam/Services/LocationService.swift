//
//  LocationService.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 30/10/23.
//

import Foundation
import Firebase


final class LocationService {
    static let shared = LocationService()
    @Published var documentChangesHomeLocation = [DocumentChange]()
    @Published var documentChangesLiveLocation = [DocumentChange]()


    func observeHomeLocationSpecific() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        let query = FirestoreConstants.homeLocationCollection
            .whereField("seniorId", isEqualTo: currentUid)
            .limit(to: 1)

        query.addSnapshotListener { querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            self.documentChangesHomeLocation = changes
        }
    }

    func observeLiveLocationSpecific() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        print("CurrentUid", currentUid)

        let query = FirestoreConstants.liveLocationsCollection
            .whereField("seniorId", isEqualTo: currentUid)
            .order(by: "createdAt", descending: true)
            .limit(to: 1)

        query.addSnapshotListener { querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            self.documentChangesLiveLocation = changes
        }
    }
}
