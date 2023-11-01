//
//  TestBatteryView.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 28/10/23.
//

import SwiftUI

struct TestBatteryView: View {
    @StateObject var batteryVM = BatteryMonitorViewModel()
    var body: some View {
        if let batteryInfo = batteryVM.batteryInfo {
            VStack {
                Text(batteryInfo.iphoneBatteryLevel ?? "0%")
                Text(batteryInfo.iphoneBatteryState ?? "Unknown")
                Text(batteryInfo.watchBatteryLevel ?? "0%")
                Text(batteryInfo.watchBatteryState ?? "Unknown")
            }
        } else {
            VStack {
                Text("No Data!!!")
            }
        }
    }
}

#Preview {
    TestBatteryView()
}
