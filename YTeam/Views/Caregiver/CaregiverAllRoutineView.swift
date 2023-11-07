//
//  CaregiverAllRoutineView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 06/11/23.
//

import SwiftUI

struct CaregiverAllRoutineView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var caregiverDashboardViewModel: CaregiverDashboardViewModel
    
    var body: some View {
        ScrollView {
            VStack {
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
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Senior Routines")
    }
}

#Preview {
    CaregiverAllRoutineView(caregiverDashboardViewModel: CaregiverDashboardViewModel())
}
