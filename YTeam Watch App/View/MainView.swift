//
//  TestAuthView.swift
//  YTeam Watch App
//
//  Created by Kevin Sander Utomo on 16/10/23.
//

import SwiftUI

struct MainView: View {
    //    @ObservedObject private var fallDetector = FallDetectionManager()
    @StateObject private var authVM = TestAuthViewModel()
    //    @StateObject private var locationViewModel = LocationViewModel()

    var body: some View {
        if authVM.userAuth?.userID != nil {
//            VStack {
//                Text("Test")
//            }
            //            IdleDetectionView()
            TestChargingView()
                .environmentObject(authVM)
        } else if authVM.userAuth?.userID == nil {
            Text("Not authenticated and not logged in")
        }
    }
}

#Preview {
    MainView()
}

