//
//  FallDetectionManager.swift
//  YTeam Watch App
//
//  Created by Kenny Jinhiro Wibowo on 12/10/23.
//

import Foundation
import CoreMotion
import UserNotifications

@MainActor
class FallDetectionManager: NSObject, CMFallDetectionDelegate, ObservableObject {
    @Published var authorized: Bool = false
    @Published var fall: Bool = false
    @Published var notificationSent: Bool = false

    let fallDetector = CMFallDetectionManager()

    private let service = DataService.shared
    private let decoder: JSONDecoder = JSONDecoder()
    static var shared: FallDetectionManager = FallDetectionManager()
    override init() {
        super.init()
        self.assignDelegate()
        self.checkAndRequestForAuthorizationStatus()
    }

    /// Assign fall detection delegate to `watch for fall detection events`.
    ///
    /// ```
    /// FallDetectionManager.assignDelegate()
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: None, the function sets the fall detector's delegate to self.
    func assignDelegate() {
        self.fallDetector.delegate = self
    }

    /// Check the watch's `fall data authorization status` and `asks for confirmation in authorization`.
    ///
    /// ```
    /// FallDetectionManager.checkAndRequestForAuthorizationStatus()
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: None, the function asks for authorization status and sets the authorization status to user's input and
    ///  `sets the authorization boolean` in the ObservedObject.
    @MainActor
    func checkAndRequestForAuthorizationStatus() {
        DispatchQueue.main.async {
            if self.fallDetector.authorizationStatus == .authorized {
                self.authorized = true
            } else {
                self.fallDetector.requestAuthorization { currentStatus in
                    switch currentStatus {
                    case .authorized:
                        self.authorized = true
                    default:
                        self.authorized = false
                    }

                }
            }
        }
    }

    /// `Unchangable conforming function to automatically check for falls`.
    ///
    /// ```
    /// Not Called. Leave it be.
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: Void. Throws FallHistory Firebase Object to fallHistory document
    func fallDetectionManager(
        _ fallDetectionManager: CMFallDetectionManager,
        didDetect event: CMFallDetectionEvent) async {
            DispatchQueue.main.async {
                self.fall = true
                self.scheduleNotification()
            }
        }

    /// Disables `fall`.
    ///
    /// ```
    /// FallDetectionManager().cancelFallStatus().
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: Void. Disables fall
    func cancelFallStatus() {
        DispatchQueue.main.async {
            self.fall = false
        }
    }

    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Potential Fall"
        content.body = "Apple Watch Detected a Potential Fall."

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        let acceptAction = UNNotificationAction(identifier: "AcceptAction", title: "Yes", options: [])
        let rejectAction = UNNotificationAction(identifier: "RejectAction", title: "No", options: [])
        let fallCategory = UNNotificationCategory(identifier: "FallNotification", actions: [acceptAction, rejectAction], intentIdentifiers: [], options: [])

        UNUserNotificationCenter.current().setNotificationCategories([fallCategory])
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    func sendFall() {
        guard let data = UserDefaults.standard.data(forKey: "user-auth") else { return }
        let userRecord = try? self.decoder.decode(UserRecord.self, from: data)
        let timeDescription: Double = Date.now.timeIntervalSince1970
        if (userRecord != nil) {
            let time = Fall(time: Description(doubleValue: timeDescription), seniorId: Description(stringValue: userRecord?.userID))
            Task { try? await service.set(endPoint: MultipleEndPoints.falls, fields: time, httpMethod: .post) }
        }
    }
}
