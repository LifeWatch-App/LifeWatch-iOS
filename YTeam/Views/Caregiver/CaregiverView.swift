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
    @ObservedObject var batteryVM: BatteryLevelStateViewModel
    var body: some View {
        TabView {
            CaregiverDashboardView(batteryVM: batteryVM)
                .tabItem {
                    Label("Dashboard", systemImage: "list.clipboard.fill")
                }
            
            RoutineView()
                .tabItem {
                    Label("Routine", systemImage: "person.badge.clock.fill")
                }
            
            MapTestView()
                .tabItem {
                    Label("Location", systemImage: "location.fill")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "chart.bar.fill")
                }
            
            ConsultationView()
                .tabItem {
                    Label("AI Consultation", systemImage: "bubble.left.and.text.bubble.right.fill")
                }
        }
    }
}

#Preview {
    CaregiverView(mainViewModel: MainViewModel(), batteryVM: BatteryLevelStateViewModel())
}
