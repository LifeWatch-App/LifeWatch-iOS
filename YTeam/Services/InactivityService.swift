//
//  InactivityService.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 23/10/23.
//

import Foundation
import Firebase

class InactivityService {
    static let shared: InactivityService = InactivityService()

    @Published var idles: [Idle] = []
    @Published var charges: [Charge] = []

    private var inactivityListener: [ListenerRegistration] = []

    func deinitializerFunction() {
        inactivityListener.forEach({ $0.remove() })
        inactivityListener = []
        idles = []
        charges = []
    }

//    init() {
//        Task{try? await observeAllIdles()}
//        Task{try? await observeAllCharges()}
//    }
    
    /// Observes all falls by adding a snapshot listener to the firebase and updates the `inactivities` properties only if user is `logged in`.
    ///
    /// ```
    /// FallService.observeAllFalls().
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: If user is logged in, add a snapshot listener to the database and filter it based on the UID.
    func observeAllIdles(userData: UserData?) {
        let uid: String?
        if userData?.role == "caregiver" {
            uid = UserDefaults.standard.string(forKey: "selectedSenior")
        } else {
            uid = Auth.auth().currentUser?.uid
        }

        guard let uid else { return }

        let query = FirestoreConstants.idlesCollection
                                    .whereField("seniorId", isEqualTo: uid)
        
        inactivityListener.append(query.addSnapshotListener { [weak self] snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added || $0.type == .modified }) else { return }
            let idles = changes.compactMap({ try? $0.document.data(as: Idle.self) })
            self?.idles = idles
        })
    }

    func observeAllCharges(userData: UserData?) {
        let uid: String?
        if userData?.role == "caregiver" {
            uid = UserDefaults.standard.string(forKey: "selectedSenior")
        } else {
            uid = Auth.auth().currentUser?.uid
        }

        guard let uid else { return }
        print("Gotten", uid)

        let query = FirestoreConstants.chargesCollection
                                    .whereField("seniorId", isEqualTo: uid)

        inactivityListener.append(query.addSnapshotListener { [weak self] snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added || $0.type == .modified }) else { return }
            let charges = changes.compactMap({ try? $0.document.data(as: Charge.self) })
            print("Charges ", charges)
            self?.charges = charges
        })
    }

    func observeAllInactivity(userData: UserData?) {
        observeAllIdles(userData: userData)
        observeAllCharges(userData: userData)
    }
}
