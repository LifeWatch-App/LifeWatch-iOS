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
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let routineData = userInfo["routine"] as? [String: Any] else { return }
        guard let isDelete = userInfo["isDelete"] as? Bool else { return }
        print("isDelete", isDelete)
        
        completionHandler(.newData)
        let dict: [AnyHashable: Any] = routineData
               do {
                   let jsonData = try JSONSerialization.data(withJSONObject: dict)
                   let routine = try JSONDecoder().decode(RoutineData.self, from: jsonData)
                   var uuidsToBeDeleted = [String]()
                   
                   let notificationCenter = UNUserNotificationCenter.current()
                   notificationCenter.getPendingNotificationRequests { unnNotificationRequests in
                       var identifiers = [String]()
                       
                       for (_, unNotificationRequest) in unnNotificationRequests.enumerated() {
                           if unNotificationRequest.content.threadIdentifier == routine.id {
                               identifiers.append(unNotificationRequest.identifier)
                           }
                           
                           notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
                       }
                       
                       if !isDelete {
                           for (index, isDone) in routine.isDone.enumerated() {
                               if !isDone {
                                   let content = UNMutableNotificationContent()
                                   content.threadIdentifier = routine.id
                                   
                                   if routine.type == "Medicine" {
                                       content.title = "Take \(routine.medicine) - \(routine.medicineAmount) \(routine.medicineUnit)"
                                       content.body = "Don't forget to take your medicine."
                                   } else {
                                       content.title = "Time to \(routine.activity)"
                                       content.body = routine.description == "" ? "Don't forget to do your routine." : routine.description
                                   }
                                   
                                   let date = Date(timeIntervalSince1970: routine.time[index])

                                   // Configure the recurring date.
                                   var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                                   dateComponents.timeZone = nil

                                   // Create the trigger as a repeating event.
                                   let trigger = UNCalendarNotificationTrigger(
                                            dateMatching: dateComponents, repeats: true)

                                   // Create the request
                                   let uuidString = routine.uuid[index].uuidString
                                   let request = UNNotificationRequest(identifier: uuidString,
                                               content: content, trigger: trigger)


                                   // Schedule the request with the system.
                                   let notificationCenter = UNUserNotificationCenter.current()
                                   notificationCenter.add(request) { (error) in
                                      if error != nil {
                                         // Handle any errors.
                                      } else {
                                          print("Notfication successfuly scheduled:", dateComponents)
                                      }
                                   }
                               }
                           }
                       }
                   }
               }
               catch {
                   print(error)
               }
    }
}

@main
struct YTeamApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @State var currentOnBoarding = 1
    @AppStorage("onBoardingDone") var onBoardingDone = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if currentOnBoarding < 6 && !onBoardingDone {
                    OnBoardingView(currentOnBoarding: $currentOnBoarding)
                } else {
                    ContentView()
                        .task {
                            try? await PTT.shared.setupChannelManager()
                        }
                }
            }
            .transition(.opacity)
        }
    }
}
