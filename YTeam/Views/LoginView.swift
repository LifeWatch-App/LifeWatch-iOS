//
//  LoginView.swift
//  YTeam
//
//  Created by Yap Justin on 10/10/23.
//

import SwiftUI
import CloudKit
import AuthenticationServices
import FirebaseAuth

struct LoginView: View {
    @ObservedObject private var loginViewModel = LoginViewModel()
    @State var isSigningUp = false
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        if !isSigningUp {
            VStack {
                TextField("Email", text: $email)
                SecureField("Password", text: $password)
                Button {
                    loginViewModel.login(email: email, password: password)
                } label: {
                    Text("Sign in")
                }
                Button {
                    isSigningUp.toggle()
                } label: {
                    Text("Sign up here")
                }
            }
            .padding()
        } else {
            SignUpView()
        }
    }
}

#Preview {
    LoginView()
}
