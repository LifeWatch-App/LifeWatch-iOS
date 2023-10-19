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
    private let service = DataService.shared
    @Published private(set) var batteryCharging: WKInterfaceDeviceBatteryState?
    @Published private(set) var currentRange: ChargingRange?
    @Published private(set) var watchReachable = false
    private let encoder = JSONEncoder()
    let watchConnectionManager = WatchConnectorManager()
    
    required init() {
        initializerFunction()
    }
    
    func initializerFunction() {
        interface.isBatteryMonitoringEnabled = true
        batteryCharging = interface.batteryState
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
    
    func handleBatteryStateChange(batteryState: WKInterfaceDeviceBatteryState, userID: String) {
        switch batteryState {
        case .charging:
            //perlu check lek misalle belum ada yang ongoing
            if self.currentRange == nil {
                self.currentRange = ChargingRange(startCharging: Date.now, taskState: "ongoing")
                let rangeCurrent: ChargingRangeRecord = ChargingRangeRecord(seniorId: Description(stringValue: userID), startCharging: Description(stringValue: self.currentRange?.startCharging?.description), taskState: Description(stringValue: self.currentRange?.taskState))
                Task { try? await service.set(endPoint: MultipleEndPoints.charges, fields: rangeCurrent, httpMethod: .post) }
            }
        default:
            guard let currentRange = self.currentRange else { return }
            
            if currentRange.getValidChargingRange(startCharging: currentRange.startCharging ?? .now, endCharging: currentRange.endCharging ?? .now) == true {
                self.chargingRangesForWatch.append(currentRange)
                Task {
                    if let chargingRecords: FirebaseRecords<ChargingRangeRecord> = try? await service.fetch(endPoint: MultipleEndPoints.charges, httpMethod: .get) {
                        
                        guard let specificChargingRecord = chargingRecords.documents.first(where: { $0.fields?.seniorId?.stringValue == userID && $0.fields?.startCharging?.stringValue == currentRange.startCharging?.description  }) else { return }
                        guard let specificChargingRecordDocumentName = specificChargingRecord.name else { return }
                        let components = specificChargingRecordDocumentName.components(separatedBy: "/")
                        guard let specificChargingRecordDocumentID = components.last else { return }
                        
                        let updatedIdleRecord = ChargingRangeRecord(seniorId: Description(stringValue: specificChargingRecord.fields?.seniorId?.stringValue), startCharging: Description(stringValue: specificChargingRecord.fields?.startCharging?.stringValue), endCharging: Description(stringValue: Date.now.description), taskState: Description(stringValue: "ended"))
                        try await service.set(endPoint: SingleEndpoints.charges(chargeDocumentID: specificChargingRecordDocumentID), fields: updatedIdleRecord, httpMethod: .patch)
                    }
                }
            } else {
                Task {
                    if let chargingRecords: FirebaseRecords<ChargingRangeRecord> = try? await service.fetch(endPoint: MultipleEndPoints.charges, httpMethod: .get) {
                        
                        guard let specificChargingRecord = chargingRecords.documents.first(where: { $0.fields?.seniorId?.stringValue == userID && $0.fields?.startCharging?.stringValue == currentRange.startCharging?.description  }) else { return }
                        guard let specificChargingRecordDocumentName = specificChargingRecord.name else { return }
                        let components = specificChargingRecordDocumentName.components(separatedBy: "/")
                        guard let specificChargingRecordDocumentID = components.last else { return }
                        
                        try await service.delete(endPoint: SingleEndpoints.charges(chargeDocumentID: specificChargingRecordDocumentID), httpMethod: .delete)
                    }
                }
            }
            resetRanges()
            
        }
    }
}


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


