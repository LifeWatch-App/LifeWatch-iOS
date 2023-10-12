//
//  FallDetectionManager.swift
//  YTeam Watch App
//
//  Created by Kenny Jinhiro Wibowo on 12/10/23.
//

import Foundation
import CoreMotion

class FallDetectionManager: NSObject, CMFallDetectionDelegate, ObservableObject {
    
    let fallDetector = CMFallDetectionManager()
    @Published var authorized: Bool = false
    
    override init() {
        super.init()
        self.fallDetector.delegate = self
        if self.fallDetector.authorizationStatus == .notDetermined{
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
    
    func fallDetectionManager(
        _ fallDetectionManager: CMFallDetectionManager,
        didDetect event: CMFallDetectionEvent) async {
        print("Fall Detected!", event.date, event.resolution.rawValue)
    }
}
