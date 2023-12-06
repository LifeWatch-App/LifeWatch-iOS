//
//  MainView.swift
//  YTeam
//
//  Created by Yap Justin on 12/10/23.
//

import SwiftUI
import AVFAudio

struct MainView: View {
    @ObservedObject var mainViewModel: MainViewModel
    @StateObject var batteryLevelViewModel = BatteryLevelStateViewModel()

    var body: some View {
        if (mainViewModel.userData?.role == nil) {
            ChooseRoleView(mainViewModel: mainViewModel)
        } else if (mainViewModel.userData?.name == "Unknown") {
            EnterNameView()
        } else {
            if mainViewModel.userData?.role == "senior" {
                SeniorView(mainViewModel: mainViewModel)
                    .environmentObject(batteryLevelViewModel)
                    .task {
                        mainViewModel.addInvitesListener()
                        await AVAudioApplication.requestRecordPermission()
                    }
            } else {
                CaregiverView()
                    .environmentObject(batteryLevelViewModel)
                    .task {
                        mainViewModel.addInvitesListener()
                        await AVAudioApplication.requestRecordPermission()
                    }
            }
        }
    }
}

#Preview {
    MainView(mainViewModel: MainViewModel())
}
