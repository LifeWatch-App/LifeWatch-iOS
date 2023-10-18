//
//  LoginView.swift
//  YTeam
//
//  Created by Yap Justin on 10/10/23.
//

import SwiftUI
//import CloudKit
import AuthenticationServices
import FirebaseAuth

struct LoginView: View {
    @ObservedObject var loginViewModel: LoginViewModel = LoginViewModel()
    @State var isSigningUp = false
    
    var body: some View {
        NavigationStack {
            if !isSigningUp {
                LoginPage(loginViewModel: loginViewModel, isSigningUp: $isSigningUp)
            } else {
                SignUpView(isSigningUp: $isSigningUp)
            }
        }
    }
}

struct LoginPage: View {
    @ObservedObject var loginViewModel: LoginViewModel
    @Binding var isSigningUp: Bool
    
    var body: some View {
        VStack {
            Image("asset")
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 32)
                .padding(.bottom, 8)
            
            VStack(alignment: .leading) {
                Text("Email address")
                TextField("Email", text: $loginViewModel.email)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray3), lineWidth: 1)
                    )
            }
            .padding(.vertical, 12)
            
            VStack(alignment: .leading) {
                Text("Password")
                SecureField("Password", text: $loginViewModel.password)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray3), lineWidth: 1)
                    )
                HStack {
                    Spacer()
                    Button("Forgot Password?") {
                        
                    }
                    .foregroundStyle(.black)
                }
            }
            
            Button {
                loginViewModel.login()
            } label: {
                HStack {
                    Spacer()
                    Text("Login")
                        .fontWeight(.semibold)
                        .padding()
                    Spacer()
                }
                .background(.accent)
                .foregroundStyle(.white)
                .cornerRadius(8)
            }
            .padding(.top, 8)
            
            Text("or")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button {
                
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "apple.logo")
                        .font(.title3)
                    Text("Continue with Apple")
                        .fontWeight(.semibold)
                        .padding(.vertical)
                    Spacer()
                }
                .foregroundStyle(.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.black, lineWidth: 2)
                )
            }
            
            HStack {
                Text("Don't have an account?")
                Button {
                    isSigningUp.toggle()
                } label: {
                    Text("Sign up")
                }
            }
            .padding(.top)
        }
        .padding()
        .navigationTitle("Login")
    }
}

#Preview {
    LoginView()
}
