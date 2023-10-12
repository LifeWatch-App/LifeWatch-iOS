//
//  MainView.swift
//  YTeam
//
//  Created by Yap Justin on 12/10/23.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State var email = ""
    
    var body: some View {
        if (authViewModel.userData?.role != nil) {
            VStack {
                Text("Welcome!")
                Text("\(authViewModel.user?.email ?? "")")
                if authViewModel.userData?.role == "senior" {
                    Text("Give your email to your caregivers")
                    ForEach(authViewModel.invites, id: \.self) { invite in
                        HStack {
                            Text(invite.seniorEmail!)
                            Text(invite.caregiverEmail!)
                        }
                    }
                } else {
                    Text("Enter your senior's email")
                    TextField("Email", text: $email)
                    Button {
                        authViewModel.sendRequestToSenior(email: email)
                    } label: {
                        Text("Request access")
                    }
                    ForEach(authViewModel.invites, id: \.self) { invite in
                        HStack {
                            Text(invite.seniorEmail!)
                            Text(invite.caregiverEmail!)
                        }
                    }
                    
                }
            }.toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(
                        action: {
                            authViewModel.signOut()
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
                Text("\(authViewModel.user?.email ?? "")")
                Text("Choose Role")
                Button {
                    authViewModel.setRole(role: "senior")
                } label: {
                    Text("As a senior")
                }
                Button {
                    authViewModel.setRole(role: "caregiver")
                } label: {
                    Text("As a caregiver")
                }
                
            }.toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(
                        action: {
                            authViewModel.signOut()
                        },
                        label: {
                            Text("Sign Out")
                                .bold()
                        }
                    )
                }
            }
            .onAppear {
                authViewModel.getUserData()
                let vm = ExampleViewModel()
                vm.addFallHistory()
            }
        }
    }
}

#Preview {
    MainView()
}
