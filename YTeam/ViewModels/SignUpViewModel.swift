//
//  SignUpVIewModel.swift
//  YTeam
//
//  Created by Yap Justin on 13/10/23.
//

import Foundation
import Combine

class SignUpViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var signUpMessage = ""
    private let service = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
    }

    private func setupSubscribers() {
        service.$signUpMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] signUpMessage in
                self?.signUpMessage = signUpMessage
            }
            .store(in: &cancellables)
    }
    
    func signUp() {
        AuthService.shared.signUp(name: name, email: email, password: password)
    }
}
