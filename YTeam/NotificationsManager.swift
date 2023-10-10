//
//  NotificationsManager.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 10/10/23.
//

import Foundation
import SwiftUI
import CloudKit

class NotificationsManager: ObservableObject {
    
    // Sets the current phone's notification center.
    private let notificationsCenter = UNUserNotificationCenter.current()
    
    // Checks if we have notifications center on, if not do throw error and close the application.
    init() {
        self.notificationsCenter
            .requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (success, error) in
            if let error: Error {
                debugPrint(error)
            } else if success {
                debugPrint("Notifications permissions success.")
                
                // Allow APNs
                DispatchQueue.main.async{
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                debugPrint("Notifications permissions failure.")
            }
        })
    }
    

    /// Call this function to notify the user when app is `closed`.
    ///
    /// ```
    /// NotificationsManager.notifyLocally(triggerInSeconds: <Double>, notificationId: <String>, notificationTitle: <String>, notificationSubtitle: <String>, notificationBody: <String>)
    /// ```
    ///
    ///
    /// - Parameters:
    ///     - triggerInSeconds: How many seconds after the instantiation should the notification be triggered.
    ///     - notificationId: Add a custom notificationID key. It could be anything.
    ///     - notificationTitle: Add what you want to show in the title.
    ///     - notificationSubtitle: Add what you want to show in the subtitle.
    ///     - notificationBody: Add wht you want to show in the body.
    /// - Returns: A notificaiton scheduled in `triggerinSeconds` seconds,  .with a `notificationId`, with a title of `notificationTitle, with a
    ///   subtitle of `notificationSubtitle`, and a body of `notificationBody`.
    ///
    func notify(triggerInSeconds: Double, notificationId: String, notificationTitle: String, notificationSubtitle: String, notificationBody: String) {
        
        // Sets the trigger settings, default: triggerInSeconds second of trigger and does not repeat.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerInSeconds, repeats: false)
        
        let content = UNMutableNotificationContent()
        
        content.title = notificationTitle
        content.subtitle = notificationSubtitle
        content.body = notificationBody
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        
        // Add error closure if there is any error.
        
        self.notificationsCenter.add(request) { (error) in
            if let error = error {
                debugPrint("Error: \(error.localizedDescription)")
            } else {
                debugPrint("Scheduled Notification Successfully")
            }
        }
        
    }
    
    /// Call this function to notify debug `user's notification settings`.
    ///
    /// ```
    /// NotificationsManager.getNotifySettings()
    /// ```
    /// - Parameters:
    ///     - None
    /// - Returns: The `debug print` for the notification settings of the user, what is on and what is disabled by them. This can be used for alerts.
    func getNotifySettings() {
        self.notificationsCenter.getNotificationSettings { settings in
            debugPrint("Notification settings: \(settings)")
        }
    }
    
    /// Call this function to notify debug `user's notification settings`.
    ///
    /// ```
    /// NotificationsManager.resetAllNotifications()
    /// ```
    /// - Parameters:
    ///     - None
    /// - Returns: Void, it resets all the notificationsCenter settings.
    func resetAllNotifications(){
        self.notificationsCenter.removeAllDeliveredNotifications()
        self.notificationsCenter.removeAllPendingNotificationRequests()
    }
    
    /// Call this function so users can `subscribe to a CloudKit record`.
    /// This function enables detection if `any alert is added (as a row) to the CloudKit record`
    /// ```
    /// NotificationsManager.subscribeToSeniorAlerts()
    /// ```
    /// - Parameters:
    ///     - None
    /// - Returns: Void, it sets up user's notifications.
    func subscribeToSeniorAlerts() {
        let predicate = NSPredicate(value: true)
        let subscription = CKQuerySubscription(recordType: "SeniorAlert", predicate: predicate, subscriptionID: "senior_alert", options: .firesOnRecordCreation)
        
        let notification = CKSubscription.NotificationInfo()
        notification.title = "Your Senior is in Danger"
        notification.alertBody = "Check out on your senior!"
        notification.soundName = "default"
        
        subscription.notificationInfo = notification
        
        CKContainer.default().publicCloudDatabase.save(subscription) { returnedSubscription, returnedError in
            if let error = returnedError{
                print(error)
            } else {
                print("Successfully subscribed to senior alerts.")
            }
        }
    }
    
    /// Call this function so users to `test the subscription to Senior Alerts`.
    ///
    /// ```
    /// NotificationsManager.testSeniorAlerts()
    /// ```
    /// - Parameters:
    ///     - None
    /// - Returns: Void, it sets up the test for the subscription of user's notifications..
    func testSeniorAlerts() {
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
