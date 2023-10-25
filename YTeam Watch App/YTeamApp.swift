//
//  YTeamApp.swift
//  YTeam Watch App
//
//  Created by Yap Justin on 10/10/23.
//

import SwiftUI
import UserNotifications

@main
struct YTeam_Watch_AppApp: App {
    let notificationCenter = UNUserNotificationCenter.current()

    init() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
            if let error: Error {
                print(error)
            }
        })
    }

    var body: some Scene {
        WindowGroup {
            TestChargingView()
        }
    }
}

