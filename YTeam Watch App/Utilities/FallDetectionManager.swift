//
//  FallDetectionManager.swift
//  YTeam Watch App
//
//  Created by Kenny Jinhiro Wibowo on 12/10/23.
//

import Foundation
import CoreMotion

class FallDetectionManager: NSObject, CMFallDetectionDelegate, ObservableObject {
    
    @Published var authorized: Bool = false
    
    let fallDetector = CMFallDetectionManager()
    private let service = DataService.shared
    
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
    func checkAndRequestForAuthorizationStatus() {
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
            
        let timeDescription = "\(event.date.description) \(event.resolution.rawValue)"
        let time = Fall(time: Description(stringValue: timeDescription))
        Task { try? await service.set(endPoint: MultipleEndPoints.falls, fields: time) }
        debugPrint("Successfully inputed \(timeDescription) to Firebase")
            
    }
    
    /// `Unchangable conforming function to automatically check for change in authorization`.
    ///
    /// ```
    /// Not Called. Leave it be.
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: None.
    func fallDetectionManagerDidChangeAuthorization(
        _ fallDetectionManager: CMFallDetectionManager
    )  {
        print("Authorization for fall detection is changed.")
    }
    
}
