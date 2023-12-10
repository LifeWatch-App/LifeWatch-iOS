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
    
    var body: some View {
        LoginPage(loginViewModel: loginViewModel)
    }
}

struct LoginPage: View {
    @ObservedObject var loginViewModel: LoginViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Image("Login")
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
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
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
                    
                    
                    Text(loginViewModel.loginMessage)
                        .foregroundStyle(Color("emergency-pink"))
                    
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
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.top, 8)
                    
                    Text("or")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    SignInWithAppleButton()
                    .frame(height: 50)
                    .onTapGesture {
                        loginViewModel.startSignInWithAppleFlow()
                    }
                    
                    HStack {
                        Text("Don't have an account?")
                        NavigationLink {
                            SignUpView()
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
    }
}

#Preview {
    LoginView()
        .preferredColorScheme(.dark)
}
