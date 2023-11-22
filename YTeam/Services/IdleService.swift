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
    private var idleListener: [ListenerRegistration] = []


    func deinitializerFunction() {
        idleListener.forEach({ $0.remove() })
        idleListener = []
        idleDocumentChanges = []
    }


    func observeIdleSpecific() {
        guard let uid = UserDefaults.standard.string(forKey: "selectedSenior") else { return }

        let query = FirestoreConstants.idlesCollection
            .whereField("seniorId", isEqualTo: uid)

        print(query)

        query.addSnapshotListener { [weak self] querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            print("Data bro", changes.first?.document.data())
            self?.idleDocumentChanges = changes
        }
    }
}
