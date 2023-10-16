//
//  SignUpView.swift
//  YTeam
//
//  Created by Yap Justin on 10/10/23.
//

import SwiftUI
import CloudKit
import AuthenticationServices
import FirebaseAuth

struct SignUpView: View {
    @ObservedObject private var signUpViewModel = SignUpViewModel()
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            Button(action: { signUp() }) {
                Text("Sign up")
            }
        }
        .padding()
    }
    
    func signUp() {
        signUpViewModel.signUp(email: email, password: password)
    }
}

#Preview {
    SignUpView()
}
