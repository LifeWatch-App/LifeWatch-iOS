//
//  HeartRateView.swift
//  YTeam Watch App
//
//  Created by Kenny Jinhiro Wibowo on 30/10/23.
//

import SwiftUI

struct HeartRateView: View {
    @ObservedObject var healthKitViewModel: HealthKitViewModel = HealthKitViewModel()
    var body: some View {
        VStack{
            Text(healthKitViewModel.heartRate.description)
                .font(.title)
            Text("BPM")
        }
    }
}

#Preview {
    HeartRateView()
}
