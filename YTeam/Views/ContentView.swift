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
                LoadingView()
            } else if mainViewModel.user != nil  {
                MainView(mainViewModel: mainViewModel)
            } else {
                LoginView()
            }
        }
        .transition(.opacity)
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
