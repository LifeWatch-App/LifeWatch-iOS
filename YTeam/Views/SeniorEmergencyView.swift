//
//  SeniorEmergencyView.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 18/10/23.
//

import SwiftUI

struct SeniorEmergencyView: View {
    @State var batteryLevel: Double = 76
    @State var walkieTalkieToggle: Bool = false
    @State var locationToggle: Bool = false
    var body: some View {
        NavigationStack {
            VStack{
                Spacer()
                SOSButton()
                    .padding(.top, 8)
                ChargingCard(batteryLevel: $batteryLevel)
                WTLocationCard(walkieTalkieToggle: $walkieTalkieToggle, locationToggle: $locationToggle)
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Emergency")
                        .font(.title)
                        .bold()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                }
            }
            .toolbarTitleDisplayMode(.inline)
        }
    }
}

struct SOSButton: View {
    var body: some View {
        Text("Press alert button to bell")
        Button {
            //SOS
        } label: {
            ZStack {
                Circle()
                    .stroke(.blue)
                    .frame(width: Screen.width * 0.9)
                Circle()
                    .tint(.blue)
                    .frame(width: Screen.width * 0.8, height: Screen.width * 0.8)
                Image(systemName: "light.beacon.max.fill")
                    .resizable()
                    .tint(.white)
                    .frame(width: Screen.width * 0.35 * 1.17730, height: Screen.width * 0.35)
            }
        }
    }
}

struct WTLocationCard: View {
    @Binding var walkieTalkieToggle: Bool
    @Binding var locationToggle: Bool
    var body: some View {
        VStack(spacing: 8) {
            HStack{
                Image(systemName: "flipphone")
                    .foregroundStyle(.blue)
                Toggle(isOn: $walkieTalkieToggle, label: {
                    Text("Walkie Talkie")
                })
            }
            Divider()
                .background(.primary)
                .padding(.leading, 24)
                
            HStack{
                Image(systemName: "location.fill")
                    .foregroundStyle(.blue)
                Toggle(isOn: $locationToggle, label: {
                    Text("Location")
                })
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
        .padding(.horizontal)
    }
}

struct ChargingCard: View {
    @Binding var batteryLevel: Double
    var body: some View {
        HStack {
            Image(systemName: "applewatch")
                .foregroundStyle(.blue)
            VStack(alignment: .leading) {
                Text("Watch Battery")
                Text("Charging")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            ZStack{
                CircularProgressView(progress: batteryLevel / 100)
                Text("\(batteryLevel, specifier: "%.0f")")
                    .bold()
            }
                .frame(width: Screen.width * 0.15)
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
        .padding(.horizontal)
        .padding(.top, 16)
    }
}
struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color(UIColor.systemGray5),
                    lineWidth: 8
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color(progress > 0.25 && progress < 0.85 ? .orange : progress > 0.85 ? .green : .red),
                    style: StrokeStyle(
                        lineWidth: 8,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                // 1
                .animation(.easeOut(duration: 0.75), value: progress)

        }
    }
}

#Preview {
    SeniorEmergencyView()
}
