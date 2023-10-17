//
//  LoginViewModel.swift
//  YTeam
//
//  Created by Yap Justin on 13/10/23.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func login() {
        AuthService.shared.login(email: email, password: password)
    }
}
