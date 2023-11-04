//
//  CaregiverEmergencyView.swift
//  YTeam
//
//  Created by Yap Justin on 18/10/23.
//

import SwiftUI

struct CaregiverDashboardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var batteryLevel: Double = 86
    @State var walkieTalkieToggle: Bool = false
    @State var locationToggle: Bool = false
    @StateObject var caregiverDashboardViewModel = CaregiverDashboardViewModel()
    @State var email = ""
    @State var showChangeSenior = false
    
    var body: some View {
        NavigationStack {
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
                    
                    
                }
            }
            .background(Color(.systemGroupedBackground))
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
                                                    .foregroundStyle(.white, .green)
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

//struct CaregiverSOSButton: View {
//    var body: some View {
//        Text("Press button to talk")
//            .font(.system(size: 18))
//        Button {
//            // SOS
//        } label: {
//            ZStack {
//                Circle()
//                    .stroke(.blue)
//                    .frame(width: Screen.width * 0.9)
//                Circle()
//                    .tint(.blue)
//                    .frame(width: Screen.width * 0.8, height: Screen.width * 0.8)
//                Image(systemName: "mic.fill")
//                    .resizable()
//                    .tint(.white)
//                    .frame(width: Screen.width * 0.25 * 1.17730, height: Screen.width * 0.45)
//            }
//        }
//    }
//}
//
//struct CaregiverWTLocationCard: View {
//    @Binding var walkieTalkieToggle: Bool
//    @Binding var locationToggle: Bool
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            HStack{
//                ZStack {
//                    RoundedRectangle(cornerRadius: 5)
//                        .foregroundStyle(.blue)
//                        .frame(width: 38, height: 38)
//                    Image(systemName: "flipphone")
//                        .font(.system(size: 18))
//                        .foregroundStyle(.white)
//                }
//                Toggle(isOn: $walkieTalkieToggle, label: {
//                    Text("Walkie Talkie")
//                        .font(.system(size: 18))
//                })
//            }
//            .padding()
//            Divider()
//                .background(.primary)
//                .padding(.leading, 48)
//                
//            HStack{
//                ZStack {
//                    RoundedRectangle(cornerRadius: 5)
//                        .foregroundStyle(.blue)
//                        .frame(width: 38, height: 38)
//                    Image(systemName: "location.fill")
//                        .font(.system(size: 18))
//                        .foregroundStyle(.white)
//                }
//                Toggle(isOn: $locationToggle, label: {
//                    Text("Location")
//                        .font(.system(size: 18))
//                })
//            }
//            .padding()
//        }
//        
//        .background(.white)
//        .clipShape(RoundedRectangle(cornerRadius: 8.0))
//        .padding(.horizontal)
//    }
//}
//
//struct CaregiverChargingCard: View {
//    @Binding var batteryLevel: Double
//    
//    var body: some View {
//        HStack {
//            ZStack {
//                RoundedRectangle(cornerRadius: 5)
//                    .foregroundStyle(.blue)
//                    .frame(width: 38, height: 38)
//                Image(systemName: "applewatch")
//                    .font(.system(size: 18))
//                    .foregroundStyle(.white)
//            }
//            VStack(alignment: .leading) {
//                Text("Watch Battery")
//                    .font(.system(size: 18))
//                Text("Charging")
//                    .font(.system(size: 14))
//                    .foregroundStyle(.secondary)
//            }
//            Spacer()
//            ZStack{
//                CircularProgressView(progress: batteryLevel / 100)
//                Text("\(batteryLevel, specifier: "%.0f")")
//                    .bold()
//            }
//                .frame(width: Screen.width * 0.15)
//        }
//        .padding()
//        .background(.white)
//        .clipShape(RoundedRectangle(cornerRadius: 8.0))
//        .padding(.horizontal)
//        .padding(.top, 16)
//    }
//}
//
//struct CaregiverCircularProgressView: View {
//    let progress: Double
//    
//    var body: some View {
//        ZStack {
//            Circle()
//                .stroke(
//                    Color(UIColor.systemGray5),
//                    lineWidth: 8
//                )
//            Circle()
//                .trim(from: 0, to: progress)
//                .stroke(
//                    Color(progress > 0.25 && progress < 0.50 ? .orange : progress > 0.50 ? .blue : .red),
//                    style: StrokeStyle(
//                        lineWidth: 8,
//                        lineCap: .round
//                    )
//                )
//                .rotationEffect(.degrees(-90))
//                .animation(.easeOut(duration: 0.75), value: progress)
//        }
//    }
//}

#Preview {
    CaregiverDashboardView()
}

