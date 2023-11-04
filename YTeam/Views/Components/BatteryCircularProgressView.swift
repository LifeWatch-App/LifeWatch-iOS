//
//  CircularProgressView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 03/11/23.
//

import SwiftUI

struct BatteryCircularProgressView: View {
    let progress: Double
    let charging: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color(UIColor.systemGray5),
                    lineWidth: 6
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color(charging ? Color("secondary-orange") : progress > 0.2 ? .accent : Color("emergency-pink")),
                    style: StrokeStyle(
                        lineWidth: 6,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.75), value: progress)
        }
    }
}

#Preview {
    BatteryCircularProgressView(progress: 0.8, charging: true)
}
