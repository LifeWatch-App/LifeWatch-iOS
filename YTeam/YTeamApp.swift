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
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.list, .banner, .badge, .sound])
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM TOKEN:", fcmToken ?? "")
        
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
        
        if AuthService.shared.userData?.fcmToken != nil {
            if ((AuthService.shared.userData?.fcmToken!) != fcmToken) {
                AuthService.shared.updateFCMToken(fcmToken: fcmToken!)
            }
        }
        
        let dataDict: [String: String] = ["fcmToken": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("fcmToken"), object: fcmToken, userInfo: dataDict)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("APNS Token: ", deviceToken.map { String(format: "%02.2hhx", $0) }.joined())
    }
}

@main
struct YTeamApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @AppStorage("currentOnBoarding") var currentOnBoarding = 1
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .task {
                    try? await PTT.shared.setupChannelManager()
                }
            
//            if currentOnBoarding < 5 {
//                OnBoardingView()
//            } else {
//                ContentView()
//                    .preferredColorScheme(.light)
//                    .task {
//                        try? await PTT.shared.setupChannelManager()
//                    }
//            }
        }
    }
}
