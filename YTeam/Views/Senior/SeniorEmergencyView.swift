//
//  SeniorEmergencyView.swift
//  YTeam
//
//  Created by Yap Justin on 18/10/23.
//

import SwiftUI

struct SeniorEmergencyView: View {
    @StateObject var seniorEmergencyViewModel = SeniorEmergencyViewModel()
    
    var body: some View {
        VStack {
            Text("Welcome!")
            Text("\(seniorEmergencyViewModel.user?.email ?? "")")
            
            Text("Give your email to your caregivers")
            ForEach(seniorEmergencyViewModel.invites, id: \.id) { invite in
                HStack {
                    Text(invite.seniorData!.email!)
                    Text(invite.caregiverData!.email!)
                    Text(String(invite.accepted!))
                    Button {
                        seniorEmergencyViewModel.acceptInvite(id: invite.id!)
                    } label: {
                        Text("Accept")
                    }
                }
            }
        }
    }
}

#Preview {
    SeniorEmergencyView()
}
