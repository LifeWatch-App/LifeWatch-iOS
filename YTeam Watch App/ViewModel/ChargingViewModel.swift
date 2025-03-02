//
//  CobaTestViewModel.swift
//  CobaApp Watch App
//
//  Created by Kevin Sander Utomo on 10/10/23.
//
import Foundation
import WatchKit
import Combine

@MainActor
final class ChargingViewModel: ObservableObject {
    private let interface = WKInterfaceDevice()
    private var cancellables = Set<AnyCancellable>()
    private var batterySubscription: AnyCancellable?
    private var chargingStateSubscription: AnyCancellable?
    private let service = DataService.shared
    @Published private(set) var isFirstTime: Bool = true
    @Published private(set) var batteryCharging: WKInterfaceDeviceBatteryState?
    @Published private(set) var batteryLevel: Int?
    @Published private(set) var currentRange: ChargingRange?
    private let encoder = JSONEncoder()
    
    required init() {
        initializerFunction()
        setupSubscribers()
    }
    
    deinit {
        print("Deinited")
        batterySubscription?.cancel()
        batterySubscription = nil
        chargingStateSubscription?.cancel()
        chargingStateSubscription = nil
    }
    
    func initializerFunction() {
        interface.isBatteryMonitoringEnabled = true
        deleteChargingRecordsInitializer()
    }
    
    func deleteChargingRecordsInitializer() {
        Task {
            guard let userIData = UserDefaults.standard.object(forKey: "user-auth") else { return }
            guard let userID = try? JSONDecoder().decode(UserRecord.self, from: userIData as! Data).userID else { return }
            
            if let chargingRecords: [FirestoreQueryRecord<ChargingRangeRecord>] = try? await self.service.queryMultipleFields(collection: "charges", httpMethod: .post, seniorId: userID) {
                
                let specificChargingRecords = chargingRecords.filter({ $0.document?.fields?.seniorId?.stringValue == userID })
                
                let specificChargingRecordsIDs = specificChargingRecords.compactMap { record -> String? in
                    let specificChargingRecordDocumentName = record.document?.name
                    let components = specificChargingRecordDocumentName?.components(separatedBy: "/")
                    let specificChargingRecordDocumentID = components?.last
                    return specificChargingRecordDocumentID
                }
                
                try await withThrowingTaskGroup(of: Void.self) { group in
                    for documentsId in specificChargingRecordsIDs {
                        group.addTask {
                            try? await self.service.delete(endPoint: SingleEndpoints.charges(chargeDocumentID: documentsId), httpMethod: .delete)
                        }
                    }
                    
                    for try await task in group {
                        print(task)
                    }
                    
                    print("Success deleting records")
                }
            }
            
        }
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
        $isFirstTime
            .sink { [weak self] firstTime in
                if firstTime == true {
                    guard let self = self else { return }
                    guard let userRecordData = UserDefaults.standard.object(forKey: "user-auth") as? Data,
                          let userRecord = try? JSONDecoder().decode(UserRecord.self, from: userRecordData),
                          let userID = userRecord.userID else {
                        return
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        if self.batteryLevel != Int(roundf(self.interface.batteryLevel * 100)) && self.batteryCharging?.rawValue != self.interface.batteryState.rawValue {
                            self.batteryLevel = Int(roundf(self.interface.batteryLevel * 100))
                            self.batteryCharging = self.interface.batteryState
                            
                            Task {
                                if let batteryRecords: [FirestoreQueryRecord<BatteryLevelRecord>] = try? await self.service.querySingleField(collection: "batteryLevels", httpMethod: .post, seniorId: userID)  {
                                    
                                    if let specificBatteryRecord = batteryRecords.first(where: { $0.document?.fields?.seniorId?.stringValue == userID }) {
                                        guard let specificBatteryRecordDocumentName = specificBatteryRecord.document?.name else { return }
                                        let components = specificBatteryRecordDocumentName.components(separatedBy: "/")
                                        guard let specificBatteryRecordDocumentID = components.last else { return }
                                        
                                        let batteryLevelRecord1: BatteryLevelRecord = BatteryLevelRecord(seniorId: Description(stringValue: userID), watchBatteryLevel: Description(stringValue: self.batteryLevel?.description), iphoneBatteryLevel: Description(stringValue: specificBatteryRecord.document?.fields?.iphoneBatteryLevel?.stringValue), watchLastUpdatedAt: Description(stringValue: Date.now.description), iphoneLastUpdatedAt: Description(stringValue: specificBatteryRecord.document?.fields?.iphoneLastUpdatedAt?.stringValue), watchBatteryState: Description(stringValue: self.batteryCharging?.description), iphoneBatteryState: Description(stringValue: specificBatteryRecord.document?.fields?.iphoneBatteryState?.stringValue))
                                        
                                        try? await self.service.set(endPoint: SingleEndpoints.batteryLevels(batteryLevelsDocumentID: specificBatteryRecordDocumentID), fields: batteryLevelRecord1, httpMethod: .patch)
                                        self.isFirstTime = false
                                    } else {
                                        let batteryLevelRecord: BatteryLevelRecord = BatteryLevelRecord(seniorId: Description(stringValue: userID), watchBatteryLevel: Description(stringValue: self.batteryLevel?.description), watchLastUpdatedAt: Description(stringValue: Date.now.description), watchBatteryState: Description(stringValue: self.batteryCharging?.description))
                                        
                                        try? await self.service.set(endPoint: MultipleEndPoints.batteryLevels, fields: batteryLevelRecord, httpMethod: .post)
                                        self.isFirstTime = false
                                    }
                                    
                                } else {
                                    let batteryLevelRecord: BatteryLevelRecord = BatteryLevelRecord(seniorId: Description(stringValue: userID), watchBatteryLevel: Description(stringValue: self.batteryLevel?.description), watchLastUpdatedAt: Description(stringValue: Date.now.description), watchBatteryState: Description(stringValue: self.batteryCharging?.description))
                                    
                                    try? await self.service.set(endPoint: MultipleEndPoints.batteryLevels, fields: batteryLevelRecord, httpMethod: .post)
                                    self.isFirstTime = false
                                }
                            }
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        
        batterySubscription = Timer.publish(every: 900, on: .main, in: .common)
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
                        if let batteryRecords: [FirestoreQueryRecord<BatteryLevelRecord>] = try? await self.service.querySingleField(collection: "batteryLevels", httpMethod: .post, seniorId: userID) {
                            
                            if let specificBatteryRecord = batteryRecords.first(where: { $0.document?.fields?.seniorId?.stringValue == userID }) {
                                guard let specificBatteryRecordDocumentName = specificBatteryRecord.document?.name else { return }
                                let components = specificBatteryRecordDocumentName.components(separatedBy: "/")
                                guard let specificBatteryRecordDocumentID = components.last else { return }
                                
                                let batteryLevelRecord1: BatteryLevelRecord = BatteryLevelRecord(seniorId: Description(stringValue: userID), watchBatteryLevel: Description(stringValue: self.batteryLevel?.description), iphoneBatteryLevel: Description(stringValue: specificBatteryRecord.document?.fields?.iphoneBatteryLevel?.stringValue), watchLastUpdatedAt: Description(stringValue: Date.now.description), iphoneLastUpdatedAt: Description(stringValue: specificBatteryRecord.document?.fields?.iphoneLastUpdatedAt?.stringValue), watchBatteryState: Description(stringValue: specificBatteryRecord.document?.fields?.watchBatteryState?.stringValue), iphoneBatteryState: Description(stringValue: specificBatteryRecord.document?.fields?.iphoneBatteryState?.stringValue))
                                
                                try? await self.service.set(endPoint: SingleEndpoints.batteryLevels(batteryLevelsDocumentID: specificBatteryRecordDocumentID), fields: batteryLevelRecord1, httpMethod: .patch)
                            }
                            
                        }
                    }
                }
            }
        
        
        chargingStateSubscription = Timer.publish(every: 3, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let userRecordData = UserDefaults.standard.object(forKey: "user-auth") as? Data,
                      let userRecord = try? JSONDecoder().decode(UserRecord.self, from: userRecordData),
                      let userID = userRecord.userID, let self else {
                    return
                }
                
                if self.batteryCharging?.rawValue != self.interface.batteryState.rawValue && self.batteryLevel != nil && self.batteryCharging != nil && self.isFirstTime == false {
                    Task {
                        self.batteryCharging = self.interface.batteryState
                        
                        if let batteryRecords: [FirestoreQueryRecord<BatteryLevelRecord>] = try? await self.service.querySingleField(collection: "batteryLevels", httpMethod: .post, seniorId: userID) {
                            
                            if let specificBatteryRecord = batteryRecords.first(where: { $0.document?.fields?.seniorId?.stringValue == userID }) {
                                guard let specificBatteryRecordDocumentName = specificBatteryRecord.document?.name else { return }
                                let components = specificBatteryRecordDocumentName.components(separatedBy: "/")
                                guard let specificBatteryRecordDocumentID = components.last else { return }
                                
                                let batteryLevelRecord1: BatteryLevelRecord = BatteryLevelRecord(seniorId: Description(stringValue: userID), watchBatteryLevel: Description(stringValue: self.batteryLevel?.description), iphoneBatteryLevel: Description(stringValue: specificBatteryRecord.document?.fields?.iphoneBatteryLevel?.stringValue), watchLastUpdatedAt: Description(stringValue: Date.now.description), iphoneLastUpdatedAt: Description(stringValue: specificBatteryRecord.document?.fields?.iphoneLastUpdatedAt?.stringValue), watchBatteryState: Description(stringValue: self.batteryCharging?.description), iphoneBatteryState: Description(stringValue: specificBatteryRecord.document?.fields?.iphoneBatteryState?.stringValue))
                                
                                try? await self.service.set(endPoint: SingleEndpoints.batteryLevels(batteryLevelsDocumentID: specificBatteryRecordDocumentID), fields: batteryLevelRecord1, httpMethod: .patch)
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
                        let currentRange = ChargingRange(startCharging: Date.now, taskState: "ongoing")
                        let rangeCurrent: ChargingRangeRecord = ChargingRangeRecord(seniorId: Description(stringValue: userID), startCharging: Description(doubleValue: currentRange.startCharging?.timeIntervalSince1970), taskState: Description(stringValue: currentRange.taskState))
                        self.currentRange = currentRange
                        Task { try? await self.service.set(endPoint: MultipleEndPoints.charges, fields: rangeCurrent, httpMethod: .post) }
                    }
                case .unplugged:
                    if self.currentRange?.taskState == "ongoing" {
                        self.currentRange?.taskState = "ended"
                    }
                    
                    if self.currentRange?.taskState == "ended" {
                        guard let currentRange = self.currentRange else { return }
                        
                        if currentRange.getValidChargingRange(startCharging: currentRange.startCharging ?? .now, endCharging: currentRange.endCharging ?? .now) == true {
                            
                            Task {
                                if let chargingRecords: [FirestoreQueryRecord<ChargingRangeRecord>] = try? await self.service.queryMultipleFields(collection: "charges", httpMethod: .post, seniorId: userID) {
                                    
                                    guard let specificChargingRecord = chargingRecords.first(where: { $0.document?.fields?.seniorId?.stringValue == userID }) else { return }
                                    guard let specificChargingRecordDocumentName = specificChargingRecord.document?.name else { return }
                                    let components = specificChargingRecordDocumentName.components(separatedBy: "/")
                                    guard let specificChargingRecordDocumentID = components.last else { return }
                                    
                                    let updatedChargingRecord = ChargingRangeRecord(seniorId: Description(stringValue: specificChargingRecord.document?.fields?.seniorId?.stringValue), startCharging: Description(doubleValue: specificChargingRecord.document?.fields?.startCharging?.doubleValue), endCharging: Description(doubleValue: Date.now.timeIntervalSince1970), taskState: Description(stringValue: "ended"))
                                    try await self.service.set(endPoint: SingleEndpoints.charges(chargeDocumentID: specificChargingRecordDocumentID), fields: updatedChargingRecord, httpMethod: .patch)
                                    self.resetRanges()
                                }
                            }
                            
                        } else {
                            Task {
                                if let chargingRecords: [FirestoreQueryRecord<ChargingRangeRecord>] = try? await self.service.queryMultipleFields(collection: "charges", httpMethod: .post, seniorId: userID) {
                                    
                                    guard let specificChargingRecord = chargingRecords.first(where: { $0.document?.fields?.seniorId?.stringValue == userID }) else { return }
                                    guard let specificChargingRecordDocumentName = specificChargingRecord.document?.name else { return }
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
                case .none:
                    print("None")
                @unknown default:
                    print("Unknown")
                }
            }
            .store(in: &cancellables)
    }
}


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


