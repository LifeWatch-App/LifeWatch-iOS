//
//  CombinedView.swift
//  YTeam Watch App
//
//  Created by Kevin Sander Utomo on 30/10/23.
//

import SwiftUI

struct CombinedView: View {
    @StateObject private var locationVM = LocationViewModel()
//    @StateObject private var idleVM = IdleDetectionViewModel()
//    @StateObject private var chargingVM = ChargingViewModel()
    @EnvironmentObject private var authVM: TestAuthViewModel
    
    var body: some View {
        
        switch locationVM.authorizationStatus {
        case .notDetermined:
            AnyView(RequestLocationView())
                .environmentObject(locationVM)
        case .restricted:
            ErrorView(errorText: "Location use is restricted.")
        case .denied:
            ErrorView(errorText: "The app does not have location permissions. Please enable them in settings.")
        case .authorizedAlways, .authorizedWhenInUse:
            VStack {
                VStack(spacing: 15) {
//                    Text("\(chargingVM.batteryLevel?.description ?? "Not able to fetch") %")
//                    Text(chargingVM.batteryCharging.description)
                    
                    VStack {
//                        SOSView()
                        PairView(
                            leftText: "Latitude:",
                            rightText: String(locationVM.lastSeenLocation?.coordinate.latitude ?? 0)
                        )
                        PairView(
                            leftText: "Longitude:",
                            rightText: String(locationVM.lastSeenLocation?.coordinate.latitude ?? 0)
                        )
                    }
                }
                .padding()
            }
//            .onReceive(idleVM.timer) { _ in
//                idleVM.checkPosition()
//            }
        default:
            Text("Unexpected status")
        }
    }
}

#Preview {
    CombinedView()
}


