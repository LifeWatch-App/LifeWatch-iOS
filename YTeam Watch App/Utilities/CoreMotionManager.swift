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
            Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                if let accelerationData = self.motionManager.accelerometerData {
                    self.accX = accelerationData.acceleration.x
                    self.accY = accelerationData.acceleration.y
                    self.accZ = accelerationData.acceleration.z
                }
                
                let accelerometerPrediction = -0.085405 * self.accX + 0.033008 * self.accY + -0.197427 * self.accZ
                                                
                if (accelerometerPrediction >= 0.6){
                    self.fall = true
                    debugPrint("Fell")
                }
                
                debugPrint("X Accelerometer: \(self.accX), Y Accelerometer: \(self.accY), Z Accelerometer: \(self.accZ), AP: \(accelerometerPrediction)");
            }
        }
    }
}
