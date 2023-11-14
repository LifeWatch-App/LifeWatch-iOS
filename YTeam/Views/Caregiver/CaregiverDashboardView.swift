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
    @State var showChangeSenior = false
    @State var showInviteSheet = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    ScrollView {
                        VStack(spacing: 20) {
                            SeniorStatus(caregiverDashboardViewModel: caregiverDashboardViewModel)
                                .padding(.horizontal)
                            
                            UpcomingRoutines(caregiverDashboardViewModel: caregiverDashboardViewModel)
                        }
                    }
                    
                    Button {
                        caregiverDashboardViewModel.showWalkieTalkie.toggle()
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
                    .fullScreenCover(isPresented: $caregiverDashboardViewModel.showWalkieTalkie, content: {
                        WalkieTalkieView()
                    })
                }
                .background(colorScheme == .light ? Color(.systemGroupedBackground) : .black)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showChangeSenior.toggle()
                        } label: {
                            HStack {
                                if caregiverDashboardViewModel.invites.isEmpty {
                                    Text("Add a senior")
                                } else {
                                    Text(caregiverDashboardViewModel.invites.first(where: { $0.seniorId == caregiverDashboardViewModel.selectedInviteId })?.seniorData?.name ?? "Subroto")
                                }
                                
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
                .sheet(isPresented: $showInviteSheet) {
                    InviteSheetView(caregiverDashboardViewModel: caregiverDashboardViewModel)
                }
                .navigationTitle("Dashboard")
            }
            
            ChangeSeniorOverlay(invites: $caregiverDashboardViewModel.invites, selectedUserId: $caregiverDashboardViewModel.selectedInviteId, showInviteSheet: $showInviteSheet, showChangeSenior: $showChangeSenior)
        }
    }
}

struct InviteSheetView: View {
    @ObservedObject var caregiverDashboardViewModel: CaregiverDashboardViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Request access to your senior")
                    .font(.system(size: 32))
                    .bold()
                    .padding(.bottom, 8)
                Text("Enter your senior's email address")
                TextField("Email", text: $caregiverDashboardViewModel.inviteEmail)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray3), lineWidth: 1)
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            .padding(.vertical, 12)
            
            Button {
                caregiverDashboardViewModel.sendRequestToSenior()
                caregiverDashboardViewModel.inviteEmail = ""
                dismiss()
            } label: {
                HStack {
                    Spacer()
                    Text("Send Request")
                        .fontWeight(.semibold)
                        .padding()
                    Spacer()
                }
                .background(.accent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.top, 8)
        }
        .navigationTitle("Request access to your senior")
        .presentationDetents([.medium])
        .padding()
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
                Image("safe")
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
                        Text("\(Int(caregiverDashboardViewModel.heartBeatInfo?.bpm ?? 0))")
                            .font(.title)
                            .bold()
                        
                        Text("bpm")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                            .padding(.leading, -4)
                        //                            .opacity((caregiverDashboardViewModel.heartBeatInfo != nil) ? 1 : 0)
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
                    
                    if (caregiverDashboardViewModel.latestLocationInfo != nil) {
                        Text("\(caregiverDashboardViewModel.latestLocationInfo?.isOutside ?? false ? "Outside" : "Home")")
                            .font(.title2)
                            .bold()
                            .padding(.bottom, 6)
                    } else {
                        Text("No Data")
                            .font(.title2)
                            .bold()
                            .padding(.bottom, 6)
                    }
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
                    
                    
                    if caregiverDashboardViewModel.idleInfo.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Inactivity")
                                .font(.subheadline)
                            
                            Text("No Data")
                                .font(.title2)
                                .bold()
                        }
                        
                    } else {
                        if (caregiverDashboardViewModel.idleInfo.first(where: { $0.taskState == "ongoing" }) != nil) {
                            
                            Text("Inactive for")
                                .font(.subheadline)
                            
                            HStack {
                                Text(Date.timeDifference(unix: caregiverDashboardViewModel.idleInfo.first(where: { $0.taskState == "ongoing" })?.startTime ?? 0).timeString)
                                    .font(.title)
                                    .bold()
                                
                                if (Date.timeDifference(unix: caregiverDashboardViewModel.idleInfo.first(where: { $0.taskState == "ongoing" })?.startTime ?? 0).timeDifference) <= 60 {
                                    Text("min")
                                        .foregroundStyle(.secondary)
                                        .font(.subheadline)
                                        .padding(.leading, -4)
                                } else if (Date.timeDifference(unix: caregiverDashboardViewModel.idleInfo.first(where: { $0.taskState == "ongoing" })?.startTime ?? 0).timeDifference) <= 3600 {
                                    Text("hours")
                                        .foregroundStyle(.secondary)
                                        .font(.subheadline)
                                        .padding(.leading, -4)
                                } else if (Date.timeDifference(unix: caregiverDashboardViewModel.idleInfo.first(where: { $0.taskState == "ongoing" })?.startTime ?? 0).timeDifference) >= 86400 {
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
                }
                .padding(12)
                .background(colorScheme == .light ? .white : Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    ZStack {
                        BatteryCircularProgressView(progress: (Double(caregiverDashboardViewModel.batteryInfo?.watchBatteryLevel ?? "0") ?? 0) / 100, charging: caregiverDashboardViewModel.batteryInfo?.watchBatteryState == "charging")
                            .frame(width: 50)
                        
                        
                        Image(systemName: "applewatch")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14)
                            .foregroundStyle(caregiverDashboardViewModel.batteryInfo?.watchBatteryState == "charging" ? Color("secondary-orange") : .accent, .white)
                    }
                    .padding(.horizontal, 4)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Watch Battery")
                            .font(.caption)
                        
                        HStack {
                            if caregiverDashboardViewModel.batteryInfo?.watchBatteryState == "charging" {
                                Image(systemName: "bolt.fill")
                                    .foregroundStyle(Color("secondary-orange"))
                            }
                            
                            Text("\(Double(caregiverDashboardViewModel.batteryInfo?.watchBatteryLevel ?? "No Data") ?? 0, specifier: "%.0f")%")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.leading, caregiverDashboardViewModel.batteryInfo?.watchBatteryState == "charging" ? -4 : 0)
                        }
                        .animation(.easeInOut, value: caregiverDashboardViewModel.batteryInfo?.watchBatteryState)
                        .animation(.easeInOut, value: caregiverDashboardViewModel.batteryInfo?.watchBatteryLevel)
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
                        BatteryCircularProgressView(progress: (Double(caregiverDashboardViewModel.batteryInfo?.iphoneBatteryLevel ?? "0") ?? 0) / 100, charging: caregiverDashboardViewModel.batteryInfo?.iphoneBatteryState == "charging")
                            .frame(width: 50)
                        
                        Image(systemName: "iphone")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14)
                            .foregroundStyle(caregiverDashboardViewModel.batteryInfo?.iphoneBatteryState == "charging" ? Color("secondary-orange") : .accent, .white)
                    }
                    .padding(.horizontal, 4)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("iPhone Battery")
                            .font(.caption)
                        
                        HStack {
                            if caregiverDashboardViewModel.batteryInfo?.iphoneBatteryState == "charging" {
                                Image(systemName: "bolt.fill")
                                    .foregroundStyle(Color("secondary-orange"))
                            }
                            
                            Text("\(Double(caregiverDashboardViewModel.batteryInfo?.iphoneBatteryLevel ?? "No Data") ?? 0, specifier: "%.0f")%")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.leading, caregiverDashboardViewModel.batteryInfo?.iphoneBatteryState == "charging" ? -4 : 0)
                        }
                        .animation(.easeInOut, value: caregiverDashboardViewModel.batteryInfo?.iphoneBatteryState)
                        .animation(.easeInOut, value: caregiverDashboardViewModel.batteryInfo?.iphoneBatteryLevel)
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
                    CaregiverAllRoutineView(caregiverDashboardViewModel: caregiverDashboardViewModel)
                } label: {
                    Text("See All")
                        .font(.headline)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    ForEach(caregiverDashboardViewModel.routines) { routine in
                        ForEach(routine.time.indices, id: \.self) { i in
                            HStack(spacing: 16) {
                                VStack {
                                    Image(systemName: routine.type == "Medicine" ? "pill.fill" : "figure.run")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundStyle(.white)
                                }
                                .padding(12)
                                .background(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\((routine.type == "Medicine" ? routine.medicine ?? "" : routine.activity ?? ""))")
                                        .font(.headline)
                                    Text(routine.type == "Medicine" ? "\(routine.medicineAmount ?? "") \(routine.medicineUnit?.rawValue ?? "")" : "\(routine.description ?? "")")
                                        .font(.subheadline)
                                    HStack {
                                        Image(systemName: "clock")
                                        Text(routine.time[i], style: .time)
                                            .padding(.leading, -4)
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: routine.isDone[i] ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40)
                                    .foregroundStyle(.white, routine.isDone[i] ? Color("secondary-green") : Color("emergency-pink"))
                            }
                            .padding()
                            .background(colorScheme == .light ? .white : Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .frame(width: Screen.width - 32)
                        }
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

