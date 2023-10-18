//
//  YTeamApp.swift
//  YTeam
//
//  Created by Yap Justin on 10/10/23.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { isSuccessful, error in
            guard isSuccessful else{
                return
            }
            print("SUCCESSFUL APNs REGISTRY")
        }
        application.registerForRemoteNotifications()
        return true
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM TOKEN:", fcmToken ?? "")
        let dataDict: [String: String] = ["fcmToken": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("fcmToken"), object: fcmToken, userInfo: dataDict)
        // Save it to the user defaults
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

@main
struct YTeamApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
