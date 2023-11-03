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
                    .task {
                        PTT.shared.requestJoinChannel()
                        mainViewModel.addInvitesListener()
                    }
            } else {
                CaregiverView(mainViewModel: mainViewModel)
                    .task {
                        PTT.shared.requestJoinChannel()
                        mainViewModel.addInvitesListener()
                    }
            }
        } else {
            ChooseRoleView(mainViewModel: mainViewModel)
        }
    }
}

#Preview {
    MainView()
}
