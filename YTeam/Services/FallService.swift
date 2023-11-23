//
//  FallService.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 17/10/23.
//

import Foundation
import Firebase

class FallService {
    static let shared: FallService = FallService()
    
    @Published var falls: [Fall] = []
    @Published var fallsToday: [Fall] = []
    private var fallsListener: [ListenerRegistration] = []

    func deinitializerFunction() {
        fallsListener.forEach({ $0.remove() })
        fallsListener = []
        falls = []
        fallsToday = []
    }

//    init() {
//        Task{try? await observeAllFalls()}
//    }
    
    /// Observes all falls by adding a snapshot listener to the firebase and updates the `falls` properties only if user is `logged in`.
    ///
    /// ```
    /// FallService.observeAllFalls().
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: If user is logged in, add a snapshot listener to the database and filter it based on the UID.
    func observeAllFalls(userData: UserData?) {
        let uid: String?
        if userData?.role == "caregiver" {
            uid = UserDefaults.standard.string(forKey: "selectedSenior")
        } else {
            uid = Auth.auth().currentUser?.uid
        }

        guard let uid else { return }

        let query = FirestoreConstants.fallsCollection
                                    .whereField("seniorId", isEqualTo: uid)
    
        fallsListener.append(query.addSnapshotListener { [weak self] snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            let falls = changes.compactMap({ try? $0.document.data(as: Fall.self) })
            self?.falls = falls
        })
    }
    
    func observeTodayFalls(userData: UserData?) {
        let uid: String?
        let currentDate = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: currentDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        if userData?.role == "caregiver" {
            uid = UserDefaults.standard.string(forKey: "selectedSenior")
        } else {
            uid = Auth.auth().currentUser?.uid
        }

        guard let uid else { return }

        let query = FirestoreConstants.fallsCollection
                                    .whereField("seniorId", isEqualTo: uid)
                                    .whereField("time", isGreaterThanOrEqualTo: startOfDay.timeIntervalSince1970)
                                    .whereField("time", isLessThanOrEqualTo: endOfDay.timeIntervalSince1970)
                                    .order(by: "time", descending: true)
    
        fallsListener.append(query.addSnapshotListener { [weak self] snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            let falls = changes.compactMap({ try? $0.document.data(as: Fall.self) })
            self?.fallsToday = falls
            print("Today falls", self?.fallsToday)
        })
    }
}
