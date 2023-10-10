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
    
    // Sets the trigger settings, default: 1 second of trigger and does not repeat.
    private let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    
    
    // Checks if we have notifications center on, if not do throw error and close the application.
    init() {
        notificationsCenter
            .requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
            if let error: Error {
                print(error)
            }
        })
    }
    
    // Call this function to notify the user.
    func notify(notificationId: String, notificationTitle: String, notificationSubtitle: String) {
    
        let content = UNMutableNotificationContent()
        
        content.title = notificationTitle
        content.subtitle = notificationSubtitle
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        
        // Add error closure if there is any error.
        
        notificationsCenter.add(request) { (error) in
            if let error = error {
                debugPrint("Error: \(error.localizedDescription)")
            } else {
                debugPrint("Scheduled Notification Successfully")
            }
        }
        
    }
    
    // Get the client's notification settings.
    func getNotifySettings() {
        notificationsCenter.getNotificationSettings { settings in
            debugPrint("Notification settings: \(settings)")
        }
    }
    
}
