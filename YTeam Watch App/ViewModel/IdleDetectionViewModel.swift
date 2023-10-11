//
//  IdleViewModel.swift
//  YTeam Watch App
//
//  Created by Maximus Aurelius Wiranata on 11/10/23.
//

import Foundation
import CoreMotion

class IdleDetectionViewModel: ObservableObject {
    var motionManager = CMMotionManager()
    
    @Published var gravityX : Double = 0
    @Published var gravityY : Double = 0
    @Published var gravityZ : Double = 0
    @Published var position: String = "Move Me"
    
    func checkPosition() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.3
            
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { data,error in
                self.gravityX = data?.gravity.x ?? 0
                self.gravityY = data?.gravity.y ?? 0
                self.gravityZ = data?.gravity.z ?? 0
                
                if self.gravityX < -0.9 {
                    self.position = "Standing + Landscape + Speaker Left"
                }
                else if self.gravityX > 0.9 {
                    self.position = "Standing + Landscape + Speaker Right"
                }
                else if self.gravityY < -0.9 {
                    self.position = "Standing + Portrait + Speaker Up"
                }
                else if self.gravityY > 0.9 {
                    self.position = "Standing + Portrait + Speaker Down"
                }
                else if self.gravityZ < -0.9 {
                    self.position = "Flat + Facing Up"
                }
                else if self.gravityZ > 0.9 {
                    self.position = "Flat + Facing Down"
                }
                else {
                    self.position = "Not at right angles"
                }
            }
        }
    }
}
