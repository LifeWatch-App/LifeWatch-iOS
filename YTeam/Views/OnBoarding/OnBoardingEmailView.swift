//
//  OnBoardingEmailView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 14/11/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct OnBoardingEmailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var seniorDashboardViewModel: SeniorDashboardViewModel
    @AppStorage("emailModal") var emailModal = true
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button("Skip") {
                    emailModal = false
                    dismiss()
                }
            }
            
            Spacer()
            
            Image("Invite-Caregiver")
                .resizable()
                .scaledToFit()
            
            Spacer()
            
            VStack {
                Text("Allow your caregiver to invite you by providing them with your email address.")
                    .padding(.bottom, 8)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                
                Text(seniorDashboardViewModel.user?.email ?? "Email not found")
                    .font(.title)
                    .bold()
                    .foregroundStyle(Color(.label))
                    .onTapGesture(count: 2) {
                        UIPasteboard.general.setValue("senior@gmail.com",
                            forPasteboardType: UTType.plainText.identifier)
                    }
            }
            .padding(.vertical, 24)
            
            Button {
                emailModal = false
                dismiss()
            } label: {
                HStack {
                    Spacer()
                    Text("Done")
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
    OnBoardingEmailView(seniorDashboardViewModel: SeniorDashboardViewModel())
//        .preferredColorScheme(.dark)
}
