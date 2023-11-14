//
//  SeniorEmergencyView.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 18/10/23.
//

import SwiftUI

struct SeniorDashboardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("emailModal") var emailModal = true
    
    @StateObject var seniorDashboardViewModel = SeniorDashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack{
                    ButtonCards(seniorDashboardViewModel: seniorDashboardViewModel)
                    
                    ForEach(seniorDashboardViewModel.invites, id: \.id) { invite in
                        if !invite.accepted! {
                            HStack() {
                                VStack(alignment: .leading) {
                                    Text("\(invite.caregiverData!.name ?? "Subroto")")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    Text("Would like to join your care team")
                                        .foregroundColor(.secondary)
                                
                                }
                                Spacer()
                                HStack(spacing: 16) {
                                    Button {
                                        seniorDashboardViewModel.acceptInvite(id: invite.id!)
                                    } label: {
                                        Text("Accept")
                                    }
                                    Button {
                                        seniorDashboardViewModel.denyInvite(id: invite.id!)
                                    } label: {
                                        Text("Deny")
                                            .foregroundStyle(.red)
                                    }
                                }
                                .padding(.leading, 4)
                            }
                            .padding()
                            .background(colorScheme == .light ? .white : Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                                                
                    }
                    
                    UpcomingActivity(seniorDashboardViewModel: seniorDashboardViewModel)
                    
                    Symtomps(seniorDashboardViewModel: seniorDashboardViewModel)
                }
                .padding(.horizontal)
            }
            .sheet(isPresented: $seniorDashboardViewModel.showAddSymptom, content: {
                AddSymptomView()
            })
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
            .fullScreenCover(isPresented: $emailModal) {
                OnBoardingEmailView()
            }
        }
    }
}

struct ButtonCards: View {
    @ObservedObject var seniorDashboardViewModel: SeniorDashboardViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            Button{
                seniorDashboardViewModel.showSOS.toggle()
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
            .fullScreenCover(isPresented: $seniorDashboardViewModel.showSOS, content: {
                SOSView(seniorDashboardViewModel: seniorDashboardViewModel)
            })
            
            Button {
                seniorDashboardViewModel.showWalkieTalkie.toggle()
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
            .fullScreenCover(isPresented: $seniorDashboardViewModel.showWalkieTalkie, content: {
                WalkieTalkieView()
            })
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
                    SeniorAllRoutineView(seniorDashboardViewModel: seniorDashboardViewModel)
                } label: {
                    Text("See All")
                        .font(.headline)
                }
            }
            
            VStack(spacing: 20) {
                // Ambil 3 dengan waktu terdekat yang belum done
                ForEach(seniorDashboardViewModel.routines.prefix(2)) { routine in
                    ForEach(routine.time.indices, id: \.self) { i in
                        HStack(spacing: 16) {
                            VStack {
                                Image(systemName: routine.type == "Medicine" ? "pill.fill" : "figure.run")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40)
                                    .foregroundStyle(.white)
                            }
                            .padding(12)
                            .frame(width: 52, height: 52)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\((routine.type == "Medicine" ? routine.medicine ?? "" : routine.activity ?? ""))")
                                    .font(.headline)
                                Text(routine.type == "Medicine" ? "\(routine.medicineAmount ?? "") \(routine.medicineUnit?.rawValue ?? "")" : "\(routine.description ?? "")")
                                HStack {
                                    Image(systemName: "clock")
                                    Text(routine.time[i], style: .time)
                                        .padding(.leading, -4)
                                }
                                .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: routine.isDone[i] ? "checkmark.circle.fill" : "circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40)
                                .foregroundStyle(.accent)
                        }
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
                Text("Today's Symptoms")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    seniorDashboardViewModel.showAddSymptom.toggle()
                } label: {
                    Image(systemName: "plus")
                        .font(.title3)
                        .bold()
                }
            }
            
            ForEach(seniorDashboardViewModel.symptoms) { symptom in
                HStack(spacing: 16) {
                    Image("safe")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                    
                    VStack(alignment: .leading) {
                        Text(symptom.name ?? "Unknown")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        if let note = symptom.note {
                            Text(note)
                                .font(.subheadline)
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "clock")
                        Text(Date.unixToDate(unix: symptom.time ?? 0), style: .time)
                            .padding(.leading, -4)
                            .font(.subheadline)
                    }
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
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
//        .preferredColorScheme(.dark)
}
