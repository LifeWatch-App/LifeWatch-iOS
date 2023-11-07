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
                            Image(systemName: caregiverDashboardViewModel.isActive ? "figure.walk" : "moon.fill")
                                .foregroundStyle(.white)
                                .padding(.horizontal, caregiverDashboardViewModel.isActive ? 2 : 0)
                        }
                        .padding(8)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Spacer()
                    }
                    
                    if caregiverDashboardViewModel.isActive {
                        Text("Currently")
                            .font(.subheadline)
                        
                        Text("Active")
                            .font(.title2)
                            .bold()
                            .padding(.bottom, 6)
                    } else {
                        Text("Inactive for")
                            .font(.subheadline)
                        
                        HStack {
                            Text("\(caregiverDashboardViewModel.inactivityTime)")
                                .font(.title)
                                .bold()
                            
                            Text("min")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                                .padding(.leading, -4)
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
                        BatteryCircularProgressView(progress: caregiverDashboardViewModel.watchBattery / 100, charging: caregiverDashboardViewModel.watchIsCharging)
                            .frame(width: 50)
                        
                        
                        Image(systemName: "applewatch")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14)
                            .foregroundStyle(caregiverDashboardViewModel.watchIsCharging ? Color("secondary-orange") : .accent, .white)
                    }
                    .padding(.horizontal, 4)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Watch Battery")
                            .font(.caption)
                        
                        HStack {
                            if caregiverDashboardViewModel.watchIsCharging {
                                Image(systemName: "bolt.fill")
                                    .foregroundStyle(Color("secondary-orange"))
                            }
                            
                            Text("\(caregiverDashboardViewModel.watchBattery, specifier: "%.0f")%")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.leading, caregiverDashboardViewModel.watchIsCharging ? -4 : 0)
                        }
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
                        BatteryCircularProgressView(progress: caregiverDashboardViewModel.phoneBattery / 100, charging: caregiverDashboardViewModel.phoneIsCharging)
                            .frame(width: 50)
                        
                        Image(systemName: "iphone")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14)
                            .foregroundStyle(caregiverDashboardViewModel.phoneIsCharging ? Color("secondary-orange") : .accent, .white)
                    }
                    .padding(.horizontal, 4)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("iPhone Battery")
                            .font(.caption)
                        
                        HStack {
                            if caregiverDashboardViewModel.phoneIsCharging {
                                Image(systemName: "bolt.fill")
                                    .foregroundStyle(Color("secondary-orange"))
                            }
                            
                            Text("\(caregiverDashboardViewModel.phoneBattery, specifier: "%.0f")%")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.leading, caregiverDashboardViewModel.phoneIsCharging ? -4 : 0)
                        }
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

