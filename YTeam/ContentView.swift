//
//  ContentView.swift
//  YTeam
//
//  Created by Yap Justin on 10/10/23.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var notifications: NotificationsManager = NotificationsManager()
    
    @State var count: Int = 0
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("\(count)")
            Button("Add Count"){
                self.count += 1
            }
        }
        .onAppear{
            notifications.notify(notificationId: "test", notificationTitle: "Test", notificationSubtitle: "Test")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
