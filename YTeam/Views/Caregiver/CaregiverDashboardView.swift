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
        NavigationStack {
            VStack {
                ScrollView {
                    VStack{
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
                        
                        UpcomingRoutines(caregiverDashboardViewModel: caregiverDashboardViewModel)
                    }
                    .padding(.horizontal)
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
                    .overlay(alignment: .topLeading) {
                        if showChangeSenior {
                            VStack {
                                HStack {
                                    Text("Senior:")
                                        .font(.headline)
                                    Spacer()
                                }
//                                ScrollView(.horizontal) {
                                HStack(spacing: 16) {
                                        // Foreach seniornya
                                        VStack {
                                            ZStack {
                                                ZStack {
                                                    Circle()
                                                        .fill(.secondary.opacity(0.5))
                                                    Text("S")
                                                        .font(.title)
                                                        .bold()
                                                        .frame(width: 30, height: 30, alignment: .center)
                                                    .padding()
                                                }
                                            }
                                            
                                            Text("Subroto")
                                                .font(.callout)
                                        }
                                    
                                        VStack {
                                            ZStack(alignment: .bottomTrailing) {
                                                ZStack {
                                                    Circle()
                                                        .fill(.secondary.opacity(0.5))
                                                    Text("S")
                                                        .font(.title)
                                                        .bold()
                                                        .frame(width: 30, height: 30, alignment: .center)
                                                    .padding()
                                                }
                                                
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundStyle(.white, Color("secondary-green"))
                                            }
                                            
                                            Text("Subroto")
                                                .font(.callout)
                                        }
                                    
                                        VStack {
                                            ZStack {
                                                Circle()
                                                    .fill(.accent)
                                                Image(systemName: "plus")
                                                    .foregroundStyle(.white)
                                                    .font(.title3)
                                                    .bold()
                                                    .frame(width: 30, height: 30, alignment: .center)
                                                .padding()
                                            }
                                            
                                            Text("Add")
                                                .font(.callout)
                                        }
                                    }
//                                }
                            }
                            .padding()
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.top, 32)
                        }
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
                            Image(systemName: "moon.fill")
                                .foregroundStyle(.white)
                        }
                        .padding(8)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Spacer()
                    }
                    
                    Text("Inactive for")
                        .font(.subheadline)
                    
                    HStack {
                        Text("\(caregiverDashboardViewModel.inactive)")
                            .font(.title)
                            .bold()
                        
                        Text("min")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                            .padding(.leading, -4)
                    }
                }
                .padding(12)
                .background(colorScheme == .light ? .white : Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    ZStack {
                        CircularProgressView(progress: caregiverDashboardViewModel.watchBattery / 100)
                            .frame(width: 50)
                        
                        Image(systemName: "applewatch")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14)
                            .foregroundStyle(.accent, .white)
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
                        CircularProgressView(progress: caregiverDashboardViewModel.phoneBattery / 100)
                            .frame(width: 50)
                        
                        Image(systemName: "iphone")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14)
                            .foregroundStyle(.accent, .white)
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
        .padding(.vertical)
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
                    Text("Obat")
                        .font(.headline)
                    Text("2 Tablet")
                    HStack {
                        Image(systemName: "clock")
                        Text("13.00")
                            .padding(.leading, -4)
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .foregroundStyle(Color("secondary-green"))
            }
            .padding()
            .background(colorScheme == .light ? .white : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    CaregiverDashboardView()
//        .preferredColorScheme(.dark)
}

