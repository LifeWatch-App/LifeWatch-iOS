//
//  CaregiverEmergencyView.swift
//  YTeam
//
//  Created by Yap Justin on 18/10/23.
//

import SwiftUI

struct CaregiverEmergencyView: View {
    @StateObject var caregiverEmergencyViewModel = CaregiverEmergencyViewModel()
    @State var email = ""
    
    var body: some View {
        VStack {
            Text("Welcome!")
            Text("\(caregiverEmergencyViewModel.user?.email ?? "")")
            
            Text("Enter your senior's email")
            TextField("Email", text: $email)
            Button {
                caregiverEmergencyViewModel.sendRequestToSenior(email: email)
            } label: {
                Text("Request access")
            }
            ForEach(caregiverEmergencyViewModel.invites, id: \.id) { invite in
                HStack {
                    Text(invite.seniorData?.email ?? "")
                    Text(invite.caregiverData?.email ?? "")
                    Text(String(invite.accepted!))
                }
            }
        }
    }
}

#Preview {
    CaregiverEmergencyView()
}
