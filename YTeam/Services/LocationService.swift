//
//  LocationService.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 30/10/23.
//

import Foundation
import Firebase
import CoreLocation


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

    func fetchHomeLocation() async throws -> HomeLocation? {
        guard let uid = UserDefaults.standard.string(forKey: "selectedSenior") else { return nil }
        let snapshot = try await FirestoreConstants.homeLocationCollection.whereField("seniorId", isEqualTo: uid).getDocuments().documents.first
        let homeLocation = try? snapshot?.data(as: HomeLocation.self)
        return homeLocation
    }

    func setHomeLocation(location: CLLocationCoordinate2D) async throws {
        guard let uid = UserDefaults.standard.string(forKey: "selectedSenior") else { return }

        if try await fetchHomeLocation() != nil {

            let homeLocation = HomeLocation(latitude: location.latitude, longitude: location.longitude, radius: 200, seniorId: uid, lastUpdatedAt: Date.now.timeIntervalSince1970)
            guard let encodedData = try? Firestore.Encoder().encode(homeLocation) else { return }
            let documents = try await FirestoreConstants.homeLocationCollection.whereField("seniorId", isEqualTo: uid).getDocuments().documents.first
            try await documents?.reference.updateData(encodedData)

        } else {
            let homeLocation = HomeLocation(latitude: location.latitude, longitude: location.longitude, radius: 200, seniorId: uid, lastUpdatedAt: Date.now.timeIntervalSince1970)
            guard let encodedData = try? Firestore.Encoder().encode(homeLocation) else { return }
            try await FirestoreConstants.homeLocationCollection.document().setData(encodedData)
        }
    }
}
