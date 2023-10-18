//
//  MainView.swift
//  YTeam
//
//  Created by Yap Justin on 12/10/23.
//

import SwiftUI

struct MainView: View {
    @StateObject var mainViewModel = MainViewModel()
    
    var body: some View {
        if (mainViewModel.userData?.role != nil) {
            if mainViewModel.userData?.role == "senior" {
                SeniorView(mainViewModel: mainViewModel)
            } else {
                CaregiverView(mainViewModel: mainViewModel)
            }
//            VStack {
//                Text("Welcome!")
//                Text("\(mainViewModel.user?.email ?? "")")
//                if mainViewModel.userData?.role == "senior" {
//                    Text("Give your email to your caregivers")
//                    ForEach(mainViewModel.invites, id: \.id) { invite in
//                        HStack {
//                            Text(invite.seniorData!.email!)
//                            Text(invite.caregiverData!.email!)
//                            Text(String(invite.accepted!))
//                            Button {
//                                mainViewModel.acceptInvite(id: invite.id!)
//                            } label: {
//                                Text("Accept")
//                            }
//                        }
//                    }
//                } else {
//                    Text("Enter your senior's email")
//                    TextField("Email", text: $email)
//                    Button {
//                        mainViewModel.sendRequestToSenior(email: email)
//                    } label: {
//                        Text("Request access")
//                    }
//                    ForEach(mainViewModel.invites, id: \.id) { invite in
//                        HStack {
//                            Text(invite.seniorData?.email ?? "")
//                            Text(invite.caregiverData?.email ?? "")
//                            Text(String(invite.accepted!))
//                        }
//                    }
//                    
//                }
//            }.toolbar {
//                ToolbarItemGroup(placement: .navigationBarLeading) {
//                    Button(
//                        action: {
//                            mainViewModel.signOut()
//                        },
//                        label: {
//                            Text("Sign Out")
//                                .bold()
//                        }
//                    )
//                }
//            }
        } else {
            ChooseRoleView(mainViewModel: mainViewModel)
        }
    }
}

#Preview {
    MainView()
}
