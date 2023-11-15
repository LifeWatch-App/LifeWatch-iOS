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
    @Published var documentChangesAllLiveLocation = [DocumentChange]()


    func observeHomeLocationSpecific() {
        guard let currentUid = UserDefaults.standard.string(forKey: "selectedSenior") else { return }

        let query = FirestoreConstants.homeLocationCollection
            .whereField("seniorId", isEqualTo: currentUid)
            .limit(to: 1)

        query.addSnapshotListener { querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            self.documentChangesHomeLocation = changes
        }
    }

    func observeLiveLocationSpecific() {
        guard let currentUid = UserDefaults.standard.string(forKey: "selectedSenior") else { return }

        let query = FirestoreConstants.liveLocationsCollection
            .whereField("seniorId", isEqualTo: currentUid)
            .order(by: "createdAt", descending: true)
            .limit(to: 1)

        query.addSnapshotListener { querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            self.documentChangesLiveLocation = changes
        }
    }

    func observeAllLiveLocation() {
        guard let currentUid = UserDefaults.standard.string(forKey: "selectedSenior") else { return }

        let query = FirestoreConstants.liveLocationsCollection
            .whereField("seniorId", isEqualTo: currentUid)
            .order(by: "createdAt", descending: true)

        query.addSnapshotListener { querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            print("Document changes: \(changes)")
            self.documentChangesAllLiveLocation = changes
        }
    }


}
