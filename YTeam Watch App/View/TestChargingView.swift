//
//  ContentView.swift
//  CobaApp Watch App
//
//  Created by Kevin Sander Utomo on 10/10/23.
//

import SwiftUI

struct TestChargingView: View {
    @StateObject private var vm = CobaTestViewModel()
    @EnvironmentObject var authVM: TestAuthViewModel

    var body: some View {
        VStack {
            Text(vm.batteryCharging?.descriptionState ?? "Unknown")

            Button("Test Auth") {
                print(authVM.userAuth)
            }

            HStack {
                Button("Start") {
                    vm.startCharging()
                }

                Button("Stop") {
                    vm.stopCharging()
                }
            }

            //            ForEach(vm.chargingRangesForWatch, id: \.self) { range in
            //                VStack {
            //                    Text(range.getFormattedStartEndTime(chargingRange: range))
            //                }
            //            }
        }
//        .onChange(of: vm.batteryCharging ?? .unknown, perform: { newValue in
//            if let userID = authVM.userAuth?.userID {
//                vm.handleBatteryStateChange(batteryState: newValue, userID: userID)
//            }
//        })
        .padding()
    }
}

struct TestCharging_Previews: PreviewProvider {
    static var previews: some View {
        TestChargingView()
    }
}

