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
    @Published var invites: [Invite] = []
    @Published var user: User?
    @Published var userData: UserData?
    private let service = AuthService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSubscribers()
    }

    private func setupSubscribers() {
        service.$user
            .combineLatest(service.$userData, service.$invites)
            .sink { [weak self] user, userData, invites in
                self?.user = user
                self?.userData = userData
                self?.invites = invites
                self?.handleAuthWatch(user: user, userData: userData, invites: invites)
            }
            .store(in: &cancellables)

//        AuthService.shared.$userData
//            .sink { [weak self] userData in
//                self?.userData = userData
//            }
//            .store(in: &cancellables)
//
//        AuthService.shared.$invites.sink { [weak self] invites in
//            self?.invites = invites
//        }
//        .store(in: &cancellables)
    }

    func handleAuthWatch(user: User?, userData: UserData?, invites: [Invite]) {
        let encoder = JSONEncoder()
        let userRecord = UserRecord(userID: user?.uid, userData: userData, invites: invites)
        if let encodedData = try? encoder.encode(userRecord) {
            WatchConnectorService.shared.session.sendMessage(["user_auth": encodedData], replyHandler: nil)
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

    func sendRequestToSenior(email: String) {
        AuthService.shared.sendRequestToSenior(email: email)
    }

    func acceptInvite(id: String) {
        AuthService.shared.acceptInvite(id: id)
    }

    func setupAuthWatch() {

    }
}
