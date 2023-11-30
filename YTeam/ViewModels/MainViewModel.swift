//
//  AuthRepository.swift
//  YTeam
//
//  Created by Yap Justin on 12/10/23.
//

import Foundation
import Combine
import FirebaseAuth

class MainViewModel: ObservableObject {
    @Published var user: User?
    @Published var userData: UserData?
    @Published var invites: [Invite] = []
    @Published var isLoading: Bool = false
    private let service = AuthService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSubscribers()
    }

    private func setupSubscribers() {
        service.$user
            .combineLatest(service.$userData, service.$isLoading, service.$invites)
            .sink { [weak self] user, userData, isLoading, invites in
                self?.user = user
                self?.userData = userData
                self?.invites = invites
                self?.handleAuthWatch(userID: user?.uid, userData: userData)
                self?.isLoading = isLoading
                print("setupSubscriberss")
            }
            .store(in: &cancellables)
    }

    func handleAuthWatch(userID: String?, userData: UserData?) {
        let encoder = JSONEncoder()
        let userRecord = UserRecord(userID: userID)
        print("User Record", userRecord)
        if let encodedData = try? encoder.encode(userRecord) {
            if (userID == nil && userData == nil) || (userID != nil && userData?.role == "senior") {
                WatchConnectorService.shared.session.sendMessage(["user_auth": encodedData], replyHandler: nil)
                print("Message sent")
            }
        }
    }

    func signOut() {
        AuthService.shared.signOut()
    }

    func getUserData() {
        AuthService.shared.getUserData()
    }

    func setRole(role: String) {
        AuthService.shared.setRole(role: role)
    }

    func addInvitesListener() {
        print("Invites Listener called")
        AuthService.shared.addInvitesListener()
    }
}
