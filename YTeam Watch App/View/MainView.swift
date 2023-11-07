//
//  TestAuthView.swift
//  YTeam Watch App
//
//  Created by Kevin Sander Utomo on 16/10/23.
//

import SwiftUI

struct MainView: View {
    @ObservedObject private var fallDetector: FallDetectionManager = FallDetectionManager()
    @ObservedObject private var motionDetector: CoreMotionManager = CoreMotionManager()
    @StateObject private var authVM = TestAuthViewModel()
    //    @StateObject private var locationViewModel = LocationViewModel()
    @ObservedObject private var heartManager: HeartManager = HeartManager()
    var body: some View {
        if authVM.userAuth?.userID != nil {
//            IdleDetectionView()
//            TestChargingView()
//            HeartRateView()
            SOSView()
                .environmentObject(authVM)
                .environmentObject(fallDetector)
                .environmentObject(motionDetector)
                .environmentObject(heartManager)
        } else if authVM.userAuth?.userID == nil {
            Text("Not authenticated and not logged in")
        }
    }
}

#Preview {
    MainView()
}

