//
//  OnBoardingInviteView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 14/11/23.
//

import SwiftUI

struct OnBoardingInviteView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("inviteModel") var inviteModal = true
    
    @ObservedObject var mainViewModel: MainViewModel
    @ObservedObject var caregiverDashboardViewModel: CaregiverDashboardViewModel
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button("Skip") {
                    inviteModal = false
                    dismiss()
                }
            }
            
            Spacer()
            
            Image(mainViewModel.userData!.role! == "senior" ? "Invite-Caregiver" : "Invite-Senior")
                .resizable()
                .scaledToFit()
            
            Spacer()
            
            VStack(alignment: .leading) {
                if mainViewModel.userData!.role! == "senior" {
                    Text("Allow your caregiver to invite you by providing them with your email address.")
                        .multilineTextAlignment(.leading)
                    
                    Text("senior@gmail.com")
                        .font(.system(size: 28))
                        .bold()
                        .padding(.bottom, 8)
                } else {
                    Text("Request access to your senior")
                        .font(.system(size: 32))
                        .bold()
                        .padding(.bottom, 8)
                    Text("Enter your senior's email address")
                    TextField("Email", text: $caregiverDashboardViewModel.inviteEmail)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray3), lineWidth: 1)
                        )
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .padding(.vertical, 24)
            
            Button {
                if mainViewModel.userData!.role! != "senior" {
                    caregiverDashboardViewModel.sendRequestToSenior()
                    caregiverDashboardViewModel.inviteEmail = ""
                }
                inviteModal = false
                dismiss()
            } label: {
                HStack {
                    Spacer()
                    Text(mainViewModel.userData!.role! == "senior" ? "Done" : "Send Request")
                        .fontWeight(.semibold)
                        .padding()
                    Spacer()
                }
                .background(.accent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.top, 8)
        }
        .padding(.horizontal)
    }
}

#Preview {
    OnBoardingInviteView(mainViewModel: MainViewModel(), caregiverDashboardViewModel: CaregiverDashboardViewModel())
}
