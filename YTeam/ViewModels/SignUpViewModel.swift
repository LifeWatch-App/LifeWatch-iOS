//
//  SignUpVIewModel.swift
//  YTeam
//
//  Created by Yap Justin on 13/10/23.
//

import Foundation

class SignUpViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    
    func signUp() {
        AuthService.shared.signUp(name: name, email: email, password: password)
    }
}
