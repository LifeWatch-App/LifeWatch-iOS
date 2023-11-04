//
//  CircularProgressView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 03/11/23.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    
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
                    Color(progress > 0.25 && progress < 0.50 ? .orange : progress > 0.50 ? .blue : .red),
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
    CircularProgressView(progress: 0.8)
}
