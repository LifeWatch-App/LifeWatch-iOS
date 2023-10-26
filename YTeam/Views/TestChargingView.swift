//
//  TestChargingView.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 16/10/23.
//

import Foundation

//
//  ContentView.swift
//  CobaApp
//
//  Created by Kevin Sander Utomo on 10/10/23.
//

import SwiftUI
import Charts

struct TestChargingView: View {
    @ObservedObject private var mainViewModel = MainViewModel()
    @StateObject private var vm = BatteryLevelStateViewModel()

    var body: some View {
        VStack {
            Text("\(vm.batteryLevel?.description ?? "Not able to fetch") %")
            Text(vm.batteryCharging.description)
        }
        .onAppear {
            mainViewModel.getUserData()
        }
        .onReceive(mainViewModel.$userData) { userData in
            if let userData = userData, userData.role == "senior" {
                Task {
                    vm.setupSubscribers()
                }
            }
        }
    }
}

#Preview {
    TestChargingView()
}
