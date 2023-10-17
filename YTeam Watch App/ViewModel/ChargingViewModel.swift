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
    @Published private(set) var batteryCharging: WKInterfaceDeviceBatteryState?
    @Published private(set) var currentRange: ChargingRange?
    @Published private(set) var watchReachable = false
//    @Published private(set) var userRecord: UserRecord?
    let watchConnectionManager = WatchConnectorManager()

    required init() {
        initializerFunction()
    }

    func initializerFunction() {
        interface.isBatteryMonitoringEnabled = true
        batteryCharging = interface.batteryState

        if self.watchConnectionManager.session.isReachable {
            print("WatchOS - Watch is available")
            self.watchReachable = true
        } else {
            print("WatchOs - Watch is unavailable")
            self.watchReachable = false
        }
    }

//    func checkRecord() {
//        watchConnectionManager.$userRecord
//            .receive(on: DispatchQueue.main)
//            .sink { record in
//                self?.userRecord = record
//            }
//            .store(in: &cancellables)
//    }

    func resetRanges() {
        currentRange = nil
    }

    func startCharging() {
        batteryCharging = .charging
    }

    func stopCharging() {
        batteryCharging = .unplugged
    }

    func handleBatteryStateChange(_ batteryState: WKInterfaceDeviceBatteryState) {
        switch batteryState {
        case .charging:
            if self.currentRange == nil {
                self.currentRange = ChargingRange(startCharging: .now, taskState: .ongoing)
            }
        default:
            if self.currentRange?.taskState == .ongoing {
                self.currentRange?.endCharging = .now
                self.currentRange?.taskState = .ended
            }

            if self.currentRange?.taskState == .ended {
                guard let currentRange = self.currentRange else { return }

                if currentRange.getValidChargingRange(startCharging: currentRange.startCharging ?? .now, endCharging: currentRange.endCharging ?? .now) == true {
                    self.chargingRangesForWatch.append(currentRange)
                    let encoder = JSONEncoder()
                    if let encodedRanges = try? encoder.encode(self.chargingRangesForWatch) {
                        self.watchConnectionManager.session.sendMessage(["charging_history": encodedRanges], replyHandler: nil)
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


