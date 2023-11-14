//
//  OnBoardingInviteView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 14/11/23.
//

import SwiftUI

struct OnBoardingInviteView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("inviteModal") var inviteModal = true
    
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
            
            Image("Invite-Senior")
                .resizable()
                .scaledToFit()
            
            Spacer()
            
            VStack(alignment: .leading) {
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
            .padding(.vertical, 24)
            
            Button {
                caregiverDashboardViewModel.sendRequestToSenior()
                caregiverDashboardViewModel.inviteEmail = ""
                inviteModal = false
                dismiss()
            } label: {
                HStack {
                    Spacer()
                    Text("Send Request")
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
    OnBoardingInviteView(caregiverDashboardViewModel: CaregiverDashboardViewModel())
//        .preferredColorScheme(.dark)
}
