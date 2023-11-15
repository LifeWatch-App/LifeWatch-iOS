//
//  IdleLocationService.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 14/11/23.
//

import Foundation
import Firebase
import Combine

final class IdleService {
    static let shared = IdleService()
    @Published var idleDocumentChanges = [DocumentChange]()
    @Published var userData: UserData?
    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()

    func observeIdleSpecific() {
        let uid: String?
        guard let userData else { return }
        if userData.role == "caregiver" {
            uid = UserDefaults.standard.string(forKey: "selectedSenior")
        } else {
            uid = Auth.auth().currentUser?.uid
        }

        guard let uid else { return }

        let query = FirestoreConstants.idlesCollection
            .whereField("seniorId", isEqualTo: uid)

        query.addSnapshotListener { querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            self.idleDocumentChanges = changes
        }
    }
}
