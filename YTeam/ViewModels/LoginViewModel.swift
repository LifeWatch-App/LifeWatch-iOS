//
//  LoginViewModel.swift
//  YTeam
//
//  Created by Yap Justin on 13/10/23.
//

import Foundation

class LoginViewModel: ObservableObject {
    func login(email: String, password: String) {
        AuthService.shared.login(email: email, password: password)
    }
}
