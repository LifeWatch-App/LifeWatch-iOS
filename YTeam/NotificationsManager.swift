//
//  NotificationsManager.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 10/10/23.
//

import Foundation
import SwiftUI


class NotificationsManager: ObservableObject {
    
    // Sets the current phone's notification center.
    private let notificationsCenter = UNUserNotificationCenter.current()
    
    // Checks if we have notifications center on, if not do throw error and close the application.
    init() {
        self.notificationsCenter
            .requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
            if let error: Error {
                print(error)
            }
        })
    }
    
    // Call this function to notify the user.
    func notify(triggerInSeconds: Double, repeatNotification: Bool, notificationId: String, notificationTitle: String, notificationSubtitle: String, notificationBody: String) {
        
        // Sets the trigger settings, default: triggerInSeconds second of trigger and does not repeat.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerInSeconds, repeats: repeatNotification)
        
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
    
    // Get the client's notification settings.
    func getNotifySettings() {
        self.notificationsCenter.getNotificationSettings { settings in
            debugPrint("Notification settings: \(settings)")
        }
    }
    
    //Reset All Delivered and Pending Notifications.
    func resetAllNotifications(){
        self.notificationsCenter.removeAllDeliveredNotifications()
        self.notificationsCenter.removeAllPendingNotificationRequests()
    }
}
