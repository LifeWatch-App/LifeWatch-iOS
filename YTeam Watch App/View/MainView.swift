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
                IdleDetectionView()
            } else {
                Text("Not authenticated and not logged in")
            }
            
            //            switch locationVM.authorizationStatus {
            //            case .notDetermined:
            //                RequestLocationView()
            //                    .environmentObject(locationVM)
            //            case .restricted:
            //                ErrorView(errorText: "Location use is restricted.")
            //            case .denied:
            //                ErrorView(errorText: "The app does not have location permissions. Please enable them in settings.")
            //            case .authorizedAlways, .authorizedWhenInUse:
            //                if vm.userAuth?.userID != nil {
            //                    IdleDetectionView()
            //                } else {
            //                    Text("Not authenticated and not logged in")
            //                }
            //            default:
            //                Text("Unexpected status")
            //            }
        }
        //        .onAppear {
        //            locationVM.requestPermission()
        //        }
    }
}

#Preview {
    MainView()
}

