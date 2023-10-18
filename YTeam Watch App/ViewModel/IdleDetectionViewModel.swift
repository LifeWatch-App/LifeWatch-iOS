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
                    if self.idle == true {
                        self.updateIdleDataFirebase(endTime: Date.now)
                    } else {
                        self.deleteIdleDataFirebase()
                    }
                    self.latestPosition = self.position
                    self.time = 0
                    self.idleTime = 0
                    self.idle = false
                    self.currentIdle = nil
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

    private func createIdleDataFirebase(startTime: Date) {
        let userIDData = UserDefaults.standard.object(forKey: "user-auth")
        do {
            let userRecord = try JSONDecoder().decode(UserRecord.self, from: userIDData as! Data)
            let idleData = Inactivity(seniorId: Description(stringValue: userRecord.userID), startTime: Description(stringValue: Date.now.description))
            if let currentIdle = self.currentIdle {
                Task { try? await service.set(endPoint: MultipleEndPoints.idles, fields: currentIdle, httpMethod: .post) }
            } else {
                self.currentIdle = idleData
            }
        } catch {
            print("Failed to decode data: \(error)")
        }
    }

    private func updateIdleDataFirebase(endTime: Date) {
        let userIDData = UserDefaults.standard.object(forKey: "user-auth")
        Task {
            if let idleRecords: FirebaseRecords<Inactivity> = try? await service.fetch(endPoint: MultipleEndPoints.idles, httpMethod: .get), let currentIdle = self.currentIdle {

                guard let userID = try? JSONDecoder().decode(UserRecord.self, from: userIDData as! Data).userID else { return }

                guard let specificIdleRecord = idleRecords.documents.first(where: { $0.fields?.seniorId?.stringValue == userID && $0.fields?.startTime?.stringValue == currentIdle.startTime?.stringValue }) else { return }

                guard let specificIdleRecordDocumentName = specificIdleRecord.name else { return }
                let components = specificIdleRecordDocumentName.components(separatedBy: "/")
                guard let specificIdleRecordDocumentID = components.last else { return }

                let updatedIdleRecord = Inactivity(seniorId: Description(stringValue: specificIdleRecord.fields?.seniorId?.stringValue), startTime: Description(stringValue: specificIdleRecord.fields?.startTime?.stringValue), endTime: Description(stringValue: Date.now.description))
                try await service.set(endPoint: SingleEndpoints.charges(chargeDocumentID: specificIdleRecordDocumentID), fields: updatedIdleRecord, httpMethod: .patch)
            }
        }
    }

    private func deleteIdleDataFirebase() {
        let userIDData = UserDefaults.standard.object(forKey: "user-auth")
        Task {
            if let idleRecords: FirebaseRecords<Inactivity> = try? await self.service.fetch(endPoint: MultipleEndPoints.idles, httpMethod: .get), let currentIdle = self.currentIdle {

                guard let userID = try? JSONDecoder().decode(UserRecord.self, from: userIDData as! Data).userID else { return }

                guard let specificIdleRecord = idleRecords.documents.first(where: { $0.fields?.seniorId?.stringValue == userID && $0.fields?.startTime?.stringValue == currentIdle.startTime?.stringValue }) else { return }
                guard let specificIdleRecordDocumentName = specificIdleRecord.name else { return }
                let components = specificIdleRecordDocumentName.components(separatedBy: "/")
                guard let specificIdleRecordDocumentID = components.last else { return }

                try await service.delete(endPoint: SingleEndpoints.idles(idleDocumentID: specificIdleRecordDocumentID), httpMethod: .delete)
            }
        }
    }
}

