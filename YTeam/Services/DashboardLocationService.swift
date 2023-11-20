//
//  DashboardLocationService.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 14/11/23.
//

import Foundation
import Firebase
import Combine

final class DashboardLocationService {
    static let shared = DashboardLocationService()
    @Published var latestLocationDocumentChanges = [DocumentChange]()
    @Published var userData: UserData?
    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    private var locationListener: [ListenerRegistration] = []


    func deinitializerFunction() {
        locationListener.forEach({ $0.remove() })
        locationListener = []
        latestLocationDocumentChanges = []
    }

    func observeLiveLocationSpecific() {
        guard let uid =  UserDefaults.standard.string(forKey: "selectedSenior") else { return }

        let query = FirestoreConstants.liveLocationsCollection
            .whereField("seniorId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .limit(to: 1)

        locationListener.append(query.addSnapshotListener { querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            self.latestLocationDocumentChanges = changes
        })
    }
}
