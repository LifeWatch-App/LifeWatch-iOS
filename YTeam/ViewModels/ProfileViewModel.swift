//
//  ProfileViewModel.swift
//  YTeam
//
//  Created by Yap Justin on 26/10/23.
//

import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var password = ""
    @Published var loginProviders: [String] = []
    private let service = AuthService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSubscribers()
    }

    private func setupSubscribers() {
        service.$loginProviders
            .sink { [weak self] loginProviders in
                self?.loginProviders = loginProviders
            }
            .store(in: &cancellables)
    }
    
    func signOut() {
        AuthService.shared.signOut()
    }
    
    func deleteUserData() {
        AuthService.shared.deleteUserData()
    }
    
    func deleteAccountWithPassword() {
        AuthService.shared.deleteAccountWithPassword(password: password)
    }
    
    func deleteAccountWithApple() {
        AuthService.shared.deleteAccountWithApple()
    }
}
