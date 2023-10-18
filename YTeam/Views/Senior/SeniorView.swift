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
            SeniorEmergencyView()
                .tabItem {
                    Label("Emergency", systemImage: "light.beacon.max.fill")
                }
            
//            EmptyView()
//                .tabItem {
//                    Label("Medicine", systemImage: "pill.fill")
//                }
//            
//            EmptyView()
//                .tabItem {
//                    Label("History", systemImage: "chart.bar.fill")
//                }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(
                    action: {
                        mainViewModel.signOut()
                    },
                    label: {
                        Text("Sign Out")
                            .bold()
                    }
                )
            }
        }
    }
}

#Preview {
    SeniorView(mainViewModel: MainViewModel())
}
