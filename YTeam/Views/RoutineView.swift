//
//  RoutineView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 05/11/23.
//

import SwiftUI

struct RoutineView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var routineViewModel = RoutineViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    RoutineWeekPicker(routineViewModel: routineViewModel)
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: 12) {
                            ForEach(routineViewModel.currentWeek, id: \.self) { day in
                                Button {
                                    routineViewModel.currentDay = day
                                    print(routineViewModel.currentDay)
                                } label: {
                                    VStack {
                                        ZStack {
                                            RoutineCircularProgressView(progress: 0.4)
                                                .frame(width: 40)
                                            
                                            Text("\(routineViewModel.extractDate(date: day, format: "d"))")
                                                .fontWeight(.semibold)
                                                .foregroundStyle(routineViewModel.isToday(date: day) ? .accent : Color(.label))
                                        }
                                        
                                        Text("\(routineViewModel.extractDate(date: day, format: "E"))")
                                            .font(.subheadline)
                                            .foregroundStyle(routineViewModel.isToday(date: day) ? .accent : Color(.label))
                                    }
                                }
                            }
                        }
                        .frame(height: 70)
                        .padding(.leading, 4)
                    }
                    .padding(.bottom, 4)
                    
                    HStack {
                        Text("23 Oct 2023")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                    // foreach routine here
                    ForEach(0...2, id: \.self) { _ in
                        HStack(spacing: 8) {
                            VStack {
                                Image(systemName: "pill.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 28)
                                    .foregroundStyle(.white, .accent)
                                
                                RoundedRectangle(cornerRadius: 100)
                                    .fill(.secondary.opacity(0.5))
                                    .frame(width: 2)
                            }
                            
                            VStack(alignment: .leading) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading) {
                                        Text("Doxylamine")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                        
                                        Text("1 remaining")
                                            .font(.subheadline)
                                    }
                                    
                                    Spacer()
                                    
                                    Button("Edit") {
                                        
                                    }
                                    .foregroundStyle(.accent)
                                    .padding(.leading, 2)
                                }
                                
                                Divider()
                                    .padding(.vertical, 4)
                                
                                HStack(alignment: .top, spacing: 24) {
                                    Spacer()
                                    
                                    VStack {
                                        Button {
                                            
                                        } label: {
                                            Image(systemName: "checkmark.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50)
                                        }
                                        
                                        Text("4:44 PM")
                                            .font(.subheadline)
                                            .foregroundStyle(.accent)
                                    }
                                    
                                    VStack {
                                        Button {
                                            
                                        } label: {
                                            Image(systemName: "circle")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50)
                                        }
                                    }
                                    
                                    VStack {
                                        Button {
                                            
                                        } label: {
                                            Image(systemName: "circle")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                
                                Text("Take the tablet with a full glass of water.")
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 8)
                                    .minimumScaleFactor(0.5)
                            }
                            .padding()
                            .background(colorScheme == .light ? .white : Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.bottom, 4)
                    }
                }
                .padding(.horizontal)
            }
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $routineViewModel.showAddRoutine, content: {
                AddRoutineView()
            })
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        routineViewModel.showAddRoutine.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.accent)
                    }
                }
            }
            .navigationTitle("Routines")
        }
    }
}

struct RoutineWeekPicker: View {
    @ObservedObject var routineViewModel: RoutineViewModel
    
    var body: some View {
        HStack {
            Button {
                routineViewModel.changeWeek(type: .previous)
            } label: {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white, .accent)
            }
            
            Spacer()
            
            Text("\(routineViewModel.extractDate(date: routineViewModel.currentWeek.first ?? Date(), format: "dd MMM yyyy")) - \(routineViewModel.extractDate(date: routineViewModel.currentWeek.last ?? Date(), format: "dd MMM yyyy"))")
                .fontWeight(.semibold)
                .font(.system(size: 20))
                .padding(.horizontal, 2)
            
            Spacer()
            
            Button {
                routineViewModel.changeWeek(type: .next)
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white, !routineViewModel.isToday(date: Date()) ? .accent : .gray)
            }
            .disabled(routineViewModel.isToday(date: Date()))
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    RoutineView()
//        .preferredColorScheme(.dark)
}
