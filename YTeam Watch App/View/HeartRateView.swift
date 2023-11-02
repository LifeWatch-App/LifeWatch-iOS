//
//  HeartRateView.swift
//  YTeam Watch App
//
//  Created by Kenny Jinhiro Wibowo on 30/10/23.
//

import SwiftUI

struct HeartRateView: View {
    @ObservedObject var heartManager: HeartManager = HeartManager()
    @ObservedObject var fallManager: FallDetectionManager = FallDetectionManager()
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
    }
}

#Preview {
    HeartRateView()
}
