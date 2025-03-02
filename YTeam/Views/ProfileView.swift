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
                VStack {
                    ZStack {
                        Circle()
                            .fill(.secondary.opacity(0.5))
                            .frame(width: 75)
                        Text(profileViewModel.userData?.name?.prefix(1).uppercased() ?? "S")
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
                    //                    Section(header: Text("App Settings")) {
                    //                        HStack {
                    //                            VStack {
                    //                                Image(systemName: "flipphone")
                    //                                    .resizable()
                    //                                    .scaledToFit()
                    //                                    .frame(width: 20, height: 20)
                    //                            }
                    //                            .padding(8)
                    //                            .background(.accent)
                    //                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    //                            .foregroundStyle(.white)
                    //                            .padding(.trailing, 4)
                    //
                    //                            Text("Walkie-Talkie")
                    //                                .fontWeight(.semibold)
                    //
                    //                            Spacer()
                    //
                    //                            Toggle("", isOn: $walkieToggle)
                    //                        }
                    //                        .padding(.vertical, 1)
                    //
                    //                        HStack {
                    //                            VStack {
                    //                                Image(systemName: "location.fill")
                    //                                    .resizable()
                    //                                    .scaledToFit()
                    //                                    .frame(width: 20, height: 20)
                    //                            }
                    //                            .padding(8)
                    //                            .background(.accent)
                    //                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    //                            .foregroundStyle(.white)
                    //                            .padding(.trailing, 4)
                    //
                    //                            Text("Location")
                    //                                .fontWeight(.semibold)
                    //
                    //                            Spacer()
                    //
                    //                            Toggle("", isOn: $locationToggle)
                    //                        }
                    //                        .padding(.vertical, 1)
                    //
                    //                        HStack {
                    //                            VStack {
                    //                                Image(systemName: "moon.fill")
                    //                                    .resizable()
                    //                                    .scaledToFit()
                    //                                    .frame(width: 20, height: 20)
                    //                            }
                    //                            .padding(8)
                    //                            .background(.accent)
                    //                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    //                            .foregroundStyle(.white)
                    //                            .padding(.trailing, 4)
                    //
                    //                            Text("Inactivity")
                    //                                .fontWeight(.semibold)
                    //
                    //                            Spacer()
                    //
                    //                            Toggle("", isOn: $inactivityToggle)
                    //                        }
                    //                        .padding(.vertical, 1)
                    //                    }

                    Section(header: Text(profileViewModel.userData?.role == "caregiver" ? "Seniors" : "Care Team")) {
                        if !profileViewModel.invites.isEmpty {
                            ForEach(profileViewModel.invites, id: \.id) { invite in
                                HStack {
                                    if profileViewModel.userData?.role == "senior" {
                                        HStack {
                                            Text(invite.caregiverData!.name ?? "Subroto")
                                            if !invite.accepted! {
                                                Text("(Pending request)")
                                                    .foregroundStyle(.secondary)
                                                    .font(.caption)
                                            }
                                        }
                                    } else {
                                        HStack {
                                            Text(invite.seniorData!.name ?? "Subroto")
                                            if !invite.accepted! {
                                                Text("(Pending request)")
                                                    .foregroundStyle(.secondary)
                                                    .font(.caption)
                                            }
                                        }
                                    }
                                    Spacer()
                                    if invite.accepted! {
                                        Button {
                                            profileViewModel.denyInvite(invite: invite)
                                        } label: {
                                            Text("Remove")
                                                .foregroundStyle(Color("emergency-pink"))
                                        }
                                    } else {
                                        if profileViewModel.userData?.role == "senior" {
                                            HStack(spacing: 16) {
                                                Button {
                                                    profileViewModel.acceptInvite(id: invite.id!)
                                                } label: {
                                                    Text("Accept")
                                                }
                                                Button {
                                                    profileViewModel.denyInvite(invite: invite)
                                                } label: {
                                                    Text("Deny")
                                                        .foregroundStyle(Color("emergency-pink"))
                                                }
                                            }
                                        } else {
                                            Button {
                                                profileViewModel.denyInvite(invite: invite)
                                            } label: {
                                                Text("Remove")
                                                    .foregroundStyle(Color("emergency-pink"))
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            if profileViewModel.userData?.role == "senior" {
                                Text("You have not accepted any caregiver.")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("You have not added any senior.")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Spacer()

                Button(action: {
                    //                    batteryLevelViewModel.cancelBatteryMonitoringIphone()

                    if profileViewModel.userData?.role != "senior" {
                        profileViewModel.resetAnalysis()
                        print("Called reset here")
                    }

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
                .padding([.horizontal, .bottom])
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
                        .background(Color("emergency-pink"))
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

//#Preview {
//    ProfileView(, resetAnalysis: <#() -> Void#>)
//        .preferredColorScheme(.dark)
//}
