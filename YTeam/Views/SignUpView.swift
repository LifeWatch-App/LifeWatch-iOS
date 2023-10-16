//
//  SignUpView.swift
//  YTeam
//
//  Created by Yap Justin on 10/10/23.
//

import SwiftUI
//import CloudKit
import AuthenticationServices
import FirebaseAuth

struct SignUpView: View {
    @ObservedObject private var signUpViewModel = SignUpViewModel()
    @Binding var isSigningUp: Bool
    
    @State private var accepted: Bool = false
    
    var body: some View {
        VStack {
            Image("asset")
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 32)
                .padding(.bottom, 8)
            
            VStack(alignment: .leading) {
                Text("Username")
                TextField("Username", text: $signUpViewModel.username)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray3), lineWidth: 1)
                    )
            }
            .padding(.vertical, 12)
            
            VStack(alignment: .leading) {
                Text("Email address")
                TextField("Email", text: $signUpViewModel.email)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray3), lineWidth: 1)
                    )
            }
            .padding(.bottom, 12)
            
            VStack(alignment: .leading) {
                Text("Password")
                SecureField("Password", text: $signUpViewModel.password)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray3), lineWidth: 1)
                    )
            }
            .padding(.bottom, 8)
            
            HStack {
                Button {
                    accepted.toggle()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                }
                .foregroundStyle(accepted ? .black : .secondary)
                
                Text("I accept the terms and privacy policy")
                Spacer()
            }
            .padding(.bottom, 8)
            
            Button {
                signUpViewModel.signUp()
            } label: {
                HStack {
                    Spacer()
                    Text("Sign Up")
                        .fontWeight(.semibold)
                        .padding()
                    Spacer()
                }
                .background(.blue)
                .foregroundStyle(.white)
                .cornerRadius(8)
            }
            .padding(.top, 8)
            
            HStack {
                Text("Already have an account?")
                Button {
                    isSigningUp.toggle()
                } label: {
                    Text("Login")
                }
            }
            .padding(.top)
        }
        .padding()
        .navigationTitle("Sign Up")
    }
}

#Preview {
    SignUpView(isSigningUp: .constant(true))
}
