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
    
    @State private var walkieToggle = true
    @State private var locationToggle = true
    @State private var inactivityToggle = true
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    ZStack {
                        Circle()
                            .fill(.secondary.opacity(0.5))
                            .frame(width: 75)
                        Text("S")
                            .font(.largeTitle)
                            .bold()
                    }
                    Text(profileViewModel.userData?.name ?? "Unknown")
                        .font(.title2)
                        .bold()
                    Text(profileViewModel.userData?.role == "senior" ? "Senior" : "Caregiver")
                    Text(profileViewModel.user?.email ?? "Unknown Email")
                }
                .padding(.horizontal)
                
                List {
                    Section(header: Text("App Settings")) {
                        HStack {
                            VStack {
                                Image(systemName: "flipphone")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                            }
                            .padding(8)
                            .background(.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .foregroundStyle(.white)
                            .padding(.trailing, 4)
                            
                            Text("Walkie Talkie")
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Toggle("", isOn: $walkieToggle)
                        }
                        .padding(.vertical, 1)
                        
                        HStack {
                            VStack {
                                Image(systemName: "location.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                            }
                            .padding(8)
                            .background(.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .foregroundStyle(.white)
                            .padding(.trailing, 4)
                            
                            Text("Location")
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Toggle("", isOn: $locationToggle)
                        }
                        .padding(.vertical, 1)
                        
                        HStack {
                            VStack {
                                Image(systemName: "location.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                            }
                            .padding(8)
                            .background(.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .foregroundStyle(.white)
                            .padding(.trailing, 4)
                            
                            Text("Inactivity")
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Toggle("", isOn: $inactivityToggle)
                        }
                        .padding(.vertical, 1)
                    }
                    
                    Section(header: Text("Care Team")) {
                        ForEach(profileViewModel.invites, id: \.id) { invite in
                            HStack {
                                Text(invite.caregiverData!.name ?? "Subroto")
                                Spacer()
                                if invite.accepted! {
                                    Button {
                                        profileViewModel.denyInvite(id: invite.id!)
                                    } label: {
                                        Text("Remove")
                                            .foregroundStyle(.red)
                                    }
                                } else {
                                    Button {
                                        profileViewModel.acceptInvite(id: invite.id!)
                                    } label: {
                                        Text("Accept")
                                    }
                                }
                            }
                        }
                       
                    }
                }
                
                Spacer()
                
                Button(action: {
                    profileViewModel.signOut()
                }, label: {
                    HStack {
                        Spacer()
                        Text("Sign Out")
                        Spacer()
                    }
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                })
                
                Button(action: {
                    showDeleteSheet = true
                }, label: {
                    Text("Delete Account")
                        .foregroundStyle(Color("emergency-pink"))
                })
                .padding(.horizontal)
            }
            .sheet(isPresented: $showDeleteSheet) {
                DeleteSheetView(profileViewModel: profileViewModel)
                    .onAppear {
                        print("login providers: ", profileViewModel.loginProviders)
                    }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile")
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
                        .clipShape(RoundedRectangle(cornerRadius: 8))
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
        .preferredColorScheme(.dark)
}
