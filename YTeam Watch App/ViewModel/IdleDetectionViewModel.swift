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
    
    @Published var currentIdle: Inactivity?
    @Published var isAlreadyIdle: Bool = false
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
                    if self.idle == true && self.currentIdle != nil {
                        self.isAlreadyIdle = false
                        self.updateIdleDataFirebase(endTime: Date.now)
                    }
                    
                    self.latestPosition = self.position
                    self.time = 0
                    self.idleTime = 0
                    self.idle = false
                    self.isAlreadyIdle = false
                    
                } else {
                    self.time += 1
                    self.idleTime = self.time
                    if self.idleTime > 30 && self.isAlreadyIdle == false {
                        self.isAlreadyIdle = true
                        self.idle = true
                        self.createIdleDataFirebase(startTime: Date.now)
                    }
                }
            }
        }
    }
    
    func createIdleDataFirebase(startTime: Date) {
        guard let userIDData = UserDefaults.standard.object(forKey: "user-auth") else {
            print("Fail getting userID")
            return
        }
        do {
            let userRecord = try JSONDecoder().decode(UserRecord.self, from: userIDData as! Data)
            let idleData = Inactivity(seniorId: Description(stringValue: userRecord.userID), startTime: Description(doubleValue: Date.now.timeIntervalSince1970), taskState: Description(stringValue: "ongoing"))
            
            if self.currentIdle == nil {
                Task {
                    try? await service.set(endPoint: MultipleEndPoints.idles, fields: idleData, httpMethod: .post)
                    self.currentIdle = idleData
                }
            }
        } catch {
            print("Failed to decode data: \(error)")
        }
    }
    
    func updateIdleDataFirebase(endTime: Date) {
        guard let userIDData = UserDefaults.standard.object(forKey: "user-auth") else {
            print("Fail getting userID")
            return
        }
        Task {
            if let idleRecords: FirebaseRecords<Inactivity> = try? await service.fetch(endPoint: MultipleEndPoints.idles, httpMethod: .get) {
                
                guard let userID = try? JSONDecoder().decode(UserRecord.self, from: userIDData as! Data).userID else {
                    print("Failed to find userID")
                    return
                }
                
                guard let specificIdleRecord = idleRecords.documents.first(where: { $0.fields?.seniorId?.stringValue == userID && $0.fields?.startTime?.doubleValue == self.currentIdle?.startTime?.doubleValue }) else {
                    print("Failed to find specific idle record")
                    return
                }
                
                guard let specificIdleRecordDocumentName = specificIdleRecord.name else { return }
                let components = specificIdleRecordDocumentName.components(separatedBy: "/")
                guard let specificIdleRecordDocumentID = components.last else { return }
                
                let updatedIdleRecord = Inactivity(seniorId: Description(stringValue: specificIdleRecord.fields?.seniorId?.stringValue), startTime: Description(doubleValue: specificIdleRecord.fields?.startTime?.doubleValue), endTime: Description(doubleValue: endTime.timeIntervalSince1970), taskState: Description(stringValue: "ended"))
                try await service.set(endPoint: SingleEndpoints.idles(idleDocumentID: specificIdleRecordDocumentID), fields: updatedIdleRecord, httpMethod: .patch)
                
                self.currentIdle = nil
            }
        }
    }
    
    func deleteIdleDataFirebase() {
        guard let userIDData = UserDefaults.standard.object(forKey: "user-auth") else {
            print("Fail getting userID")
            return
        }
        Task {
            if let idleRecords: FirebaseRecords<Inactivity> = try? await self.service.fetch(endPoint: MultipleEndPoints.idles, httpMethod: .get) {
                
                guard let userID = try? JSONDecoder().decode(UserRecord.self, from: userIDData as! Data).userID else { return }
                
                guard let specificIdleRecord = idleRecords.documents.first(where: { $0.fields?.seniorId?.stringValue == userID && $0.fields?.startTime?.doubleValue == self.currentIdle?.startTime?.doubleValue }) else { return }
                guard let specificIdleRecordDocumentName = specificIdleRecord.name else { return }
                let components = specificIdleRecordDocumentName.components(separatedBy: "/")
                guard let specificIdleRecordDocumentID = components.last else { return }
                
                try await service.delete(endPoint: SingleEndpoints.idles(idleDocumentID: specificIdleRecordDocumentID), httpMethod: .delete)
            }
        }
    }
}

