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
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        AuthService.shared.$user.sink { [weak self] user in
            self?.user = user
        }
        .store(in: &cancellables)
        
        AuthService.shared.$userData.sink { [weak self] userData in
            self?.userData = userData
        }
        .store(in: &cancellables)
        
        AuthService.shared.$invites.sink { [weak self] invites in
            self?.invites = invites
        }
        .store(in: &cancellables)
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
}
