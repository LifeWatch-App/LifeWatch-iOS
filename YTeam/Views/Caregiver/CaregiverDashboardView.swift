//
//  CaregiverEmergencyView.swift
//  YTeam
//
//  Created by Yap Justin on 18/10/23.
//

import SwiftUI
import Shimmer
import SkeletonUI

struct CaregiverDashboardView: View {
    @Environment(\.colorScheme) var colorScheme

    @AppStorage("inviteModal") var inviteModal = true

    @StateObject var caregiverDashboardViewModel: CaregiverDashboardViewModel = CaregiverDashboardViewModel()
    @State var showChangeSenior = false
    @State var showInviteSheet = false
    @State var searchTest = ""

    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {
                    VStack {
                        ScrollView {
                            VStack(spacing: 20) {
                                SeniorStatus(caregiverDashboardViewModel: caregiverDashboardViewModel)
                                    .padding(.horizontal)

                                UpcomingRoutines(caregiverDashboardViewModel: caregiverDashboardViewModel)

                                ZStack(alignment: .topLeading) {
                                    MapPreview(caregiverDashboardViewModel: caregiverDashboardViewModel)

                                    if let locationInfo = caregiverDashboardViewModel.latestLocationInfo, !caregiverDashboardViewModel.isLoading {
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
                                if !caregiverDashboardViewModel.isLoading {
                                    Text("\(caregiverDashboardViewModel.speakerName)...")
                                        .font(.subheadline)
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(.accent)
                                        .padding(.horizontal)
                                        .padding(.top, 8)
                                }
                            }
                        } else {
                            if !caregiverDashboardViewModel.isLoading {
                                Text("You are not in a channel\n(you won't receive incoming transmissions)")
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(Color("emergency-pink"))
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                            }
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
                            .skeleton(with: caregiverDashboardViewModel.isLoading,
                                      size: CGSize(width: UIScreen.main.bounds.width - 30, height: 50),
                                      animation: .linear(),
                                      appearance: .gradient(),
                                      shape: ShapeType.rounded(.radius(10, style: .circular)))
                            .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false))
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                        }
                    }
                    .background(colorScheme == .light ? Color(.systemGroupedBackground): .black)
                    .navigationTitle("Tracker")
                    .onChange(of: caregiverDashboardViewModel.falls) { oldValue, newValue in

                    }
                    .fullScreenCover(isPresented: $caregiverDashboardViewModel.showWalkieTalkie, content: {
                        WalkieTalkieView()
                    })
                    .fullScreenCover(isPresented: $inviteModal) {
                        OnBoardingInviteView(caregiverDashboardViewModel: caregiverDashboardViewModel)
                    }
                    //                .background(colorScheme == .light ? Color(.systemGroupedBackground) : .black)
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
                                    if !caregiverDashboardViewModel.isLoading {
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
                    .sheet(isPresented: $caregiverDashboardViewModel.showDisclaimerSheet) {
                        DisclaimerView()
                    }

                }
            }

            ChangeSeniorOverlay(showInviteSheet: $showInviteSheet, showChangeSenior: $showChangeSenior)
                .environmentObject(caregiverDashboardViewModel)

        }
        .transition(.opacity)
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
                    .skeleton(with: caregiverDashboardViewModel.isLoading,
                              size: CGSize(width: 50, height: 50),
                              animation: .linear(),
                              appearance: .gradient(.radial),
                              shape: ShapeType.circle)
                    .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                    .frame(width: 50)

                VStack(alignment: .leading) {
                    HStack {
                        Text(caregiverDashboardViewModel.falls.count > 0 ? "Fall Detection Triggered" : caregiverDashboardViewModel.sos.count > 0 ? "SOS Button Triggered" : caregiverDashboardViewModel.latestSymptomInfo == nil ? "No Alerts" : "Symptoms Reported")
                            .font(.headline)
                            .foregroundStyle(caregiverDashboardViewModel.falls.count > 0 || caregiverDashboardViewModel.sos.count > 0 ? Color("emergency-pink") : Color(.label))

                        Image(systemName: caregiverDashboardViewModel.latestSymptomInfo == nil && caregiverDashboardViewModel.falls.count == 0 && caregiverDashboardViewModel.sos.count == 0 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(.white, Color(caregiverDashboardViewModel.latestSymptomInfo == nil && caregiverDashboardViewModel.falls.count == 0 && caregiverDashboardViewModel.sos.count == 0 ? "secondary-green" : "emergency-pink"))
                            .font(.subheadline)
                    }


                    Text(caregiverDashboardViewModel.falls.count > 0 || caregiverDashboardViewModel.sos.count > 0 ? "Please contact your senior or find help immediately!" : caregiverDashboardViewModel.latestSymptomInfo == nil ? "No symptoms reported" : "\(caregiverDashboardViewModel.invites.first(where: { $0.seniorId == caregiverDashboardViewModel.selectedInviteId })?.seniorData?.name ?? "Subroto") experienced \(caregiverDashboardViewModel.latestSymptomInfo?.name?.lowercased() ?? "none") lately")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    //                        .skeleton(with: caregiverDashboardViewModel.isLoading,
                    ////                                  appearance: .gradient(),
                    //                                  shape: ShapeType.rounded(.radius(10, style: .circular)))
                }
                .skeleton(with: caregiverDashboardViewModel.isLoading,
                          animation: .linear(), appearance: .gradient(),
                          shape: ShapeType.rounded(.radius(5, style: .circular)), lines: 2,
                          scales: [0: 0.5, 1: 0.9])
                .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))

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
                        .skeleton(with: caregiverDashboardViewModel.isLoading,
                                  size: CGSize(width: 50, height: 50), animation: .linear(),
                                  appearance: .gradient(),
                                  shape: ShapeType.rounded(.radius(5, style: .circular)))
                        .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                        VStack(alignment: .leading) {
                            Text("Heart Rate")
                                .font(.caption)

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
                        .skeleton(with: caregiverDashboardViewModel.isLoading,
                                  animation: .linear(), appearance: .gradient(),
                                  shape: ShapeType.rounded(.radius(5, style: .circular)), lines: 2,
                                  scales: [0: 1, 1: 1])
                        .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))

                        Spacer()
                    }
                }
                .padding(12)
                .background(colorScheme == .light ? .white : Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading) {
                    HStack {
                        VStack {
                            Image(systemName: "applewatch.radiowaves.left.and.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundStyle(.white)
                                .font(.system(size: 60))
                        }
                        .padding(8)
                        .background(.blue)
                        .skeleton(with: caregiverDashboardViewModel.isLoading,
                                  size: CGSize(width: 50, height: 50),
                                  animation: .linear(),
                                  appearance: .gradient(),
                                  shape: ShapeType.rounded(.radius(5, style: .circular)))
                        .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                        if caregiverDashboardViewModel.idleInfo.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Inactivity")
                                    .font(.subheadline)
                                    .skeleton(with: caregiverDashboardViewModel.isLoading,
                                              animation: .linear(),
                                              appearance: .gradient(),
                                              shape: ShapeType.rounded(.radius(5, style: .circular)))
                                    .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))

                                Text("Active")
                                    .font(.title2)
                                    .bold()
                                    .skeleton(with: caregiverDashboardViewModel.isLoading,
                                              animation: .linear(),
                                              appearance: .gradient(),
                                              shape: ShapeType.rounded(.radius(5, style: .circular)))
                                    .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false))
                            }
                            .skeleton(with: caregiverDashboardViewModel.isLoading,
                                      animation: .linear(), appearance: .gradient(),
                                      shape: ShapeType.rounded(.radius(5, style: .circular)), lines: 2,
                                      scales: [0: 1, 1: 1])
                            .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))

                        } else {
                            if (caregiverDashboardViewModel.idleInfo.first(where: { $0.taskState == "ongoing" }) != nil) {
                                VStack(alignment: .leading) {
                                    Text("Stationary For")
                                        .font(.caption)
                                        .skeleton(with: caregiverDashboardViewModel.isLoading,
                                                  animation: .linear(),
                                                  appearance: .gradient(),
                                                  shape: ShapeType.rounded(.radius(5, style: .circular)))
                                        .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))

                                    HStack {
                                        Text(Date.timeDifference(unix: caregiverDashboardViewModel.idleInfo.first(where: { $0.taskState == "ongoing" })?.startTime ?? 0).timeString)
                                            .font(.title2)
                                            .bold()

                                        Text(Date.timeDifference(unix: caregiverDashboardViewModel.idleInfo.first(where: { $0.taskState == "ongoing" })?.startTime ?? 0).timeUnits)
                                            .foregroundStyle(.secondary)
                                            .font(.subheadline)
                                            .padding(.leading, -4)
                                    }


                                }
                                .skeleton(with: caregiverDashboardViewModel.isLoading,
                                          animation: .linear(), appearance: .gradient(),
                                          shape: ShapeType.rounded(.radius(5, style: .circular)), lines: 2,
                                          scales: [0: 1, 1: 1])
                                .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                            } else {
                                VStack(alignment: .leading) {
                                    Text("Watch Activity")
                                        .font(.caption)


                                    Text("In Motion")
                                        .font(.title3)
                                        .bold()
                                }
                                .skeleton(with: caregiverDashboardViewModel.isLoading,
                                          animation: .linear(), appearance: .gradient(),
                                          shape: ShapeType.rounded(.radius(5, style: .circular)), lines: 2,
                                          scales: [0: 1, 1: 1])
                                .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
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
                    .skeleton(with: caregiverDashboardViewModel.isLoading,
                              size: CGSize(width: 50, height: 50), animation: .linear(),
                              appearance: .gradient(),
                              shape: ShapeType.rounded(.radius(5, style: .circular)))
                    .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
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
                    .skeleton(with: caregiverDashboardViewModel.isLoading,
                              animation: .linear(), appearance: .gradient(),
                              shape: ShapeType.rounded(.radius(5, style: .circular)), lines: 2,
                              scales: [0: 1, 1: 1])
                    .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))

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
                    .skeleton(with: caregiverDashboardViewModel.isLoading,
                              size: CGSize(width: 50, height: 50),
                              animation: .linear(),
                              appearance: .gradient(),
                              shape: ShapeType.rounded(.radius(5, style: .circular)))
                    .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))

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
                    .skeleton(with: caregiverDashboardViewModel.isLoading,
                              animation: .linear(), appearance: .gradient(),
                              shape: ShapeType.rounded(.radius(5, style: .circular)), lines: 2,
                              scales: [0: 1, 1: 1])
                    .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))

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

                if !caregiverDashboardViewModel.isLoading {
                    NavigationLink {
                        CaregiverAllRoutineView(caregiverDashboardViewModel: caregiverDashboardViewModel)
                    } label: {
                        Text("See All")
                            .font(.headline)
                    }
                }
            }
            .padding(.horizontal)

            if !caregiverDashboardViewModel.isLoading {
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
                                            .foregroundStyle(.secondary)
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
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top) {
                        ForEach(routinesDummyDataSkeleton) { routine in
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
                                    .skeleton(with: caregiverDashboardViewModel.isLoading,
                                              size: CGSize(width: 60, height: 60),
                                              animation: .linear(),
                                              appearance: .gradient(),
                                              shape: ShapeType.rounded(.radius(8, style: .circular)))
                                    .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))

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
                                        .foregroundStyle(.secondary)
                                    }
                                    .skeleton(with: caregiverDashboardViewModel.isLoading,
                                              animation: .linear(), appearance: .gradient(),
                                              shape: ShapeType.rounded(.radius(5, style: .circular)), lines: 3,
                                              scales: [0: 1, 1: 0.8, 2: 0.4], spacing: 10)
                                    .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))

                                    Spacer()

                                    Image(systemName: routine.isDone[i] ? "checkmark.circle.fill" : "minus.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40)
                                        .skeleton(with: caregiverDashboardViewModel.isLoading,
                                                  size: CGSize(width: 40, height: 40),
                                                  animation: .linear(),
                                                  appearance: .gradient(.radial),
                                                  shape: ShapeType.circle)
                                        .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
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
                .scrollDisabled(true)
                .scrollTargetBehavior(.viewAligned)
            }
        }
    }
}

struct MapPreview: View {
    @Environment(\.colorScheme) var colorScheme

    @StateObject var mapVM = MapViewModel()
    @ObservedObject var caregiverDashboardViewModel: CaregiverDashboardViewModel

    var body: some View {
        VStack {
            HStack {
                Text("Senior's Location")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()

                if !caregiverDashboardViewModel.isLoading {
                    NavigationLink {
                        MapTestView(mapVM: mapVM)
                    } label: {
                        Text("Details")
                            .font(.headline)
                    }
                }
            }
            .padding(.horizontal)

            VStack {
                if mapVM.lastSeenLocation != nil && mapVM.mapRegion != nil && !caregiverDashboardViewModel.isLoading {
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
                    .skeleton(with: caregiverDashboardViewModel.isLoading,
                              size: CGSize(width: UIScreen.main.bounds.width - 70, height: 50),
                              animation: .linear(), appearance: .gradient(),
                              shape: ShapeType.rounded(.radius(5, style: .circular)))
                    .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
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
                    .skeleton(with: caregiverDashboardViewModel.isLoading,
                              size: CGSize(width: UIScreen.main.bounds.width - 70, height: 50),
                              animation: .linear(), appearance: .gradient(),
                              shape: ShapeType.rounded(.radius(5, style: .circular)))
                    .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                    .padding()
                    .background(colorScheme == .light ? .white : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal)
                }
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
                if caregiverDashboardViewModel.isLoading {
                    Image("Robot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                        .skeleton(with: caregiverDashboardViewModel.isLoading,
                                  size: CGSize(width: 24, height: 24),
                                  animation: .linear(),
                                  appearance: .gradient(.radial),
                                  shape: ShapeType.circle)
                        .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                        .padding(5)
                        .background(colorScheme == .light ? .white : Color(.systemGray6))
                        .clipShape(Circle())
                } else {
                    Image("Robot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                }

                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(caregiverDashboardViewModel.analysis != "" && !caregiverDashboardViewModel.isLoadingAnalysis ? caregiverDashboardViewModel.analysis : caregiverDashboardViewModel.isLoadingAnalysis ? "Analyzing..." : "Hi, I'm an AI medical counselor here to assist you in assessing the health of your senior. Because of the missing data, I am unable to assess it at this time. In order for us to assist you with the analysis, kindly add a senior and ensure that they are wearing their watch.")
                            .font(.callout)

                        if !caregiverDashboardViewModel.isLoadingAnalysis && !caregiverDashboardViewModel.isLoading {
                            Text(caregiverDashboardViewModel.extractDate(date: caregiverDashboardViewModel.analysisDate, format: "dd MMM yyyy HH:mm:ss"))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Divider()

                        Group {
                            Text("This medical AI is intended solely for educational purposes and should not be used as a substitute for professional medical advice.")

                            Button("Click here for more information") {
                                if !caregiverDashboardViewModel.isLoading {
                                    caregiverDashboardViewModel.showDisclaimerSheet.toggle()
                                }
                            }
                            .foregroundStyle(.accent)
                        }
                        .font(.caption)
                    }
                    .skeleton(with: caregiverDashboardViewModel.isLoading,
                              animation: .linear(), appearance: .gradient(),
                              shape: ShapeType.rounded(.radius(5, style: .circular)), lines: 4,
                              scales: [0: 0.5, 1: 1, 2: 0.8, 3: 0.6 ], spacing: 15)
                    .shimmering(active: caregiverDashboardViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))



                    Spacer()
                }
                .padding(12)
                .background(colorScheme == .light ? .white : Color(.systemGray6))
                .clipShape(ChatBubbleTopLeft())
            }
        }
        .padding(.horizontal)
        .onChange(of: caregiverDashboardViewModel.selectedInviteId) { oldValue, newValue in
            caregiverDashboardViewModel.checkAnalysis()
        }
    }
}

#Preview {
    CaregiverDashboardView()
    //        .preferredColorScheme(.dark)
}

