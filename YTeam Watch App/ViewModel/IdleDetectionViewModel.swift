//
//  IdleViewModel.swift
//  YTeam Watch App
//
//  Created by Maximus Aurelius Wiranata on 11/10/23.
//

import Foundation
import CoreMotion

class IdleDetectionViewModel: ObservableObject {
    private let service = DataService.shared
    var motionManager = CMMotionManager()
    
    @Published var gravityX : Double = 0
    @Published var gravityY : Double = 0
    @Published var gravityZ : Double = 0
    
    @Published var position: String = ""
    var latestPosition: String = ""
    var idle: Bool = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var time = 0
    var idleTime = 0
    
    var startTime = ""
    var endTime = ""
    
    func checkPosition() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1
            
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
                
                if self.latestPosition != self.position {
                    self.latestPosition = self.position
                    self.time = 0
                    self.idleTime = 0
                    self.idle = false
                } else {
                    self.time += 1
                    self.idleTime = self.time
                    if self.idleTime > 1800 {
                        self.idle = true
                    }
                }
            }
        }
    }
    
    func checkIdle() {
//        let inactivity = Inactivity(startTime: Description(timeStampValue: <#T##String?#>), endTime: Description(timeStampValue: <#T##String?#>))
//        Task { try? await service.set(endPoint: MultipleEndPoints.inactivity, fields: inactivity) }
    }
}
