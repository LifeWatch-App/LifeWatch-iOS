//
//  HeartRateView.swift
//  YTeam Watch App
//
//  Created by Kenny Jinhiro Wibowo on 30/10/23.
//

import SwiftUI

struct HeartRateView: View {
    @ObservedObject var heartManager: HeartManager = HeartManager()
    var body: some View {
        VStack{
            Text(heartManager.heartRate.description)
                .font(.title)
            Text("BPM")
        }
    }
}

#Preview {
    HeartRateView()
}
