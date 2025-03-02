//
//  YTeamApp.swift
//  YTeam Watch App
//
//  Created by Yap Justin on 10/10/23.
//

import SwiftUI
import UserNotifications
import WatchKit

@main
struct YTeam_Watch_App: App {
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
            MainView()
        }
    }
}
