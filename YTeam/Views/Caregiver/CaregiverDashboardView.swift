//
//  CaregiverEmergencyView.swift
//  YTeam
//
//  Created by Yap Justin on 18/10/23.
//

import SwiftUI

struct CaregiverDashboardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("inviteModal") var inviteModal = true
    
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
                            
                            ZStack(alignment: .topLeading) {
                                MapPreview()

                                if let locationInfo = caregiverDashboardViewModel.latestLocationInfo {
                                    Text(locationInfo.isOutside ?? false ? "Outside" : "Home")
                                        .fontWeight(.bold)
                                        .padding(.top, 40)
                                        .padding(.leading, 25)
                                }
                            }
                            
                            AnalysisResult(caregiverDashboardViewModel: caregiverDashboardViewModel)
                        }
                    }

                    if caregiverDashboardViewModel.isJoined {
                        if caregiverDashboardViewModel.isPlaying {
                            Text("\(caregiverDashboardViewModel.speakerName)...")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.accent)
                                .padding(.horizontal)
                                .padding(.top, 8)
                        }
                    } else {
                        Text("You are not in a channel\n(you won't receive incoming transmissions)")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }
                    Button {
                        caregiverDashboardViewModel.showWalkieTalkie.toggle()
                    } label: {
                        HStack {
                            Spacer()

                            Image(systemName: "flipphone")
                            Text("Walkie-Talkie")

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
                .fullScreenCover(isPresented: $caregiverDashboardViewModel.showWalkieTalkie, content: {
                    WalkieTalkieView()
                })
                .background(colorScheme == .light ? Color(.systemGroupedBackground) : .black)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            if caregiverDashboardViewModel.invites.isEmpty {
                                showInviteSheet.toggle()
                            } else {
                                showChangeSenior.toggle()
                            }
                        } label: {
                            HStack {
                                if caregiverDashboardViewModel.invites.isEmpty {
                                    Text("Add a senior")
                                } else if caregiverDashboardViewModel.invites.contains(where: { $0.accepted == true }) {
                                    Text(caregiverDashboardViewModel.invites.first(where: { $0.seniorId == caregiverDashboardViewModel.selectedInviteId })?.seniorData?.name ?? "Subroto")
                                    
                                    Image(systemName: showChangeSenior ? "chevron.up" : "chevron.down")
                                        .font(.subheadline)
                                        .padding(.leading, -2)
                                } else {
                                    Text("Add a senior")
                                }
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
                .navigationTitle("Tracker")
                .onChange(of: caregiverDashboardViewModel.falls) { oldValue, newValue in
                    
                }
            }

            ChangeSeniorOverlay(showInviteSheet: $showInviteSheet, showChangeSenior: $showChangeSenior)
                .environmentObject(caregiverDashboardViewModel)
        }
        .fullScreenCover(isPresented: $inviteModal) {
            OnBoardingInviteView(caregiverDashboardViewModel: caregiverDashboardViewModel)
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
                Image(caregiverDashboardViewModel.falls.count > 0 || caregiverDashboardViewModel.sos.count > 0 ? "danger" : caregiverDashboardViewModel.latestSymptomInfo == nil ? "safe" : caregiverDashboardViewModel.latestSymptomInfo?.name ?? "Unknown")
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(100)
                    .frame(width: 50)

                VStack(alignment: .leading) {
                    HStack {
                        Text(caregiverDashboardViewModel.falls.count > 0 ? "Fall Detection Triggered" : caregiverDashboardViewModel.sos.count > 0 ? "SOS Button Triggered" : caregiverDashboardViewModel.latestSymptomInfo == nil ? "Safe Condition" : "Symptoms Detected")
                            .font(.headline)
                            .foregroundStyle(caregiverDashboardViewModel.falls.count > 0 || caregiverDashboardViewModel.sos.count > 0 ? Color("emergency-pink") : Color(.label))
                        Image(systemName: caregiverDashboardViewModel.latestSymptomInfo == nil && caregiverDashboardViewModel.falls.count == 0 && caregiverDashboardViewModel.sos.count == 0 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(.white, Color(caregiverDashboardViewModel.latestSymptomInfo == nil && caregiverDashboardViewModel.falls.count == 0 && caregiverDashboardViewModel.sos.count == 0 ? "secondary-green" : "emergency-pink"))
                            .font(.subheadline)
                    }

                    Text(caregiverDashboardViewModel.falls.count > 0 || caregiverDashboardViewModel.sos.count > 0 ? "Please contact your senior or find help immediately!" : caregiverDashboardViewModel.latestSymptomInfo == nil ? "No symptoms detected" : "\(caregiverDashboardViewModel.invites.first(where: { $0.seniorId == caregiverDashboardViewModel.selectedInviteId })?.seniorData?.name ?? "Subroto") experienced \(caregiverDashboardViewModel.latestSymptomInfo?.name?.lowercased() ?? "none") lately")
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
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.white)
                        }
                        .padding(12)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        VStack(alignment: .leading) {
                            Text("Heart Rate")
                                .font(.subheadline)
                            
                            HStack {
                                Text("\(Int(caregiverDashboardViewModel.heartBeatInfo?.bpm ?? 0))")
                                    .font(.title2)
                                    .bold()
                                
                                Text("bpm")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                                    .padding(.leading, -4)
                            }
                        }

                        Spacer()
                    }
                }
                .padding(12)
                .background(colorScheme == .light ? .white : Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading) {
                    HStack {
                        VStack {
                            Image(systemName: (caregiverDashboardViewModel.idleInfo.first(where: { $0.taskState == "ongoing" }) != nil) ? "figure.walk" : "moon.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.white)
                                .padding(.horizontal, (caregiverDashboardViewModel.idleInfo.first(where: { $0.taskState == "ongoing" }) != nil) ? 2 : 0)
                        }
                        .padding(12)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        if caregiverDashboardViewModel.idleInfo.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Inactivity")
                                    .font(.subheadline)

                                Text("Active")
                                    .font(.title2)
                                    .bold()
                            }

                        } else {
                            if (caregiverDashboardViewModel.idleInfo.first(where: { $0.taskState == "ongoing" }) != nil) {
                                VStack(alignment: .leading) {
                                    Text("Inactive for")
                                        .font(.subheadline)

                                    HStack {
                                        Text(Date.timeDifference(unix: caregiverDashboardViewModel.idleInfo.first(where: { $0.taskState == "ongoing" })?.startTime ?? 0).timeString)
                                            .font(.title2)
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
                                }
                            } else {
                                VStack(alignment: .leading) {
                                    Text("Currently")
                                        .font(.subheadline)

                                    Text("Active")
                                        .font(.title2)
                                        .bold()
                                }
                            }
                        }

                        Spacer()
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
                        .animation(.easeInOut, value: caregiverDashboardViewModel.batteryInfo)
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
                        Text("Phone Battery")
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
                Text("Senior's Routine")
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
            
            if caregiverDashboardViewModel.routines.count > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top) {
                        ForEach(caregiverDashboardViewModel.routines) { routine in
                            ForEach(routine.time.indices, id: \.self) { i in
                                HStack(alignment: .center, spacing: 16) {
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
                                        
                                        if routine.type == "Medicine" {
                                            if (routine.medicineAmount != "") {
                                                Text("\(routine.medicineAmount ?? "") \(routine.medicineUnit?.rawValue ?? "")")
                                                    .font(.subheadline)
                                            }
                                        } else {
                                            if (routine.description != "") {
                                                Text(routine.description ?? "")
                                                    .font(.subheadline)
                                            }
                                        }

                                        HStack {
                                            Image(systemName: "clock")
                                            Text(routine.time[i], style: .time)
                                                .padding(.leading, -4)
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: routine.isDone[i] ? "checkmark.circle.fill" : "minus.circle.fill")
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
            } else {
                HStack {
                    Spacer()
                    
                    Text("Routines not Set.")
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .padding()
                .background(colorScheme == .light ? .white : Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
            }
        }
    }
}

struct MapPreview: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var mapVM = MapViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Text("Senior's Location")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                NavigationLink {
                    MapTestView(mapVM: mapVM)
                } label: {
                    Text("Details")
                        .font(.headline)
                }
            }
            .padding(.horizontal)
            
            if mapVM.lastSeenLocation != nil && mapVM.mapRegion != nil {
                MKMapRep(mapVM: mapVM)
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal)
            } else if mapVM.mapRegion == nil {
                HStack {
                    Spacer()
                    
                    VStack {
                        Text("Home Location not Available")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        Text("Ask your senior to set their home location.")
                            .font(.subheadline)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(colorScheme == .light ? .white : Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
            } else {
                HStack {
                    Spacer()
                    
                    VStack {
                        Text("Location not Available")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        Text("Ask your senior to turn on their location.")
                            .font(.subheadline)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(colorScheme == .light ? .white : Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
            }
        }
    }
}

struct AnalysisResult: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var caregiverDashboardViewModel: CaregiverDashboardViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("AI Analysis Result")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            
            HStack(alignment: .top) {
                Image("Robot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24)
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(caregiverDashboardViewModel.analysis != "" && !caregiverDashboardViewModel.isLoadingAnalysis ? caregiverDashboardViewModel.analysis : caregiverDashboardViewModel.isLoadingAnalysis ? "Analyzing..." : "Hi, I'm an AI medical counselor here to assist you in assessing the health of your senior. Because of the missing data, I am unable to assess it at this time. In order for us to assist you with the analysis, kindly add a senior and ensure that they are wearing their watch.")
                            .font(.callout)
                        
                        if !caregiverDashboardViewModel.isLoadingAnalysis {
                            Text(caregiverDashboardViewModel.extractDate(date: caregiverDashboardViewModel.analysisDate, format: "dd MMM yyyy HH:mm:ss"))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(12)
                .background(colorScheme == .light ? .white : Color(.systemGray6))
                .clipShape(ChatBubbleTopLeft())
            }
        }
        .padding(.horizontal)
        .onChange(of: caregiverDashboardViewModel.selectedInviteId) { oldValue, newValue in
//            caregiverDashboardViewModel.checkAnalysis()
        }
    }
}

#Preview {
    CaregiverDashboardView()
    //        .preferredColorScheme(.dark)
}

