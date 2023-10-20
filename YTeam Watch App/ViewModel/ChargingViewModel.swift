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
    private var timerSubscription: AnyCancellable?
    private let service = DataService.shared
    @Published private(set) var batteryCharging: WKInterfaceDeviceBatteryState?
    @Published private(set) var currentRange: ChargingRange?
    @Published private(set) var watchReachable = false
    private let encoder = JSONEncoder()
    
    required init() {
        initializerFunction()
        setupSubscribers()
    }
    
    deinit {
        timerSubscription?.cancel()
        timerSubscription = nil
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
        timerSubscription = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                if self?.batteryCharging != self?.interface.batteryState {
                    self?.batteryCharging = self?.interface.batteryState
                }
            }
        
        $batteryCharging
            .receive(on: DispatchQueue.main)
            .sink { [weak self] batteryState in
                guard let batteryState, let self, let userIData = UserDefaults.standard.object(forKey: "user-auth") else { return }
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
        default:
            return "Not Charging!!"
        }
    }
}


