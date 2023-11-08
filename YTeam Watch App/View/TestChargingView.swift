//
//  ContentView.swift
//  CobaApp Watch App
//
//  Created by Kevin Sander Utomo on 10/10/23.
//

import SwiftUI

struct TestChargingView: View {
    @StateObject private var vm = ChargingViewModel()
    @EnvironmentObject var authVM: TestAuthViewModel
    
    var body: some View {
        VStack {
            Text("\(vm.batteryLevel?.description ?? "Not able to fetch") %")
            Text(vm.batteryCharging.description)
            
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
            .padding()
        }
    }
}

struct TestCharging_Previews: PreviewProvider {
    static var previews: some View {
        TestChargingView()
    }
}

