//
//  SignUpVIewModel.swift
//  YTeam
//
//  Created by Yap Justin on 13/10/23.
//

import Foundation

class SignUpViewModel: ObservableObject {
    func signUp(email: String, password: String) {
        AuthService.shared.signUp(email: email, password: password)
    }
}
