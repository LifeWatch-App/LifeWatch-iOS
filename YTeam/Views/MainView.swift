//
//  MainView.swift
//  YTeam
//
//  Created by Yap Justin on 12/10/23.
//

import SwiftUI
import AVFAudio

struct MainView: View {
    @StateObject var mainViewModel = MainViewModel()
    @StateObject var batteryLevelViewModel = BatteryLevelStateViewModel()
    @StateObject var caregiverDashboardViewModel = CaregiverDashboardViewModel()

    var body: some View {
        if (mainViewModel.userData?.role == nil) {
            ChooseRoleView(mainViewModel: mainViewModel)
        } else if (mainViewModel.userData?.name == "Unknown") {
            EnterNameView()
        } else {
            if mainViewModel.userData?.role == "senior" {
                SeniorView(mainViewModel: mainViewModel)
                    .environmentObject(batteryLevelViewModel)
                    .environmentObject(caregiverDashboardViewModel)
                    .task {
                        PTT.shared.requestJoinChannel()
                        mainViewModel.addInvitesListener()
                        await AVAudioApplication.requestRecordPermission()
                    }
            } else {
                CaregiverView(mainViewModel: mainViewModel)
                    .environmentObject(batteryLevelViewModel)
                    .environmentObject(caregiverDashboardViewModel)
                    .task {
                        PTT.shared.requestJoinChannel()
                        mainViewModel.addInvitesListener()
                        await AVAudioApplication.requestRecordPermission()
                    }
            }
        }
    }
}

#Preview {
    MainView()
}
