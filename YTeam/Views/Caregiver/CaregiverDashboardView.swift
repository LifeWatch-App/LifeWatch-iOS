//
//  CaregiverEmergencyView.swift
//  YTeam
//
//  Created by Yap Justin on 18/10/23.
//

import SwiftUI

struct CaregiverDashboardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var caregiverDashboardViewModel = CaregiverDashboardViewModel()
    @State var email = ""
    @State var showChangeSenior = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    ScrollView {
                        VStack(spacing: 20) {
                            //                    VStack {
                            //                        Text("Welcome, \(caregiverDashboardViewModel.user?.email ?? "")!")
                            //                        Text("Enter your senior's email")
                            //                        TextField("Email", text: $email)
                            //                            .padding()
                            //                            .keyboardType(.emailAddress)
                            //                            .autocapitalization(.none)
                            //                        Button {
                            //                            caregiverDashboardViewModel.sendRequestToSenior(email: email)
                            //                        } label: {
                            //                            Text("Request access")
                            //                        }
                            //                        ForEach(caregiverDashboardViewModel.invites, id: \.id) { invite in
                            //                            HStack {
                            //                                Text("Invite sent: \(invite.seniorData!.email!)")
                            //                                Text(invite.accepted! ? "(Accepted)" : "(Pending)")
                            //                            }
                            //                            .padding(.top, 4)
                            //                        }
                            //                    }
                            
                            SeniorStatus(caregiverDashboardViewModel: caregiverDashboardViewModel)
                                .padding(.horizontal)
                            
                            UpcomingRoutines(caregiverDashboardViewModel: caregiverDashboardViewModel)
                        }
                    }
                    
                    Button {
                        
                    } label: {
                        HStack {
                            Spacer()
                            
                            Image(systemName: "flipphone")
                            Text("Walkie Talkie")
                            
                            Spacer()
                        }
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                    }
                }
                .background(colorScheme == .light ? Color(.systemGroupedBackground) : .black)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showChangeSenior.toggle()
                        } label: {
                            HStack {
                                Text("Subroto")
                                
                                Image(systemName: showChangeSenior ? "chevron.up" : "chevron.down")
                                    .font(.subheadline)
                                    .padding(.leading, -2)
                            }
                            .font(.headline)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            ProfileView()
                        } label: {
                            Image(systemName: "person.crop.circle")
                                .font(.title)
                        }
                    }
                }
                .navigationTitle("Dashboard")
            }
            
            ChangeSeniorOverlay(showChangeSenior: $showChangeSenior)
        }
    }
}

struct SeniorStatus: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var caregiverDashboardViewModel: CaregiverDashboardViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Senior's Status")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                Image("symtomps")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Safe Condition")
                            .font(.headline)
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.white, Color("secondary-green"))
                            .font(.subheadline)
                    }
                    
                    Text("No symtomps detected")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(colorScheme == .light ? .white : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    HStack {
                        VStack {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.white)
                        }
                        .padding(8)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Spacer()
                    }
                    
                    Text("Heart Rate")
                        .font(.subheadline)
                    
                    HStack {
                        Text("\(caregiverDashboardViewModel.heartRate)")
                            .font(.title)
                            .bold()
                        
                        Text("bpm")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                            .padding(.leading, -4)
                    }
                }
                .padding(12)
                .background(colorScheme == .light ? .white : Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading) {
                    HStack {
                        VStack {
                            Image(systemName: "location.fill")
                                .foregroundStyle(.white)
                        }
                        .padding(8)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Spacer()
                    }
                    
                    Text("Location")
                        .font(.subheadline)
                    
                    Text("\(caregiverDashboardViewModel.location)")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 6)
                }
                .padding(12)
                .background(colorScheme == .light ? .white : Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading) {
                    HStack {
                        VStack {
                            Image(systemName: (caregiverDashboardViewModel.idleInfo.first(where: { $0.taskState == "ongoing" }) != nil) ? "figure.walk" : "moon.fill")
                                .foregroundStyle(.white)
                                .padding(.horizontal, (caregiverDashboardViewModel.idleInfo.first(where: { $0.taskState == "ongoing" }) != nil) ? 2 : 0)
                        }
                        .padding(8)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Spacer()
                    }
                    
                    if (caregiverDashboardViewModel.idleInfo.first(where: { $0.taskState == "ongoing" }) != nil) {
                        
                        Text("Inactive for")
                            .font(.subheadline)
                        
                        HStack {
                            Text(Date.timeDifference(unix: caregiverDashboardViewModel.idleInfo.first(where: { $0.taskState == "ongoing" })?.startTime ?? 0).0)
                                .font(.title)
                                .bold()
                            
                            if (Date.timeDifference(unix: caregiverDashboardViewModel.idleInfo.first(where: { $0.taskState == "ongoing" })?.startTime ?? 0).1) <= 60 {
                                Text("min")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                                    .padding(.leading, -4)
                            } else if (Date.timeDifference(unix: caregiverDashboardViewModel.idleInfo.first(where: { $0.taskState == "ongoing" })?.startTime ?? 0).1) <= 3600 {
                                Text("hours")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                                    .padding(.leading, -4)
                            } else if (Date.timeDifference(unix: caregiverDashboardViewModel.idleInfo.first(where: { $0.taskState == "ongoing" })?.startTime ?? 0).1) >= 86400 {
                                Text("days")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                                    .padding(.leading, -4)
                            }
                        }
                    } else {
                        Text("Currently")
                            .font(.subheadline)
                        
                        Text("Active")
                            .font(.title2)
                            .bold()
                            .padding(.bottom, 6)
                    }
                }
                .padding(12)
                .background(colorScheme == .light ? .white : Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            if let batteryInfo = caregiverDashboardViewModel.batteryInfo {
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        ZStack {
                            BatteryCircularProgressView(progress: (Double(batteryInfo.watchBatteryLevel ?? "0") ?? 0) / 100, charging: batteryInfo.watchBatteryState == "charging")
                                .frame(width: 50)
                            
                            
                            Image(systemName: "applewatch")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14)
                                .foregroundStyle(batteryInfo.watchBatteryState == "charging" ? Color("secondary-orange") : .accent, .white)
                        }
                        .padding(.horizontal, 4)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Watch Battery")
                                .font(.caption)
                            
                            HStack {
                                if batteryInfo.watchBatteryState == "charging" {
                                    Image(systemName: "bolt.fill")
                                        .foregroundStyle(Color("secondary-orange"))
                                }
                                
                                Text("\(Double(batteryInfo.watchBatteryLevel ?? "0") ?? 0, specifier: "%.0f")%")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .padding(.leading, batteryInfo.watchBatteryState == "charging" ? -4 : 0)
                            }
                            .animation(.easeInOut, value: batteryInfo.watchBatteryState)
                            .animation(.easeInOut, value: batteryInfo.watchBatteryLevel)
                        }
                        
                        Spacer()
                    }
                    .padding(.leading, 8)
                    .padding(.vertical, 12)
                    .frame(width: (Screen.width/2)-22)
                    .background(colorScheme == .light ? .white : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    HStack(spacing: 8) {
                        ZStack {
                            BatteryCircularProgressView(progress: (Double(batteryInfo.iphoneBatteryLevel ?? "0") ?? 0) / 100, charging: batteryInfo.iphoneBatteryState == "charging")
                                .frame(width: 50)
                            
                            Image(systemName: "iphone")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14)
                                .foregroundStyle(batteryInfo.iphoneBatteryState == "charging" ? Color("secondary-orange") : .accent, .white)
                        }
                        .padding(.horizontal, 4)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("iPhone Battery")
                                .font(.caption)
                            
                            HStack {
                                if batteryInfo.iphoneBatteryState == "charging" {
                                    Image(systemName: "bolt.fill")
                                        .foregroundStyle(Color("secondary-orange"))
                                }
                                
                                Text("\(Double(batteryInfo.iphoneBatteryLevel ?? "0") ?? 0, specifier: "%.0f")%")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .padding(.leading, batteryInfo.iphoneBatteryState == "charging" ? -4 : 0)
                            }
                            .animation(.easeInOut, value: batteryInfo.iphoneBatteryState)
                            .animation(.easeInOut, value: batteryInfo.iphoneBatteryLevel)
                        }
                        
                        Spacer()
                    }
                    .padding(.leading, 8)
                    .padding(.vertical, 12)
                    .frame(width: (Screen.width/2)-22)
                    .background(colorScheme == .light ? .white : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}

struct UpcomingRoutines: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var caregiverDashboardViewModel: CaregiverDashboardViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Upcoming Routines")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                NavigationLink {
                    EmptyView()
                } label: {
                    Text("See All")
                        .font(.headline)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(caregiverDashboardViewModel.routines) { routine in
                        HStack(spacing: 16) {
                            VStack {
                                Image(systemName: "pill.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40)
                                    .foregroundStyle(.white)
                            }
                            .padding(12)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(routine.name)
                                    .font(.headline)
                                Text(routine.description)
                                HStack {
                                    Image(systemName: "clock")
                                    Text(routine.time, style: .time)
                                        .padding(.leading, -4)
                                }
                                .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: routine.isDone ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40)
                                .foregroundStyle(.white, routine.isDone ? Color("secondary-green") : Color("emergency-pink"))
                        }
                        .padding()
                        .background(colorScheme == .light ? .white : Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .frame(width: Screen.width - 32)
                    }
                }
                .padding(.horizontal)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
        }
    }
}

#Preview {
    CaregiverDashboardView()
    //        .preferredColorScheme(.dark)
}

