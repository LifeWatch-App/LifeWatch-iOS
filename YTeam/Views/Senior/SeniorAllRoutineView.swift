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
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(seniorDashboardViewModel.routines) { routine in
                    HStack {
                        Divider()
                            .frame(minWidth: 4)
                            .background(.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 100))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(routine.name)
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text(routine.description)
                            
                            HStack {
                                Image(systemName: "clock")
                                Text(routine.time, style: .time)
                                    .padding(.leading, -4)
                            }
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45)
                            .foregroundStyle(.accent)
                    }
                    .padding()
                    .background(colorScheme == .light ? .white : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Routines")
    }
}

#Preview {
    SeniorAllRoutineView(seniorDashboardViewModel: SeniorDashboardViewModel())
}
