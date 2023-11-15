//
//  ContentView.swift
//  CobaApp Watch App
//
//  Created by Kevin Sander Utomo on 10/10/23.
//

import SwiftUI

struct TestChargingView: View {
    @StateObject private var vm = ChargingViewModel()
    
    var body: some View {
        VStack {
            Text("\(vm.batteryLevel?.description ?? "Not able to fetch") %")
            Text(vm.batteryCharging.description)

            HStack {
                Button("Start") {
                    vm.startCharging()
                }
                
                Button("Stop") {
                    vm.stopCharging()
                }
            }
            .padding()
        }
    }
}

struct TestCharging_Previews: PreviewProvider {
    static var previews: some View {
        TestChargingView()
    }
}

