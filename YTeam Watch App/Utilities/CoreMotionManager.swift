//
//  CoreMotionManager.swift
//  YTeam Watch App
//
//  Created by Kenny Jinhiro Wibowo on 16/10/23.
//

import Foundation
import CoreMotion
import WatchConnectivity
import WatchKit

class CoreMotionManager: ObservableObject {
    
    private var motionManager: CMMotionManager = CMMotionManager()
    private let accelerometerInterval: Double = 2
    
    @Published var fall: Bool = false
    @Published var accelerometerAvailable: Bool = false
    @Published var accelerometerStarted: Bool = false
    
    private var lastX: Double = 0
    private var lastY: Double = 0
    private var lastZ: Double = 0
    
    private var accX: Double = 0
    private var accY: Double = 0
    private var accZ: Double = 0
    
    private var timer: Timer?
    
    init() {
        self.checkAccelerometerAvailability()
        self.setAccelerometerInterval(accelerometerInterval: self.accelerometerInterval)
        self.startAccelerometer()
    }
    
    
    /// Check the watch's `availability of accelerometer`.
    ///
    /// ```
    /// motionManager.checkAccelerometerAvailability()
    /// ```
    /// - Parameters:
    ///     - None
    /// - Returns: `Void. Boolean of accelerometerAvailable is set regarding to the condition statement.`
    func checkAccelerometerAvailability() {
        if (self.motionManager.isAccelerometerAvailable == false) {
            self.accelerometerAvailable = false
        }
        if (self.motionManager.isAccelerometerAvailable == true) {
            self.accelerometerAvailable = true
        }
    }
    
    /// Check the watch's `accelerometer interval`.
    ///
    /// ```
    /// motionManager.setAccelerometerInterval()
    /// ```
    /// - Parameters:
    ///     - None
    /// - Returns: `Void. Sets accelerometer interval to whatever the hardcoded inteval is.`
    func setAccelerometerInterval(accelerometerInterval: Double) {
        //A broader smooth window of about 2 seconds of sensed data entries out-performed both shorter and longer smooth windows.
        if (self.accelerometerAvailable) {
            self.motionManager.accelerometerUpdateInterval = self.accelerometerInterval
        }
    }
    
    /// Start the watch's `accelerometer` `if accelerometer availability is true`.
    ///
    /// ```
    /// motionManager.startAccelerometer()
    /// ```
    /// - Parameters:
    ///     - None
    /// - Returns: `Void. Starts accelerometer of the motion manager if accelerometer's availability is true.`
    func startAccelerometer() {
        if (self.accelerometerAvailable){
            self.motionManager.startAccelerometerUpdates()
            self.accelerometerStarted = true
            self.checkForFalls(interval: self.accelerometerInterval)
        }
    }
    
    /// Stop the watch's `accelerometer` `if accelerometer is started`.
    ///
    /// ```
    /// motionManager.stopAccelerometer()
    /// ```
    /// - Parameters:
    ///     - None
    /// - Returns: `Void. Starts accelerometer of the motion manager if accelerometer's availability is true.`
    func stopAccelerometer() {
        if self.timer != nil {
            print("Stop the timer!")
            self.timer?.invalidate()
            self.timer = nil
            
            self.motionManager.stopAccelerometerUpdates()
            self.accelerometerStarted = false
            
            //TODO: Send to database
        }
    }
    
    /// Log the watch's `accelerometer` and checks if user `fell`.
    ///
    /// ```
    /// motionManager.checkForFalls()
    /// ```
    /// - Parameters:
    ///     - Interval (`Double`): The amount of seconds to log another report.
    /// - Returns: `Void. Starts a timer for every for user falls after accelerometer starts.`
    func checkForFalls(interval: Double) {
        if (self.accelerometerStarted && !self.fall) {
            self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
                if (self.fall) {
                    return
                }
                
                if let accelerationData = self.motionManager.accelerometerData, self.fall == false {
                    self.lastX = self.accX
                    self.lastY = self.accY
                    self.lastZ = self.accZ
                    
                    self.accX = accelerationData.acceleration.x
                    self.accY = accelerationData.acceleration.y
                    self.accZ = accelerationData.acceleration.z
                    
                    if (self.lastX == 0) && (self.lastY == 0) && (self.lastZ == 0) {
                        return
                    }
                    
                    print("Delta X: \(abs(self.accX - self.lastX))");
                    print("Delta Y: \(abs(self.accY - self.lastY))");
                    print("Delta Z: \(abs(self.accZ - self.lastZ))");
                    
                    if (abs(self.accX - self.lastX) >= 1 || abs(self.accY - self.lastY) >= 1 || abs(self.accZ - self.lastZ) >= 1) {
                        print("You fell")
                        timer.invalidate()
                        self.stopAccelerometer()
                        self.fall = true
                        self.triggerHapticFeedback()
                    }
                }
            }
        }
    }
    
    /// Triggers `haptic feedback`.
    ///
    /// ```
    /// CoreMotionManager().triggerHapticFeedback().
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: Void. Disables fall
    func triggerHapticFeedback() {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["hapticFeedback": true], replyHandler: nil, errorHandler: { error in
                print("Error sending haptic feedback message: \(error.localizedDescription)")
            })
        } else {
            // If the watch is not reachable, use local haptic feedback
            WKInterfaceDevice.current().play(.notification)
        }
    }
    
    /// Disables `fall`.
    ///
    /// ```
    /// CoreMotionManager().cancelFallStatus().
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: Void. Disables fall
    func cancelFallStatus() {
        self.fall = false
    }
}
