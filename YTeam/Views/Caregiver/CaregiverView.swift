//
//  NavigationView.swift
//  YTeam
//
//  Created by Yap Justin on 18/10/23.
//

import SwiftUI

struct CaregiverView: View {
    @ObservedObject var mainViewModel: MainViewModel
    @State var showChangeSenior = false
    var body: some View {
        TabView {
            CaregiverDashboardView()
                .tabItem {
                    Label("Emergency", systemImage: "light.beacon.max.fill")
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
    CaregiverView(mainViewModel: MainViewModel())
}
