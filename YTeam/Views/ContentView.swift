//
//  ContentView.swift
//  YTeam
//
//  Created by Yap Justin on 10/10/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var mainViewModel = MainViewModel()
    
    var body: some View {
        ZStack {
            if mainViewModel.isLoading {
                ProgressView()
            } else {
                if mainViewModel.user != nil {
                    MapTestView()
                } else {
                    LoginView()
                }
            }
        }
        .transition(.slide)
        .task {
            AuthService.shared.listenToAuthState()
        }
        .onChange(of: AuthService.shared.user) { oldValue, newValue in
            if oldValue == nil && newValue != nil {
                mainViewModel.getUserData()
            }
        }
        
    }
}

#Preview {
    ContentView()
}
