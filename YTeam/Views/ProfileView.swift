//
//  ProfileView.swift
//  YTeam
//
//  Created by Yap Justin on 26/10/23.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var profileViewModel = ProfileViewModel()
    @State private var showDeleteSheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    profileViewModel.signOut()
                }, label: {
                    Text("Sign Out")
                })
                Button(action: {
                    showDeleteSheet = true
                }, label: {
                    Text("Delete Account")
                })
            }
            .sheet(isPresented: $showDeleteSheet) {
                DeleteSheetView(profileViewModel: profileViewModel)
                    .onAppear {
                        print("login providers: ", profileViewModel.loginProviders)
                    }
            }
        }
    }
}

struct DeleteSheetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Reauthenticate your account")
                .font(.largeTitle)
                .bold()
            
            ForEach(profileViewModel.loginProviders, id: \.self) { loginProvider in
                if loginProvider == "password" {
                    VStack(alignment: .leading) {
                        Text("Password")
                        SecureField("Password", text: $profileViewModel.password)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray3), lineWidth: 1)
                            )
                    }
                    
                    Button {
                        profileViewModel.deleteAccountWithPassword()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete Account & Data")
                                .fontWeight(.semibold)
                                .padding()
                            Spacer()
                        }
                        .background(.red)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                    }
                    .padding(.top, 8)
                } else if loginProvider == "apple.com" {
                    SignInWithAppleButton()
                        .frame(height: 50)
                        .onTapGesture {
                            profileViewModel.deleteAccountWithApple()
                        }
                }
            }
        }
        .presentationDetents([.medium])
        .padding()
    }
}

#Preview {
    ProfileView()
}
