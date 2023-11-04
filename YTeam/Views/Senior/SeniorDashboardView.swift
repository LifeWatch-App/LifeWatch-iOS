//
//  SeniorEmergencyView.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 18/10/23.
//

import SwiftUI

struct SeniorDashboardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var seniorDashboardViewModel = SeniorDashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack{
//                    VStack {
//                        Text("Welcome, \(seniorDashboardViewModel.user?.email ?? "")!")
//                        Text("Give your email to your caregivers")
//                        ForEach(seniorDashboardViewModel.invites, id: \.id) { invite in
//                            HStack {
//                                Text("Invite from: \(invite.caregiverData!.email!)")
//                                Text(invite.accepted! ? "(Accepted)" : "")
//                                if (!invite.accepted!) {
//                                    Button {
//                                        seniorDashboardViewModel.acceptInvite(id: invite.id!)
//                                    } label: {
//                                        Text("Accept")
//                                    }
//                                }
//                            }
//                            .padding(.top, 4)
//                        }
//                    }
                    
                    ButtonCards(seniorDashboardViewModel: seniorDashboardViewModel)
                    
                    UpcomingActivity(seniorDashboardViewModel: seniorDashboardViewModel)
                    
                    Symtomps(seniorDashboardViewModel: seniorDashboardViewModel)
                }
                .padding(.horizontal)
            }
            .background(colorScheme == .light ? Color(.systemGroupedBackground) : .black)
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
            .navigationTitle("Dashboard")
        }
    }
}

struct ButtonCards: View {
    @ObservedObject var seniorDashboardViewModel: SeniorDashboardViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            Button{
                
            } label: {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text("SOS\nButton")
                            .multilineTextAlignment(.leading)
                            .font(.title)
                            .bold()
                        
                        Spacer()
                        
                        Image(systemName: "light.beacon.max.fill")
                            .font(.title2)
                    }
                    
                    Text("Alerting Family Member")
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .background(Color("emergency-pink"))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            Button {
                
            } label: {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text("Walkie\nTalkie")
                            .multilineTextAlignment(.leading)
                            .font(.title)
                            .bold()
                        
                        Spacer()
                        
                        Image(systemName: "flipphone")
                            .font(.title2)
                    }
                    
                    Text("Talk to Family Member")
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .background(.accent)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .foregroundStyle(.white)
    }
}

struct UpcomingActivity: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var seniorDashboardViewModel: SeniorDashboardViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Upcoming Routine")
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
            
            VStack(spacing: 20) {
                ForEach(seniorDashboardViewModel.routines.prefix(3)) { routine in
                    HStack {
                        Divider()
                            .frame(minWidth: 4)
                            .background(.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 100))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(routine.name)
                                .font(.title3)
                                .fontWeight(.semibold)
                            HStack {
                                Image(systemName: "clock")
                                Text(routine.time, style: .time)
                                    .padding(.leading, -4)
                            }
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "circle")
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(.accent)
                    }
                }
            }
            .padding()
            .background(colorScheme == .light ? .white : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.vertical)
    }
}

struct Symtomps: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var seniorDashboardViewModel: SeniorDashboardViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Symptoms")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    
                } label: {
                    Image(systemName: "plus")
                        .font(.title3)
                        .bold()
                }
            }
            
            ForEach(seniorDashboardViewModel.symptoms) { symptom in
                HStack(spacing: 16) {
                    Image("symtomps")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(symptom.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                        HStack {
                            Image(systemName: "clock")
                            Text(symptom.time, style: .time)
                                .padding(.leading, -4)
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(colorScheme == .light ? .white : Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview {
    SeniorDashboardView()
        .preferredColorScheme(.dark)
}


//struct SOSButton: View {
//    @ObservedObject var seniorDashboardViewModel: SeniorDashboardViewModel = SeniorDashboardViewModel()
//    @ObservedObject var audioManager: AudioPlayerManager = AudioPlayerManager()
//
//    var body: some View {
//        Text("Press alert button to bell")
//            .font(.system(size: 18))
//        Button {
//            Task{ try? seniorDashboardViewModel.sendSOS()}
//            audioManager.playAlert()
//        } label: {
//            ZStack {
//                Circle()
//                    .stroke(.blue)
//                    .frame(width: Screen.width * 0.9)
//                Circle()
//                    .tint(.blue)
//                    .frame(width: Screen.width * 0.8, height: Screen.width * 0.8)
//                Image(systemName: "light.beacon.max.fill")
//                    .resizable()
//                    .tint(.white)
//                    .frame(width: Screen.width * 0.35 * 1.17730, height: Screen.width * 0.35)
//            }
//        }
//    }
//}
