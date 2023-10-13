//
//  ContentView.swift
//  YTeam
//
//  Created by Yap Justin on 10/10/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var mainViewModel = MainViewModel()
    
    var body: some View {
        Group {
            if mainViewModel.user != nil {
                MainView()
            } else {
                LoginView()
            }
        }.onAppear {
            AuthService.shared.listenToAuthState()
        }
    }
}

#Preview {
    ContentView()
}
