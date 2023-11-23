//
//  TestAuthView.swift
//  YTeam Watch App
//
//  Created by Kevin Sander Utomo on 16/10/23.
//

import SwiftUI

struct MainView: View {
    //@ObservedObject private var fallDetector: FallDetectionManager = FallDetectionManager()
    //@ObservedObject private var motionDetector: CoreMotionManager = CoreMotionManager()
    @StateObject private var authVM = TestAuthViewModel()
    //@ObservedObject private var heartManager: HeartManager = HeartManager()

    //    private var fallDetected: Bool {
    //        return fallDetector.fall || motionDetector.fall
    //    }

    var body: some View {
        if authVM.userAuth?.userID != nil {
            CombinedView()
            //            TestChargingView()
            //                        IdleDetectionView()
            //            Text("Logged in")
            //                .environmentObject(authVM)
            //            TestChargingView()
                .environmentObject(authVM)
            //.environmentObject(heartManager)
            //                .sheet(isPresented: $motionDetector.fall) {
            //                    FallNotificationView()
            //                        .environmentObject(fallDetector)
            //                        .environmentObject(motionDetector)
            //                        .toolbar(.hidden, for: .navigationBar)
            //                }
            //                .sheet(isPresented: $fallDetector.fall) {
            //                    FallNotificationView()
            //                        .environmentObject(fallDetector)
            //                        .environmentObject(motionDetector)
            //                        .toolbar(.hidden, for: .navigationBar)
            //                }
            //                .sheet(isPresented: $fallDetector.notificationSent) {
            //                    FallNotificationSentView()
            //                        .environmentObject(fallDetector)
            //                        .environmentObject(motionDetector)
            //                        .toolbar(.hidden, for: .navigationBar)
            //                }

        } else if authVM.userAuth?.userID == nil {
            Text("Not authenticated and logged in")
        }
    }
}

#Preview {
    MainView()
}

