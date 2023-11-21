//
//  SOSService.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 22/10/23.
//

import Foundation
import Firebase

class SOSService {
    static let shared: SOSService = SOSService()
    
    @Published var sos: [SOS] = []
    private var sosListener: [ListenerRegistration] = []

    func deinitializerFunction() {
        sosListener.forEach({ $0.remove() })
        sosListener = []
        sos = []
    }

//    init() {
//        Task{try? await observeAllSOS()}
//    }
    
    /// Sends SOS to Firebase.
    ///
    /// ```
    /// SOSService.sendSOS().
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: If user is logged in, add a snapshot listener to the database and filter it based on the UID.
    func sendSOS() async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let sosCollection = FirestoreConstants.sosCollection
        let SOS = SOS(seniorId: userId, time: Date.now.timeIntervalSince1970)
        
        guard let encodedSOSData = try? Firestore.Encoder().encode(SOS) else { return }
        
        try? await sosCollection.document().setData(encodedSOSData)
    }
    
    /// Observes all falls by adding a snapshot listener to the firebase and updates the `falls` properties only if user is `logged in`.
    ///
    /// ```
    /// FallService.observeAllFalls().
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: If user is logged in, add a snapshot listener to the database and filter it based on the UID.
    func observeAllSOS(userData: UserData?) {
        let uid: String?
        if userData?.role == "caregiver" {
            uid = UserDefaults.standard.string(forKey: "selectedSenior")
        } else {
            uid = Auth.auth().currentUser?.uid
        }

        guard let uid else { return }

        let query = FirestoreConstants.sosCollection
                                    .whereField("seniorId", isEqualTo: uid)
    
        sosListener.append(query.addSnapshotListener { [weak self] snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            let sos = changes.compactMap({ try? $0.document.data(as: SOS.self) })
            self?.sos = sos
        })
    }
}
