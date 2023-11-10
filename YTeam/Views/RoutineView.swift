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
    @State var routine: Routine = Routine()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    RoutineWeekPicker(routineViewModel: routineViewModel)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(routineViewModel.currentWeek, id: \.self) { day in
                                Button {
                                    routineViewModel.currentDay = day
                                } label: {
                                    VStack {
                                        ZStack {
                                            RoutineCircularProgressView(progress: routineViewModel.progressCount, disabled: day > Date())
                                                .frame(width: 40)
                                            
                                            Text("\(routineViewModel.extractDate(date: day, format: "d"))")
                                                .fontWeight(.semibold)
                                                .foregroundStyle(routineViewModel.isToday(date: day) ? .accent : day > Date() ? .secondary : Color(.label))
                                        }
                                        
                                        Text("\(routineViewModel.extractDate(date: day, format: "E"))")
                                            .font(.subheadline)
                                            .foregroundStyle(routineViewModel.isToday(date: day) ? .accent : day > Date() ? .secondary : Color(.label))
                                    }
                                }
                                .disabled(day > Date())
                            }
                        }
                        .frame(height: 70)
                        .padding(.leading, 4)
                    }
                    .padding(.bottom, 4)
                    
                    if routineViewModel.routines.count > 0 {
                        HStack {
                            Text("\(routineViewModel.extractDate(date: routineViewModel.currentDay, format: "dd MMM yyyy"))")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        // foreach routine here
                        ForEach(routineViewModel.routines) { routine in
                            if routine.time.count == 1 {
                                HStack(spacing: 8) {
                                    VStack {
                                        Image(systemName: routine.type == "Medicine" ? "pill.circle.fill" : "figure.run.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 28)
                                            .foregroundStyle(.white, .accent)
                                        
                                        RoundedRectangle(cornerRadius: 100)
                                            .fill(.secondary.opacity(0.5))
                                            .frame(width: 2)
                                    }
                                    
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("\((routine.type == "Medicine" ? routine.medicine ?? "" : routine.activity ?? ""))")
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                            
                                            Text(routine.type == "Medicine" ? "\(routine.medicineAmount ?? "") \(routine.medicineUnit?.rawValue ?? "")" : "\(routine.description ?? "")")
                                            
                                            HStack {
                                                Image(systemName: "clock")
                                                Text(routine.time.first ?? Date(), style: .time)
                                                    .padding(.leading, -4)
                                            }
                                            .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing) {
                                            Button("Edit") {
                                                self.routine = routine
                                                routineViewModel.showEditRoutine.toggle()
                                            }
                                            .foregroundStyle(.accent)
                                            
                                            Spacer()
                                            
                                            Button {
                                                // change done status here
                                                
                                            } label: {
                                                Image(systemName: "circle")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 45)
                                                    .foregroundStyle(.accent)
                                                    .padding(.leading, 2)
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(colorScheme == .light ? .white : Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            } else {
                                HStack(spacing: 8) {
                                    VStack {
                                        Image(systemName: routine.type == "Medicine" ? "pill.circle.fill" : "figure.run.circle.fill")
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
                                                Text("\((routine.type == "Medicine" ? routine.medicine ?? "" : routine.activity ?? ""))")
                                                    .font(.title3)
                                                    .fontWeight(.semibold)
                                                
                                                Text("\(routine.isDone.filter {$0 == false}.count) remaining")
                                                    .font(.subheadline)
                                            }
                                            
                                            Spacer()
                                            
                                            Button("Edit") {
                                                self.routine = routine
                                                routineViewModel.showEditRoutine.toggle()
                                            }
                                            .foregroundStyle(.accent)
                                            .padding(.leading, 2)
                                        }
                                        
                                        Divider()
                                            .padding(.vertical, 4)
                                        
                                        HStack(alignment: .top, spacing: 20) {
                                            Spacer(minLength: 0)
                                            
                                            ForEach(routine.time.indices, id: \.self) { i in
                                                VStack {
                                                    Button {
                                                        // change done status here
                                                        routineViewModel.updateRoutine(routine, i)
                                                    } label: {
                                                        Image(systemName: routine.isDone[i] ? "checkmark.circle.fill" : "circle")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 50)
                                                    }
                                                    
                                                    Text("\(routine.time[i], style: .time)")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.accent)
                                                }
                                            }
                                            
                                            Spacer(minLength: 0)
                                        }
                                        
                                        Text(routine.type == "Medicine" ? "\(routine.medicineAmount ?? "") \(routine.medicineUnit?.rawValue ?? "")" : "\(routine.description ?? "")")
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
                    } else {
                        ContentUnavailableView {
                            Label("Routines not Set", systemImage: "pills.fill")
                        } description: {
                            Text("Add a daily medicine or activity schedule by clicking the plus button.")
                        }
                        .padding(.top, 64)
                    }
                }
                .padding(.horizontal)
            }
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $routineViewModel.showAddRoutine, content: {
                AddEditRoutineView(routine: nil)
            })
            .sheet(isPresented: $routineViewModel.showEditRoutine, content: {
                AddEditRoutineView(routine: routine)
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
            .disabled(routineViewModel.currentWeek.contains(Date()))
        }
        .padding(.vertical, 8)
        .onChange(of: routineViewModel.currentWeek) { oldValue, newValue in
            if routineViewModel.currentDay > Date() {
                routineViewModel.currentDay = Date()
                routineViewModel.fetchCurrentWeek()
            }
        }
    }
}

#Preview {
    RoutineView()
//        .preferredColorScheme(.dark)
}
