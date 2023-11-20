//
//  HeartAnomalyService.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 05/11/23.
//

import Foundation
import Firebase

class HeartAnomalyService {
    static let shared: HeartAnomalyService = HeartAnomalyService()
    
    @Published var heartAnomalies: [HeartAnomaly] = []

    private var heartAnomalyListener: [ListenerRegistration] = []

    func deinitializerFunction() {
        heartAnomalyListener.forEach({ $0.remove() })
        heartAnomalyListener = []
        heartAnomalies = []
    }

//    init() {
//        Task{try? await observeAllAnomalies()}
//    }
    
    /// Observes all falls by adding a snapshot listener to the firebase and updates the `heartAnomalies` properties only if user is `logged in`.
    ///
    /// ```
    /// HeartAnomalyService.observeAllAnomalies().
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: If user is logged in, add a snapshot listener to the database and filter it based on the UID.
    func observeAllAnomalies(userData: UserData?) {
        let uid: String?
        if userData?.role == "caregiver" {
            uid = UserDefaults.standard.string(forKey: "selectedSenior")
        } else {
            uid = Auth.auth().currentUser?.uid
        }

        guard let uid else { return }

        let query = FirestoreConstants.heartAnomalyCollection
                                    .whereField("seniorId", isEqualTo: uid)
        
        heartAnomalyListener.append(query.addSnapshotListener { [weak self] snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            let heartAnomalies = changes.compactMap({ try? $0.document.data(as: HeartAnomaly.self) })
            self?.heartAnomalies = heartAnomalies
        })
    }
}
