//
//  TestAuthView.swift
//  YTeam Watch App
//
//  Created by Kevin Sander Utomo on 16/10/23.
//

import SwiftUI

struct MainView: View {
    @ObservedObject private var fallDetector = FallDetectionManager()
    @StateObject private var vm = TestAuthViewModel()
    @StateObject private var locationVM = LocationViewModel()
    var body: some View {
        VStack {
            if vm.userAuth?.userID != nil {
                switch locationVM.authorizationStatus {
                case .notDetermined:
//                    AnyView(RequestLocationView())
//                        .environmentObject(locationVM)
                    IdleDetectionView()
                    TestChargingView(authVM: vm)
                case .restricted:
                    ErrorView(errorText: "Location use is restricted.")
                case .denied:
                    ErrorView(errorText: "The app does not have location permissions. Please enable them in settings.")
                case .authorizedAlways, .authorizedWhenInUse:
                    IdleDetectionView()
                    TestChargingView(authVM: vm)
                default:
                    Text("Unexpected status")
                }
            } else {
                Text("Not authenticated and not logged in")
            }
        }
        .onAppear {
            locationVM.requestPermission()
        }
    }
}

#Preview {
    MainView()
}

