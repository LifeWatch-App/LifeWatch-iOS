//
//  RoutineView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 05/11/23.
//

import Shimmer
import SkeletonUI
import SwiftUI

struct RoutineView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var routineViewModel = RoutineViewModel()
    @State var routine: Routine = Routine()
    
    private var lastDate: Date = Calendar.current.startOfDay(for: Date()).addingTimeInterval(24 * 60 * 60 - 1)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    RoutineWeekPicker(routineViewModel: routineViewModel)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(routineViewModel.currentWeek.indices, id: \.self) { i in
                                
                                Button {
                                    routineViewModel.currentDay = routineViewModel.currentWeek[i]
                                    routineViewModel.dailyRoutineData()
                                } label: {
                                    VStack {
                                        ZStack {
                                            RoutineCircularProgressView(progress: routineViewModel.progressCount[i])
                                                .frame(width: 40)
                                            
                                            Text("\(routineViewModel.extractDate(date: routineViewModel.currentWeek[i], format: "d"))")
                                                .fontWeight(.semibold)
                                                .foregroundStyle(routineViewModel.isToday(date: routineViewModel.currentWeek[i]) ? .accent : Color(.label))
                                        }
                                        .skeleton(with: routineViewModel.isLoading,
                                                  size: CGSize(width: 40, height: 40),
                                                  animation: .none, appearance: .solid(color: .gray.opacity(0.2), background: .gray.opacity(0.2)),
                                                  shape: ShapeType.circle)
                                        .shimmering(active: routineViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                                        
                                        Text("\(routineViewModel.extractDate(date: routineViewModel.currentWeek[i], format: "E"))")
                                            .font(.subheadline)
                                            .foregroundStyle(routineViewModel.isToday(date: routineViewModel.currentWeek[i]) ? .accent : Color(.label))
                                            .skeleton(with: routineViewModel.isLoading,
                                                      animation: .none, appearance: .solid(color: .gray.opacity(0.2), background: .gray.opacity(0.2)),
                                                      shape: ShapeType.rounded(.radius(5, style: .circular)))
                                        
                                            .shimmering(active: routineViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                                    }
                                }
                                
                                //                                } else {
                                //                                    Button {
                                //                                        routineViewModel.currentDay = routineViewModel.currentWeek[i]
                                //                                        routineViewModel.dailyRoutineData()
                                //                                    } label: {
                                //                                        VStack {
                                //                                            ZStack {
                                //                                                RoutineCircularProgressView(progress: routineViewModel.progressCount[i])
                                //                                                    .skeleton(with: routineViewModel.isLoading,
                                //                                                              size: CGSize(width: 40, height: 40),
                                //                                                              animation: .none, appearance: .solid(color: .white, background: .white),
                                //                                                              shape: ShapeType.circle)
                                //                                                    .shimmering(active: routineViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                                //                                                    .frame(width: 40)
                                //                                            }
                                //                                        }
                                //                                    }
                                //                                }
                            }
                        }
                        .frame(height: 70)
                        .padding(.leading, 4)
                    }
                    .padding(.bottom, 4)
                    .onAppear {
                        routineViewModel.countProgress()
                    }
                    
                    if !routineViewModel.isLoading {
                        if (!routineViewModel.seniorSelected && routineViewModel.userRole == .caregiver) {
                            ContentUnavailableView {
                                Label("Try connecting to a senior", systemImage: "person.fill.badge.plus")
                            } description: {
                                Text("Invite your senior's email, then connect before adding their routines.")
                            }
                            .padding(.top, 64)
                        } else if routineViewModel.dailyRoutines.count > 0 {
                            HStack {
                                Text("\(routineViewModel.extractDate(date: routineViewModel.currentDay, format: "dd MMM yyyy"))")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                            }
                            
                            // foreach routine here
                            ForEach(routineViewModel.dailyRoutines) { routine in
                                if routine.time.count == 1 {
                                    HStack(spacing: 8) {
                                        VStack {
                                            Image(systemName: routine.type == "Medicine" ? "pill.circle.fill" : "figure.run.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 28)
                                                .foregroundStyle(.white, .accent)
                                            
                                            if routine != routineViewModel.dailyRoutines.last {
                                                RoundedRectangle(cornerRadius: 100)
                                                    .fill(.secondary.opacity(0.5))
                                                    .frame(width: 2)
                                            } else {
                                                Spacer()
                                            }
                                        }
                                        
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("\((routine.type == "Medicine" ? routine.medicine ?? "" : routine.activity ?? ""))")
                                                    .font(.title3)
                                                    .fontWeight(.semibold)
                                                
                                                if routine.type == "Medicine" {
                                                    if (routine.medicineAmount != "") {
                                                        Text("\(routine.medicineAmount ?? "") \(routine.medicineUnit?.rawValue ?? "")")
                                                    }
                                                } else {
                                                    if (routine.description != "") {
                                                        Text(routine.description ?? "")
                                                    }
                                                }
                                                
                                                HStack {
                                                    Image(systemName: "clock")
                                                    Text(routine.time.first ?? Date(), style: .time)
                                                        .padding(.leading, -4)
                                                }
                                                .foregroundStyle(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .trailing) {
                                                Button("Edit") {
                                                    self.routine = routine
                                                    routineViewModel.showEditRoutine.toggle()
                                                }
                                                .foregroundStyle(.accent)
                                                
                                                Spacer()
                                                
                                                if (routineViewModel.userRole == .senior) {
                                                    Button {
                                                        // change done status here - single
                                                        routineViewModel.updateSingleRoutineCheck(routine: routine)
                                                        //                                                routineViewModel.countProgress()
                                                    } label: {
                                                        Image(systemName: routine.isDone[0] ? "checkmark.circle.fill" : "circle")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 45)
                                                            .foregroundStyle(.accent)
                                                            .padding(.leading, 2)
                                                    } } else {
                                                        Image(systemName: routine.isDone[0] ? "checkmark.circle.fill" : "minus.circle.fill")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 50)
                                                            .foregroundStyle(routine.isDone[0] ? Color("secondary-green") : Color("emergency-pink"))
                                                    }
                                            }
                                        }
                                        .padding()
                                        .background(colorScheme == .light ? .white : Color(.systemGray6))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .padding(.bottom, 4)
                                } else {
                                    HStack(spacing: 8) {
                                        VStack {
                                            Image(systemName: routine.type == "Medicine" ? "pill.circle.fill" : "figure.run.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 28)
                                                .foregroundStyle(.white, .accent)
                                            
                                            if routine != routineViewModel.dailyRoutines.last {
                                                RoundedRectangle(cornerRadius: 100)
                                                    .fill(.secondary.opacity(0.5))
                                                    .frame(width: 2)
                                            } else {
                                                Spacer()
                                            }
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
                                                        if (routineViewModel.userRole == .senior) {
                                                            Button {
                                                                // change done status here
                                                                routineViewModel.updateRoutineCheck(routine: routine, index: i)
                                                            } label: {
                                                                Image(systemName: routine.isDone[i] ? "checkmark.circle.fill" : "circle")
                                                                    .resizable()
                                                                    .scaledToFit()
                                                                    .frame(width: 50)
                                                            }
                                                        } else {
                                                            Image(systemName: routine.isDone[i] ? "checkmark.circle.fill" : "minus.circle.fill")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 50)
                                                                .foregroundStyle(routine.isDone[i] ? Color("secondary-green") : Color("emergency-pink"))
                                                        }
                                                        
                                                        Text("\(routine.time[i], style: .time)")
                                                            .font(.subheadline)
                                                            .foregroundStyle(Color.secondary)
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
                                routineViewModel.isTodayAndAfter() ?
                                Label("Routines Not Set", systemImage: "pills.fill") : Label("The Day Has Passed", systemImage: "calendar.circle")
                            } description: {
                                Text(routineViewModel.isTodayAndAfter() ? "Add a daily medicine or activity schedule by clicking the plus button." : "Routines for this day were not set.")
                            }
                            .padding(.top, 64)
                        }
                    } else {
                        if routinesDummyDataSkeleton2.count > 0 {
                            HStack {
                                Text("\(routineViewModel.extractDate(date: routineViewModel.currentDay, format: "dd MMM yyyy"))")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .skeleton(with: routineViewModel.isLoading,
                                              size: CGSize(width: 120, height: 30),
                                              animation: .none, appearance: .solid(color: .gray.opacity(0.2), background: .gray.opacity(0.2)),
                                              shape: ShapeType.rounded(.radius(5, style: .circular)))
                                
                                    .shimmering(active: routineViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                                Spacer()
                            }
                            
                            // foreach routine here
                            ForEach(routinesDummyDataSkeleton2) { routine in
                                if routine.time.count == 1 {
                                    HStack(spacing: 8) {
                                        VStack {
                                            Image(systemName: routine.type == "Medicine" ? "pill.circle.fill" : "figure.run.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 28)
                                                .foregroundStyle(.white, .accent)
                                            
                                            
                                            if routine != routinesDummyDataSkeleton2.last {
                                                RoundedRectangle(cornerRadius: 100)
                                                    .fill(.secondary.opacity(0.5))
                                                    .frame(width: 2)
                                            } else {
                                                Spacer()
                                            }
                                        }
                                        
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("\((routine.type == "Medicine" ? routine.medicine ?? "" : routine.activity ?? ""))")
                                                    .font(.title3)
                                                    .fontWeight(.semibold)
                                                
                                                if routine.type == "Medicine" {
                                                    if (routine.medicineAmount != "") {
                                                        Text("\(routine.medicineAmount ?? "") \(routine.medicineUnit?.rawValue ?? "")")
                                                    }
                                                } else {
                                                    if (routine.description != "") {
                                                        Text(routine.description ?? "")
                                                    }
                                                }
                                                
                                                HStack {
                                                    Image(systemName: "clock")
                                                    Text(routine.time.first ?? Date(), style: .time)
                                                        .padding(.leading, -4)
                                                }
                                                .foregroundStyle(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .trailing) {
                                                Button("Edit") {
                                                    self.routine = routine
                                                    routineViewModel.showEditRoutine.toggle()
                                                }
                                                .foregroundStyle(.accent)
                                                
                                                Spacer()
                                                
                                                if (routineViewModel.userRole == .senior) {
                                                    Button {
                                                        // change done status here - single
                                                        routineViewModel.updateSingleRoutineCheck(routine: routine)
                                                        //                                                routineViewModel.countProgress()
                                                    } label: {
                                                        Image(systemName: routine.isDone[0] ? "checkmark.circle.fill" : "circle")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 45)
                                                            .foregroundStyle(.accent)
                                                            .padding(.leading, 2)
                                                    } } else {
                                                        Image(systemName: routine.isDone[0] ? "checkmark.circle.fill" : "minus.circle.fill")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 50)
                                                            .foregroundStyle(routine.isDone[0] ? Color("secondary-green") : Color("emergency-pink"))
                                                    }
                                            }
                                        }
                                        .padding()
                                        .background(colorScheme == .light ? .white : Color(.systemGray6))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .padding(.bottom, 4)
                                } else {
                                    HStack(spacing: 8) {
                                        VStack {
                                            Image(systemName: routine.type == "Medicine" ? "pill.circle.fill" : "figure.run.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 28)
                                                .foregroundStyle(.white, .accent)
                                            
                                            if routine != routinesDummyDataSkeleton.last {
                                                RoundedRectangle(cornerRadius: 100)
                                                    .fill(.secondary.opacity(0.5))
                                                    .frame(width: 2)
                                                    .opacity(0)
                                            } else {
                                                Spacer()
                                            }
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
                                                .skeleton(with: routineViewModel.isLoading,
                                                          animation: .none, appearance: colorScheme == .light ? .gradient() : .solid(color: .gray.opacity(0.2), background: .gray.opacity(0.2)),
                                                          shape: ShapeType.rounded(.radius(5, style: .circular)), lines: 2,
                                                          scales: [0: 0.8, 1: 0.45])
                                                
                                                .shimmering(active: routineViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                                                
                                                Spacer()
                                                
                                                //                                                Button("Edit") {
                                                //                                                    self.routine = routine
                                                //                                                    routineViewModel.showEditRoutine.toggle()
                                                //                                                }
                                                //                                                .foregroundStyle(.accent)
                                                //                                                .padding(.leading, 2)
                                                //                                                .skeleton(with: routineViewModel.isLoading,
                                                //                                                          animation: .none, appearance: .gradient(),
                                                //                                                          shape: ShapeType.rounded(.radius(5, style: .circular)), lines: 1,
                                                //                                                          scales: [0: 0.8])
                                                //
                                                //                                                .shimmering(active: routineViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                                            }
                                            
                                            Divider()
                                                .padding(.vertical, 4)
                                            
                                            HStack(alignment: .top, spacing: 20) {
                                                Spacer(minLength: 0)
                                                
                                                ForEach(routine.time.indices, id: \.self) { i in
                                                    VStack {
                                                        if (routineViewModel.userRole == .senior) {
                                                            Button {
                                                                // change done status here
                                                                routineViewModel.updateRoutineCheck(routine: routine, index: i)
                                                            } label: {
                                                                Image(systemName: routine.isDone[i] ? "checkmark.circle.fill" : "circle")
                                                                    .resizable()
                                                                    .scaledToFit()
                                                                    .skeleton(with: routineViewModel.isLoading,
                                                                              size: CGSize(width: 50, height: 50),
                                                                              animation: .none, appearance: colorScheme == .light ? .gradient() : .solid(color: .gray.opacity(0.2), background: .gray.opacity(0.2)),
                                                                              shape: ShapeType.circle)
                                                                
                                                                    .shimmering(active: routineViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                                                                    .frame(width: 50)
                                                            }
                                                        } else {
                                                            Image(systemName: routine.isDone[i] ? "checkmark.circle.fill" : "minus.circle.fill")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .skeleton(with: routineViewModel.isLoading,
                                                                          size: CGSize(width: 50, height: 50),
                                                                          animation: .none, appearance: colorScheme == .light ? .gradient() : .solid(color: .gray.opacity(0.2), background: .gray.opacity(0.2)),
                                                                          shape: ShapeType.circle)
                                                            
                                                                .shimmering(active: routineViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                                                                .frame(width: 50)
                                                                .foregroundStyle(routine.isDone[i] ? Color("secondary-green") : Color("emergency-pink"))
                                                        }
                                                        
                                                        Text("\(routine.time[i], style: .time)")
                                                            .font(.subheadline)
                                                            .foregroundStyle(Color.secondary)
                                                            .skeleton(with: routineViewModel.isLoading,
                                                                      size: CGSize(width: 40, height: 15),
                                                                      animation: .none, appearance: colorScheme == .light ? .gradient() : .solid(color: .gray.opacity(0.2), background: .gray.opacity(0.2)),
                                                                      shape: ShapeType.rounded(.radius(5, style: .circular)))
                                                        
                                                            .shimmering(active: routineViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                                                        
                                                    }
                                                }
                                                
                                                Spacer(minLength: 0)
                                            }
                                            
                                            //                                            Text(routine.type == "Medicine" ? "\(routine.medicineAmount ?? "") \(routine.medicineUnit?.rawValue ?? "")" : "\(routine.description ?? "")")
                                            //                                                .foregroundStyle(.secondary)
                                            //                                                .skeleton(with: routineViewModel.isLoading,
                                            //                                                          animation: .none, appearance: .gradient(),
                                            //                                                          shape: ShapeType.rounded(.radius(5, style: .circular)), lines: 1, scales: [0: 0.7])
                                            //
                                            //                                                .shimmering(active: routineViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                                            //                                                .minimumScaleFactor(0.5)
                                            //                                                .padding(.top, 8)
                                        }
                                        .padding()
                                        .background(colorScheme == .light ? .white : Color(.systemGray6))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .padding(.bottom, 4)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .background(Color(.systemGroupedBackground))
            .onAppear {
                if routineViewModel.viewHasAppeared != true {
                    routineViewModel.viewHasAppeared = true
                }
            }
            .sheet(isPresented: $routineViewModel.showAddRoutine, content: {
                AddEditRoutineView(currentDay: routineViewModel.currentDay, routine: nil)
            })
            .sheet(isPresented: $routineViewModel.showEditRoutine, content: {
                AddEditRoutineView(currentDay: routineViewModel.currentDay, routine: routine)
            })
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    
                    if !routineViewModel.isLoading {
                        Button {
                            routineViewModel.showAddRoutine.toggle()
                        } label: {
                            Image(systemName: "plus")
                                .font(.title3)
                                .bold()
                                .foregroundStyle(routineViewModel.currentDay < Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date() || routineViewModel.seniorSelected == false ? .gray : .accent)
                        }
                        .disabled(routineViewModel.currentDay < Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date() || routineViewModel.seniorSelected == false )
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
                    .foregroundStyle(.white, .accent)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    RoutineView()
    //        .preferredColorScheme(.dark)
}
