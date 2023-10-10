//
//  ContentView.swift
//  YTeam
//
//  Created by Yap Justin on 10/10/23.
//

import SwiftUI
import CloudKit

struct ContentView: View {
    
    @ObservedObject var notifications: NotificationsManager = NotificationsManager()
    
    @State var count: Int = 0
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, World!")
            Button("Subscribe to notifications") {
                notifications.subscribeToSeniorAlerts()
            }
            Button("Add to record") {
                let record = CKRecord(recordType: "SeniorAlert")
                record["id"] = UUID().uuidString
                CKContainer.default().publicCloudDatabase.save(record) { (returnedRecord, error) in
                    if (error == nil){
                        debugPrint("Added Row to Senior Alert")
                    } else if let error {
                        debugPrint(error)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
