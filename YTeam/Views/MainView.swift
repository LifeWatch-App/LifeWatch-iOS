//
//  MainView.swift
//  YTeam
//
//  Created by Yap Justin on 12/10/23.
//

import SwiftUI

struct MainView: View {
    @ObservedObject private var mainViewModel = MainViewModel()
    @State var email = ""
    
    var body: some View {
        if (mainViewModel.userData?.role != nil) {
            VStack {
                Text("Welcome!")
                Text("\(mainViewModel.user?.email ?? "")")
                if mainViewModel.userData?.role == "senior" {
                    Text("Give your email to your caregivers")
                    ForEach(mainViewModel.invites, id: \.self) { invite in
                        HStack {
                            Text(invite.seniorEmail!)
                            Text(invite.caregiverEmail!)
                            Text(String(invite.accepted!))
                            Button {
                                mainViewModel.acceptInvite(id: invite.id!)
                            } label: {
                                Text("Accept")
                            }
                        }
                    }
                } else {
                    Text("Enter your senior's email")
                    TextField("Email", text: $email)
                    Button {
                        mainViewModel.sendRequestToSenior(email: email)
                    } label: {
                        Text("Request access")
                    }
                    ForEach(mainViewModel.invites, id: \.self) { invite in
                        HStack {
                            Text(invite.seniorEmail!)
                            Text(invite.caregiverEmail!)
                            Text(String(invite.accepted!))
                        }
                    }
                    
                }
            }.toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(
                        action: {
                            mainViewModel.signOut()
                        },
                        label: {
                            Text("Sign Out")
                                .bold()
                        }
                    )
                }
            }
        } else {
            VStack {
                Text("\(mainViewModel.user?.email ?? "")")
                Text("Choose Role")
                Button {
                    mainViewModel.setRole(role: "senior")
                } label: {
                    Text("As a senior")
                }
                Button {
                    mainViewModel.setRole(role: "caregiver")
                } label: {
                    Text("As a caregiver")
                }
                
            }.toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(
                        action: {
                            mainViewModel.signOut()
                        },
                        label: {
                            Text("Sign Out")
                                .bold()
                        }
                    )
                }
            }
            .onAppear {
                mainViewModel.getUserData()
            }
        }
    }
}

#Preview {
    MainView()
}
