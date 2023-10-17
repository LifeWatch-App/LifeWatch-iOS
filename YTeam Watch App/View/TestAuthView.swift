//
//  TestAuthView.swift
//  YTeam Watch App
//
//  Created by Kevin Sander Utomo on 16/10/23.
//

import SwiftUI

struct TestAuthView: View {
    @StateObject private var vm = TestAuthViewModel()
    var body: some View {
        if vm.userAuth?.userID != nil {
            VStack {
                Text("Authenticated and logged in")
                Button("Test") {
                    print(vm.userAuth)
                }
            }
        } else {
            Text("Not authenticated and not logged in")
        }
    }
}

#Preview {
    TestAuthView()
}
