//
//  SeniorView.swift
//  YTeam
//
//  Created by Yap Justin on 18/10/23.
//

import SwiftUI

struct SeniorView: View {
    @ObservedObject var mainViewModel: MainViewModel
    
    var body: some View {
        TabView {
            SeniorDashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "list.clipboard.fill")
                }
            
            RoutineView()
                .tabItem {
                    Label("Routine", systemImage: "person.badge.clock.fill")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "chart.bar.fill")
                }
        }
    }
}

#Preview {
    SeniorView(mainViewModel: MainViewModel())
}
