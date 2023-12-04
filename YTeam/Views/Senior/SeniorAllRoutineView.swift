//
//  SeniorAllRoutineView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 06/11/23.
//

import SwiftUI

struct SeniorAllRoutineView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var seniorDashboardViewModel: SeniorDashboardViewModel
    @StateObject var routineViewModel: RoutineViewModel = RoutineViewModel()
    
    var body: some View {
        if seniorDashboardViewModel.routines.count > 0 {
            ScrollView {
                VStack {
                    ForEach(seniorDashboardViewModel.routines) { routine in
                        ForEach(routine.time.indices, id: \.self) { i in
                            HStack(spacing: 16) {
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
                                    Text(routine.type == "Medicine" ? "\(routine.medicineAmount ?? "") \(routine.medicineUnit?.rawValue ?? "")" : "\(routine.description ?? "")")
                                    HStack {
                                        Image(systemName: "clock")
                                        Text(routine.time[i], style: .time)
                                            .padding(.leading, -4)
                                    }
                                    .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                Button {
                                    routineViewModel.updateRoutineCheck(routine: routine, index: i)
                                } label: {
                                    Image(systemName: routine.isDone[i] ? "checkmark.circle.fill" : "circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40)
                                        .foregroundStyle(.accent)
                                }
                            }
                            .padding()
                            .background(colorScheme == .light ? .white : Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .frame(width: Screen.width - 32)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Routines")
        } else {
            ContentUnavailableView {
                Label("Routines not Set", systemImage: "pills.fill")
            } description: {
                Text("To set your routine and medicine schedule, go directly to the routine tab.")
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

#Preview {
    SeniorAllRoutineView(seniorDashboardViewModel: SeniorDashboardViewModel())
}
