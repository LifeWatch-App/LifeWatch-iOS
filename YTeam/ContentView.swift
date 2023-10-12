//
//  ContentView.swift
//  YTeam
//
//  Created by Yap Justin on 10/10/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.user != nil {
                MainView()
            } else {
                LoginView()
            }
        }.onAppear {
            authViewModel.listenToAuthState()
        }
    }
}

#Preview {
    ContentView()
}
