//
//  ContentView.swift
//  CobaApp Watch App
//
//  Created by Kevin Sander Utomo on 10/10/23.
//

import SwiftUI

struct TestChargingView: View {
    @StateObject private var vm = CobaTestViewModel()
    
    var body: some View {
        VStack {
            Text(vm.batteryCharging?.descriptionState ?? "Unknown")
            
            HStack {
                Button("Start") {
                    vm.startCharging()
                }
                
                Button("Stop") {
                    vm.stopCharging()
                }
            }
            
            ForEach(vm.chargingRangesForWatch, id: \.self) { range in
                VStack {
                    Text(range.getFormattedStartEndTime(chargingRange: range))
                }
            }
        }
        .onChange(of: vm.batteryCharging ?? .unknown, perform: { newValue in
            vm.handleBatteryStateChange(newValue)
        })
        .padding()
    }
}

struct TestCharging_Previews: PreviewProvider {
    static var previews: some View {
        TestChargingView()
    }
}

