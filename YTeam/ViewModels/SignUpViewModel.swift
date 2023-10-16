//
//  SignUpVIewModel.swift
//  YTeam
//
//  Created by Yap Justin on 13/10/23.
//

import Foundation

class SignUpViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    
    func signUp() {
        AuthService.shared.signUp(email: email, password: password)
    }
}
