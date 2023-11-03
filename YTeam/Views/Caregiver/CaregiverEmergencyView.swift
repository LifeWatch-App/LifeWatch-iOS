//
//  CaregiverEmergencyView.swift
//  YTeam
//
//  Created by Yap Justin on 18/10/23.
//

import SwiftUI

struct CaregiverEmergencyView: View {
    @State var batteryLevel: Double = 86
    @State var walkieTalkieToggle: Bool = false
    @State var locationToggle: Bool = false
    @StateObject var caregiverEmergencyViewModel = CaregiverEmergencyViewModel()
    @State var email = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack{
                    VStack {
                        Text("Welcome, \(caregiverEmergencyViewModel.user?.email ?? "")!")
                        Text("Enter your senior's email")
                        TextField("Email", text: $email)
                            .padding()
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        Button {
                            caregiverEmergencyViewModel.sendRequestToSenior(email: email)
                        } label: {
                            Text("Request access")
                        }
                        ForEach(caregiverEmergencyViewModel.invites, id: \.id) { invite in
                            HStack {
                                Text("Invite sent: \(invite.seniorData!.email!)")
                                Text(invite.accepted! ? "(Accepted)" : "(Pending)")
                            }
                            .padding(.top, 4)
                        }
                    }
                    Button {
                        PTT.shared.requestJoinChannel()
                    } label: {
                        HStack {
                            Spacer()
                            Text("requestJoinChannel")
                                .fontWeight(.semibold)
                                .padding()
                            Spacer()
                        }
                        .background(.accent)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                    }
                    .padding(.top, 8)
                    Button {
                        PTT.shared.stopReceivingAudio()
                    } label: {
                        HStack {
                            Spacer()
                            Text("stopReceivingAudio")
                                .fontWeight(.semibold)
                                .padding()
                            Spacer()
                        }
                        .background(.accent)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                    }
                    .padding(.top, 8)
                    Button {
                        caregiverEmergencyViewModel.startRecording()
                    } label: {
                        HStack {
                            Spacer()
                            Text("start recording")
                                .fontWeight(.semibold)
                                .padding()
                            Spacer()
                        }
                        .background(.accent)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                    }
                    .padding(.top, 8)
                    Button {
                        caregiverEmergencyViewModel.stopRecording()
                    } label: {
                        HStack {
                            Spacer()
                            Text("stop recording")
                                .fontWeight(.semibold)
                                .padding()
                            Spacer()
                        }
                        .background(.accent)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                    }
                    .padding(.top, 8)
                    Button {
                        caregiverEmergencyViewModel.fetchAllRecording()
                    } label: {
                        HStack {
                            Spacer()
                            Text("fetch")
                                .fontWeight(.semibold)
                                .padding()
                            Spacer()
                        }
                        .background(.accent)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                    }
                    ForEach(caregiverEmergencyViewModel.recordingsList, id: \.self) { recording in
                                            VStack{
                                                HStack{
                                                    Image(systemName:"headphones.circle.fill")
                                                        .font(.system(size:50))
                                                    
                                                    VStack(alignment:.leading) {
                                                        Text("\(recording.lastPathComponent)")
                                                    }
                                                    VStack {
                                                        Button(action: {
                                                            caregiverEmergencyViewModel.deleteRecording(url:recording)
                                                        }) {
                                                            Image(systemName:"xmark.circle.fill")
                                                                .foregroundColor(.white)
                                                                .font(.system(size:15))
                                                        }
                                                        Spacer()
                                                        
                                                        Button(action: {
                                                            caregiverEmergencyViewModel.startPlaying(url: recording)
                                                        }) {
                                                            Image(systemName: "play.fill")
                                                                .foregroundColor(.white)
                                                                .font(.system(size:30))
                                                        }
                                                        
                                                    }
                                                    
                                                }.padding()
                                            }.padding(.horizontal,10)
                                            .frame(width: 370, height: 85)
                                            .background(Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)))
                                            .cornerRadius(30)
                                            .shadow(color: Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)).opacity(0.3), radius: 10, x: 0, y: 10)
                                        }
                    .padding(.top, 8)
                    CaregiverSOSButton()
                        .padding(.top, 8)
                    CaregiverChargingCard(batteryLevel: $batteryLevel)
                    CaregiverWTLocationCard(walkieTalkieToggle: $walkieTalkieToggle, locationToggle: $locationToggle)
                }
            }
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        ProfileView()
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

struct CaregiverSOSButton: View {
    var body: some View {
        Text("Press button to talk")
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
                Image(systemName: "mic.fill")
                    .resizable()
                    .tint(.white)
                    .frame(width: Screen.width * 0.25 * 1.17730, height: Screen.width * 0.45)
            }
        }
    }
}

struct CaregiverWTLocationCard: View {
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

struct CaregiverChargingCard: View {
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

struct CaregiverCircularProgressView: View {
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
    CaregiverEmergencyView()
}

