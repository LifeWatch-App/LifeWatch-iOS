//
//  TestAuthView.swift
//  YTeam Watch App
//
//  Created by Kevin Sander Utomo on 16/10/23.
//

import SwiftUI

struct MainView: View {
    @StateObject private var vm = TestAuthViewModel()
    var body: some View {
        if vm.userAuth?.userID != nil {
            VStack {
                TestChargingView()
                    .environmentObject(vm)
            }
        } else if vm.userAuth?.userID == nil {
            Text("Not authenticated and not logged in")
        }
    }
}

#Preview {
    MainView()
}
