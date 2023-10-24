//
//  CobaTestViewModel.swift
//  CobaApp Watch App
//
//  Created by Kevin Sander Utomo on 10/10/23.
//
import Foundation
import WatchKit
import Combine

final class CobaTestViewModel: ObservableObject {
    private let interface = WKInterfaceDevice()
    private(set) var chargingRangesForWatch: [ChargingRange] = []
    private var cancellables = Set<AnyCancellable>()
    private var batterySubscription: AnyCancellable?
    private let service = DataService.shared
    @Published private(set) var batteryCharging: WKInterfaceDeviceBatteryState = .unplugged
    @Published private(set) var batteryLevel: Int?
    @Published private(set) var currentRange: ChargingRange?
    private let encoder = JSONEncoder()

    required init() {
        initializerFunction()
        setupSubscribers()
    }

    deinit {
        batterySubscription?.cancel()
        batterySubscription = nil
    }

    func initializerFunction() {
        interface.isBatteryMonitoringEnabled = true
    }

    func resetRanges() {
        currentRange = nil
    }

    func startCharging() {
        batteryCharging = .charging
    }

    func stopCharging() {
        batteryCharging = .unplugged
    }


    private func setupSubscribers() {
        batterySubscription = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let userRecordData = UserDefaults.standard.object(forKey: "user-auth") as? Data,
                      let userRecord = try? JSONDecoder().decode(UserRecord.self, from: userRecordData),
                      let userID = userRecord.userID, let self = self else {
                          return
                      }

                if self.batteryLevel != Int(roundf(interface.batteryLevel * 100)) {
                    self.batteryLevel = Int(roundf(interface.batteryLevel * 100))

                    Task {
                        if let batteryRecords: FirebaseRecords<BatteryLevelRecord> = try? await self.service.fetch(endPoint: MultipleEndPoints.batteryLevels, httpMethod: .get) {

                            guard let specificBatteryRecord = batteryRecords.documents.first(where: { $0.fields?.seniorID?.stringValue == userID }) else { return }
                            guard let specificBatteryRecordDocumentName = specificBatteryRecord.name else { return }
                            let components = specificBatteryRecordDocumentName.components(separatedBy: "/")
                            guard let specificBatteryRecordDocumentID = components.last else { return }

                            let batteryLevelRecord1: BatteryLevelRecord = BatteryLevelRecord(seniorID: Description(stringValue: userID), watchBatteryLevel: Description(stringValue: self.batteryLevel?.description), iphoneBatteryLevel: specificBatteryRecord.fields?.iphoneBatteryLevel, watchLastUpdatedAt: Description(stringValue: Date.now.description), iphoneLastUpdatedAt: specificBatteryRecord.fields?.iphoneLastUpdatedAt, watchBatteryState: specificBatteryRecord.fields?.watchBatteryState, iphoneBatteryState: specificBatteryRecord.fields?.iphoneBatteryState)

                            try? await self.service.set(endPoint: SingleEndpoints.batteryLevels(batteryLevelsDocumentID: specificBatteryRecordDocumentID), fields: batteryLevelRecord1, httpMethod: .patch)
                        } else {
                            let batteryLevelRecord: BatteryLevelRecord = BatteryLevelRecord(seniorID: Description(stringValue: userID), watchBatteryLevel: Description(stringValue: self.batteryLevel?.description), watchLastUpdatedAt: Description(stringValue: Date.now.description))

                            try? await self.service.set(endPoint: MultipleEndPoints.batteryLevels, fields: batteryLevelRecord, httpMethod: .post)
                        }
                        //MARK: On iOS side (caregiver), it must be real-time monitoring for the batteryLevel, with a specific userId, of the user that is logged in, and then create two collections of ios and watch
                        //MARK: From watch send data to the watch collection
                        //MARK: From ios send data to the ios collection
                    }
                }

                if self.batteryCharging != self.interface.batteryState {
                    if self.interface.batteryState != .unknown {
                        self.batteryCharging = self.interface.batteryState

                        Task {
                            if let batteryRecords: FirebaseRecords<BatteryLevelRecord> = try? await self.service.fetch(endPoint: MultipleEndPoints.batteryLevels, httpMethod: .get) {

                                guard let specificBatteryRecord = batteryRecords.documents.first(where: { $0.fields?.seniorID?.stringValue == userID }) else { return }
                                guard let specificBatteryRecordDocumentName = specificBatteryRecord.name else { return }
                                let components = specificBatteryRecordDocumentName.components(separatedBy: "/")
                                guard let specificBatteryRecordDocumentID = components.last else { return }

                                let batteryLevelRecord: BatteryLevelRecord = BatteryLevelRecord(seniorID: Description(stringValue: userID), watchBatteryLevel: specificBatteryRecord.fields?.watchBatteryLevel, iphoneBatteryLevel: specificBatteryRecord.fields?.iphoneBatteryLevel, watchLastUpdatedAt: Description(stringValue: Date.now.description), iphoneLastUpdatedAt: specificBatteryRecord.fields?.iphoneLastUpdatedAt, watchBatteryState: Description(stringValue: self.batteryCharging.description), iphoneBatteryState: specificBatteryRecord.fields?.iphoneBatteryState)

                                try? await self.service.set(endPoint: SingleEndpoints.batteryLevels(batteryLevelsDocumentID: specificBatteryRecordDocumentID), fields: batteryLevelRecord, httpMethod: .patch)
                            }
                        }
                    }
                }
            }

        $batteryCharging
            .receive(on: DispatchQueue.main)
            .sink { [weak self] batteryState in
                guard let self, let userIData = UserDefaults.standard.object(forKey: "user-auth") else { return }
                guard let userID = try? JSONDecoder().decode(UserRecord.self, from: userIData as! Data).userID else { return }
                switch batteryState {
                case .charging:
                    if self.currentRange == nil {
                        self.currentRange = ChargingRange(startCharging: Date.now, taskState: "ongoing")
                        let rangeCurrent: ChargingRangeRecord = ChargingRangeRecord(seniorId: Description(stringValue: userID), startCharging: Description(stringValue: self.currentRange?.startCharging?.description), taskState: Description(stringValue: self.currentRange?.taskState))
                        Task { try? await self.service.set(endPoint: MultipleEndPoints.charges, fields: rangeCurrent, httpMethod: .post) }
                    }
                case .unplugged:
                    if self.currentRange?.taskState == "ongoing" {
                        self.currentRange?.taskState = "ended"
                    }

                    if self.currentRange?.taskState == "ended" {
                        guard let currentRange = self.currentRange else { return }

                        if currentRange.getValidChargingRange(startCharging: currentRange.startCharging ?? .now, endCharging: currentRange.endCharging ?? .now) == true {
                            self.chargingRangesForWatch.append(currentRange)
                            Task {
                                if let chargingRecords: FirebaseRecords<ChargingRangeRecord> = try? await self.service.fetch(endPoint: MultipleEndPoints.charges, httpMethod: .get) {

                                    guard let specificChargingRecord = chargingRecords.documents.first(where: { $0.fields?.seniorId?.stringValue == userID && $0.fields?.startCharging?.stringValue == currentRange.startCharging?.description  }) else { return }
                                    guard let specificChargingRecordDocumentName = specificChargingRecord.name else { return }
                                    let components = specificChargingRecordDocumentName.components(separatedBy: "/")
                                    guard let specificChargingRecordDocumentID = components.last else { return }

                                    let updatedIdleRecord = ChargingRangeRecord(seniorId: Description(stringValue: specificChargingRecord.fields?.seniorId?.stringValue), startCharging: Description(stringValue: specificChargingRecord.fields?.startCharging?.stringValue), endCharging: Description(stringValue: Date.now.description), taskState: Description(stringValue: "ended"))
                                    try await self.service.set(endPoint: SingleEndpoints.charges(chargeDocumentID: specificChargingRecordDocumentID), fields: updatedIdleRecord, httpMethod: .patch)
                                    self.resetRanges()
                                }
                            }
                        } else {
                            Task {
                                if let chargingRecords: FirebaseRecords<ChargingRangeRecord> = try? await self.service.fetch(endPoint: MultipleEndPoints.charges, httpMethod: .get) {

                                    guard let specificChargingRecord = chargingRecords.documents.first(where: { $0.fields?.seniorId?.stringValue == userID && $0.fields?.startCharging?.stringValue == currentRange.startCharging?.description  }) else { return }
                                    guard let specificChargingRecordDocumentName = specificChargingRecord.name else { return }
                                    let components = specificChargingRecordDocumentName.components(separatedBy: "/")
                                    guard let specificChargingRecordDocumentID = components.last else { return }

                                    try await self.service.delete(endPoint: SingleEndpoints.charges(chargeDocumentID: specificChargingRecordDocumentID), httpMethod: .delete)
                                    self.resetRanges()
                                }
                            }
                        }

                        resetRanges()
                    }
                case .unknown:
                    print("Unknown state")
                case .full:
                    print("Your battery is full")
                @unknown default:
                    print("Unknown")
                }
            }
            .store(in: &cancellables)


        //        batteryLevelSubscription = Timer.publish(every: 5, on: .main, in: .common)
        //            .autoconnect()
        //            .sink { [weak self] _ in
        //                guard let self else { return }
        //                if self.batteryLevel != Int(roundf(interface.batteryLevel * 100)) {
        //                    self.batteryLevel = Int(roundf(interface.batteryLevel * 100))
        //
        //                    guard let userIData = UserDefaults.standard.object(forKey: "user-auth") else { return }
        //                    guard let userID = try? JSONDecoder().decode(UserRecord.self, from: userIData as! Data).userID else { return }
        //                    let batteryLevelRecord: BatteryLevelRecord = BatteryLevelRecord(seniorID: Description(stringValue: userID), watchBatteryLevel: Description(stringValue: self.batteryLevel?.description), watchLastUpdatedAt: Description(stringValue: Date.now.description))
        //
        //                    Task {
        //                        if let batteryRecords: FirebaseRecords<BatteryLevelRecord> = try? await self.service.fetch(endPoint: MultipleEndPoints.batteryLevels, httpMethod: .get) {
        //
        //                            guard let specificBatteryRecord = batteryRecords.documents.first(where: { $0.fields?.seniorID?.stringValue == userID }) else { return }
        //                            guard let specificBatteryRecordDocumentName = specificBatteryRecord.name else { return }
        //                            let components = specificBatteryRecordDocumentName.components(separatedBy: "/")
        //                            guard let specificBatteryRecordDocumentID = components.last else { return }
        //
        //                            try? await self.service.set(endPoint: SingleEndpoints.batteryLevels(batteryLevelsDocumentID: specificBatteryRecordDocumentID), fields: batteryLevelRecord, httpMethod: .patch)
        //                        } else {
        //                            try? await self.service.set(endPoint: MultipleEndPoints.batteryLevels, fields: batteryLevelRecord, httpMethod: .post)
        //                        }
        //                        //MARK: On iOS side (caregiver), it must be real-time monitoring for the batteryLevel, with a specific userId, of the user that is logged in, and then create two collections of ios and watch
        //                        //MARK: From watch send data to the watch collection
        //                        //MARK: From ios send data to the ios collection
        //                    }
        //                }
        //
        //            }
    }

}



//    func handleBatteryStateChange(batteryState: WKInterfaceDeviceBatteryState, userID: String) {
//        switch batteryState {
//        case .charging:
//            if self.currentRange == nil {
//                self.currentRange = ChargingRange(startCharging: Date.now, taskState: "ongoing")
//                let rangeCurrent: ChargingRangeRecord = ChargingRangeRecord(seniorId: Description(stringValue: userID), startCharging: Description(stringValue: self.currentRange?.startCharging?.description), taskState: Description(stringValue: self.currentRange?.taskState))
//                Task { try? await service.set(endPoint: MultipleEndPoints.charges, fields: rangeCurrent, httpMethod: .post) }
//            }
//        default:
//            if self.currentRange?.taskState == "ongoing" {
//                self.currentRange?.taskState = "ended"
//            }
//
//            if self.currentRange?.taskState == "ended" {
//                guard let currentRange = self.currentRange else { return }
//
//                if currentRange.getValidChargingRange(startCharging: currentRange.startCharging ?? .now, endCharging: currentRange.endCharging ?? .now) == true {
//                    self.chargingRangesForWatch.append(currentRange)
//                    Task {
//                        if let chargingRecords: FirebaseRecords<ChargingRangeRecord> = try? await service.fetch(endPoint: MultipleEndPoints.charges, httpMethod: .get) {
//
//                            guard let specificChargingRecord = chargingRecords.documents.first(where: { $0.fields?.seniorId?.stringValue == userID && $0.fields?.startCharging?.stringValue == currentRange.startCharging?.description  }) else { return }
//                            guard let specificChargingRecordDocumentName = specificChargingRecord.name else { return }
//                            let components = specificChargingRecordDocumentName.components(separatedBy: "/")
//                            guard let specificChargingRecordDocumentID = components.last else { return }
//
//                            let updatedIdleRecord = ChargingRangeRecord(seniorId: Description(stringValue: specificChargingRecord.fields?.seniorId?.stringValue), startCharging: Description(stringValue: specificChargingRecord.fields?.startCharging?.stringValue), endCharging: Description(stringValue: Date.now.description), taskState: Description(stringValue: "ended"))
//                            try await service.set(endPoint: SingleEndpoints.charges(chargeDocumentID: specificChargingRecordDocumentID), fields: updatedIdleRecord, httpMethod: .patch)
//                        }
//                    }
//                } else {
//                    Task {
//                        if let chargingRecords: FirebaseRecords<ChargingRangeRecord> = try? await service.fetch(endPoint: MultipleEndPoints.charges, httpMethod: .get) {
//
//                            guard let specificChargingRecord = chargingRecords.documents.first(where: { $0.fields?.seniorId?.stringValue == userID && $0.fields?.startCharging?.stringValue == currentRange.startCharging?.description  }) else { return }
//                            guard let specificChargingRecordDocumentName = specificChargingRecord.name else { return }
//                            let components = specificChargingRecordDocumentName.components(separatedBy: "/")
//                            guard let specificChargingRecordDocumentID = components.last else { return }
//
//                            try await service.delete(endPoint: SingleEndpoints.charges(chargeDocumentID: specificChargingRecordDocumentID), httpMethod: .delete)
//                        }
//                    }
//                }
//                resetRanges()
//            }
//        }
//    }


extension WKInterfaceDeviceBatteryState {
    var descriptionState: String {
        switch self {
        case .charging:
            return "Charging!!"
        case .unknown:
            return "Unknown!!"
        default:
            return "Not Charging!!"
        }
    }

    var description: String {
        switch self {
        case .unknown:
            return "unknown"
        case .unplugged:
            return "unplugged"
        case .charging:
            return "charging"
        case .full:
            return "full"
        default:
            return "unknown"
        }
    }
}


