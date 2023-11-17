//
//  InviteSheetView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 14/11/23.
//

import SwiftUI

struct InviteSheetView: View {
    @ObservedObject var caregiverDashboardViewModel: CaregiverDashboardViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
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
            .padding(.vertical, 12)
            
            Button {
                caregiverDashboardViewModel.sendRequestToSenior()
                caregiverDashboardViewModel.inviteEmail = ""
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
        .presentationDetents([.medium])
        .padding()
    }
}

#Preview {
    InviteSheetView(caregiverDashboardViewModel: CaregiverDashboardViewModel())
}
