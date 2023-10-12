//
//  ContentView.swift
//  YTeam Watch App
//
//  Created by Yap Justin on 10/10/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var fallDetectionManager: FallDetectionManager = FallDetectionManager()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            fallDetectionManager.authorized ? Text("Fall Detection Authorized, Try Falling!") : Text("Authorize First")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
