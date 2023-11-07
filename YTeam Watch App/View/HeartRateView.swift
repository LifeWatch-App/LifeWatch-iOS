//
//  HeartRateView.swift
//  YTeam Watch App
//
//  Created by Kenny Jinhiro Wibowo on 30/10/23.
//

import SwiftUI

struct HeartRateView: View {
    @EnvironmentObject var heartManager: HeartManager
    @EnvironmentObject var fallManager: FallDetectionManager
    @EnvironmentObject var motionManager: CoreMotionManager
    var body: some View {
        VStack{
            Button{
                Task { await heartManager.updateLowHeartRateToDatabase() }
            } label: {
                Text("Low Heart")
            }
            Button{
                Task { await heartManager.updateHighHeartRateToDatabase() }
            } label: {
                Text("High Heart")
            }
            Button{
                Task { await heartManager.updateIrregularHeartRhythmToDatabase() }
            } label: {
                Text("Irregular Heart")
            }
            Text(heartManager.heartRate.description)
                .font(.title)
            Text("BPM")
        }
        .sheet(isPresented: $fallManager.fall) {
            FallNotificationView()
        }
    }
}

#Preview {
    HeartRateView()
}
