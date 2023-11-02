//
//  CoreMotionManager.swift
//  YTeam Watch App
//
//  Created by Kenny Jinhiro Wibowo on 16/10/23.
//

import Foundation
import CoreMotion

class CoreMotionManager: ObservableObject {
    
    private let motionManager: CMMotionManager = CMMotionManager()
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
    
    init() {
        self.checkAccelerometerAvailability()
        self.setAccelerometerInterval(accelerometerInterval: self.accelerometerInterval)
        self.startAccelerometer()
        self.checkForFalls(interval: self.accelerometerInterval)
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
        if (self.accelerometerStarted) {
            self.motionManager.stopAccelerometerUpdates()
            self.accelerometerStarted = false
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
        if (self.accelerometerStarted) {
            var timer: Timer?
            
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                if let accelerationData = self.motionManager.accelerometerData {
                    self.lastX = self.accX
                    self.lastY = self.accY
                    self.lastZ = self.accZ
                    
                    self.accX = accelerationData.acceleration.x
                    self.accY = accelerationData.acceleration.y
                    self.accZ = accelerationData.acceleration.z
                }
                
                if (self.lastX == 0) && (self.lastY == 0) && (self.lastZ == 0) {
                    return
                }
                
                if (abs(self.accX - self.lastX) >= 0.9) {
                    self.fall = true
                    debugPrint("Fell")
                }
                
                if (abs(self.accY - self.lastY) >= 0.9) {
                    self.fall = true
                    debugPrint("Fell")
                }
                
                if (abs(self.accZ - self.lastZ) >= 0.9) {
                    self.fall = true
                    debugPrint("Fell")
                }

                debugPrint("Last X: \(self.lastX), X: \(self.accX)");
                debugPrint("Last Y: \(self.lastY), Y: \(self.accY)");
                debugPrint("Last Z: \(self.lastZ), Z: \(self.accZ)");
                
                //TODO: Find the way to stop the timer
                if (self.fall) {
                    timer?.invalidate()
                    timer = nil
                }
            }
        }
        
        if (self.fall) {
            self.stopAccelerometer()
        }
    }
}
