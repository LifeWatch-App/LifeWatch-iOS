//
//  RoutineCircularProgressView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 05/11/23.
//

import SwiftUI

struct RoutineCircularProgressView: View {
    let progress: Double
    let disabled: Bool
    
    var body: some View {
        ZStack {
            if disabled {
                Circle()
                    .stroke(
                        .secondary,
                        lineWidth: 4
                    )
            } else {
                Circle()
                    .stroke(
                        .accent.opacity(0.25),
                        lineWidth: 4
                    )
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        .accent,
                        style: StrokeStyle(
                            lineWidth: 4,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.75), value: progress)
            }
        }
    }
}

#Preview {
    RoutineCircularProgressView(progress: 0.3, disabled: false)
}
