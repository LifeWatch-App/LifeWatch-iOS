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
        let currentDate = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: currentDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let query = FirestoreConstants.liveLocationsCollection
            .whereField("seniorId", isEqualTo: uid)
            .whereField("createdAt", isGreaterThanOrEqualTo: startOfDay.timeIntervalSince1970)
            .whereField("createdAt", isLessThanOrEqualTo: endOfDay.timeIntervalSince1970)
            .order(by: "createdAt", descending: true)
            .order(by: FieldPath.documentID(), descending: true)
            .limit(to: 1)

        locationListener.append(query.addSnapshotListener { [weak self] querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            self?.latestLocationDocumentChanges = changes
        })
    }
}
