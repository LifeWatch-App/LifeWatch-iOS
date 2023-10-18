//
//  SeniorEmergencyView.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 18/10/23.
//

import SwiftUI

struct SeniorEmergencyView: View {
    @State var batteryLevel: Double = 86
    @State var walkieTalkieToggle: Bool = false
    @State var locationToggle: Bool = false
    @StateObject var seniorEmergencyViewModel = SeniorEmergencyViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack{
                    VStack {
                        Text("Welcome!")
                        Text("\(seniorEmergencyViewModel.user?.email ?? "")")
                        
                        Text("Give your email to your caregivers")
                        ForEach(seniorEmergencyViewModel.invites, id: \.id) { invite in
                            HStack {
                                Text(invite.seniorData!.email!)
                                Text(invite.caregiverData!.email!)
                                Text(String(invite.accepted!))
                                Button {
                                    seniorEmergencyViewModel.acceptInvite(id: invite.id!)
                                } label: {
                                    Text("Accept")
                                }
                            }
                        }
                    }
                    SOSButton()
                        .padding(.top, 8)
                    ChargingCard(batteryLevel: $batteryLevel)
                    WTLocationCard(walkieTalkieToggle: $walkieTalkieToggle, locationToggle: $locationToggle)
                }
            }
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.title)
                    }
                }
            }
            .navigationTitle("Emergency")
        }
    }
}

struct SOSButton: View {
    var body: some View {
        Text("Press alert button to bell")
            .font(.system(size: 18))
        Button {
            // SOS
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
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(.blue)
                        .frame(width: 38, height: 38)
                    Image(systemName: "flipphone")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                }
                Toggle(isOn: $walkieTalkieToggle, label: {
                    Text("Walkie Talkie")
                        .font(.system(size: 18))
                })
            }
            .padding()
            Divider()
                .background(.primary)
                .padding(.leading, 48)
                
            HStack{
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(.blue)
                        .frame(width: 38, height: 38)
                    Image(systemName: "location.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                }
                Toggle(isOn: $locationToggle, label: {
                    Text("Location")
                        .font(.system(size: 18))
                })
            }
            .padding()
        }
        
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
        .padding(.horizontal)
    }
}

struct ChargingCard: View {
    @Binding var batteryLevel: Double
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundStyle(.blue)
                    .frame(width: 38, height: 38)
                Image(systemName: "applewatch")
                    .font(.system(size: 18))
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading) {
                Text("Watch Battery")
                    .font(.system(size: 18))
                Text("Charging")
                    .font(.system(size: 14))
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
                    Color(progress > 0.25 && progress < 0.50 ? .orange : progress > 0.50 ? .blue : .red),
                    style: StrokeStyle(
                        lineWidth: 8,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.75), value: progress)
        }
    }
}

#Preview {
    SeniorEmergencyView()
}
