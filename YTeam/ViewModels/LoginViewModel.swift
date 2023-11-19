//
//  LoginViewModel.swift
//  YTeam
//
//  Created by Yap Justin on 13/10/23.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var loginMessage = ""
    private let service = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
    }

    private func setupSubscribers() {
        service.$loginMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loginMessage in
                self?.loginMessage = loginMessage
            }
            .store(in: &cancellables)
    }
    
    func login() {
        service.login(email: email, password: password)
    }
    
    func startSignInWithAppleFlow() {
        service.startSignInWithAppleFlow()
    }
}
