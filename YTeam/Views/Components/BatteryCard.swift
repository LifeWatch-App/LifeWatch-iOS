//
//  BatteryCard.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 05/11/23.
//

import SwiftUI

struct BatteryCard: View {
    @Binding var batteryInfo: BatteryLevel?
    let type: String

    var stateColor: Color {
        if type == "watch" {
            return batteryInfo?.watchBatteryState == "charging" ? Color.orange : Color.blue
        } else if type == "iphone" {
            return batteryInfo?.iphoneBatteryState == "charging" ? Color.orange : Color.blue
        }

        return Color.blue
    }

    var progressAmount: Float {
        if type == "watch" {
            return Float(((Double(batteryInfo?.watchBatteryLevel ?? "0") ?? 0) / 100 ))
        } else {
            return Float(((Double(batteryInfo?.iphoneBatteryLevel ?? "0") ?? 0) / 100))
        }
    }

    var body: some View {
        HStack(spacing: 5) {
            ProgressBar(progress: progressAmount, type: type, color: stateColor)
                .frame(width: 45, height: 45, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)

            VStack(alignment: .leading) {
                Text(type == "watch" ? "Watch Battery" : "iPhone Battery")
                    .font(.caption)

                HStack(spacing: 2) {
                    if type == "watch" {
                        if batteryInfo?.watchBatteryState == "charging" {
                            Image(systemName: "bolt.fill")
                                .font(.subheadline)
                                .foregroundStyle(stateColor)
                        }
                    } else {
                        if batteryInfo?.iphoneBatteryState == "charging" {
                            Image(systemName: "bolt.fill")
                                .font(.subheadline)
                                .foregroundStyle(stateColor)
                        }
                    }

                    if type == "watch" {
                        Text("\(batteryInfo?.watchBatteryLevel ?? "0")%")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    } else {
                        Text("\(batteryInfo?.iphoneBatteryLevel ?? "0")%")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                }
            }
        }
        .padding(.leading, 5)
        .padding(.trailing, 10)
        .padding(.vertical, 10)
        .background(Color("emergency-pink").opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 5))
        //            .shadow(color: .black, radius: 0.2, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/
    }
}

struct ProgressBar: View {
    let progress: Float
    let type: String
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 5.0)
                .opacity(0.2)
                .foregroundStyle(Color(uiColor: UIColor.systemCyan))

            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .foregroundStyle(color)
                .rotationEffect(Angle(degrees: 270))
                .animation(.easeInOut(duration: 2.0), value: progress)

            Image(systemName: type == "watch" ? "applewatch" : "iphone")
                .font(.title3)
                .foregroundStyle(color)
        }
    }
}

//#Preview {
//    BatteryCard(batteryInfo: <#BatteryLevel#>, progressValue: .constant(0.35))
//}
