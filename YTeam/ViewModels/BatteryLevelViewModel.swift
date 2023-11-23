//
//  BatteryLevelStateManager.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 24/10/23.
//

import Foundation
import Combine
import SwiftUI
import Firebase

@MainActor
final class BatteryLevelStateViewModel: ObservableObject {
    private let interface = UIDevice.current
    private var cancellables = Set<AnyCancellable>()
    private var batterySubscription: AnyCancellable?
    private var chargingStateSubscription: AnyCancellable?
    private let chargingService: BatteryChargingService = BatteryChargingService.shared
    private let authService: AuthService = AuthService()
    @Published private(set) var batteryLevel: Int?
    @Published private(set) var batteryCharging: UIDevice.BatteryState?
    @Published private(set) var currentRange: ChargingRange?
    @Published private(set) var isFirstTime: Bool = true
    
    init() {
        initializerFunction()
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
    }
    
    private func resetRanges() {
        currentRange = nil
    }
    
    func startCharging() {
        batteryCharging = .charging
    }
    
    func stopCharging() {
        batteryCharging = .unplugged
    }
    
    func testCreateBatteryLevel() async throws {
        try await chargingService.createBatteryLevel(batteryLevel: 50)
    }
    
    func testFetchBatteryLevel() async throws {
        let testBatteryLevels = try await chargingService.fetchBatteryLevel()
        print(testBatteryLevels)
    }
    
    func testUpdateBatteryLevel() async throws {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        if let batteryRecords = try? await self.chargingService.fetchBatteryLevel() {
            guard let specificBatteryRecord = batteryRecords.first(where: { $0.seniorId == userID }) else { return }
            let batteryLevel = BatteryLevel(seniorId: userID, watchBatteryLevel: specificBatteryRecord.watchBatteryLevel, iphoneBatteryLevel: "50", watchLastUpdatedAt: specificBatteryRecord.watchLastUpdatedAt, iphoneLastUpdatedAt: Date.now.description, watchBatteryState: specificBatteryRecord.watchBatteryState, iphoneBatteryState: specificBatteryRecord.iphoneBatteryState)
            try await chargingService.updateBatteryLevel(batteryLevel: batteryLevel)
        }
    }
    
    func setupSubscribers() {
        $isFirstTime
            .receive(on: DispatchQueue.main)
            .sink { [weak self] firstTime in
                guard let self = self else { return }
                guard let userID = Auth.auth().currentUser?.uid else { return }
                if firstTime {
                    if self.batteryLevel != Int(roundf(interface.batteryLevel * 100)) {
                        
                        
                        self.batteryLevel = Int(roundf(self.interface.batteryLevel * 100))
                        
                        
                        Task {
                            if let batteryRecords = try? await self.chargingService.fetchBatteryLevel(), !batteryRecords.isEmpty {
                                
                                if let specificBatteryRecord = batteryRecords.first(where: { $0.seniorId == userID }) {
                                    let batteryLevel = BatteryLevel(seniorId: userID, watchBatteryLevel: specificBatteryRecord.watchBatteryLevel, iphoneBatteryLevel: self.batteryLevel?.description, watchLastUpdatedAt: specificBatteryRecord.watchLastUpdatedAt, iphoneLastUpdatedAt: Date.now.description, watchBatteryState: specificBatteryRecord.watchBatteryState, iphoneBatteryState: specificBatteryRecord.iphoneBatteryState)
                                    
                                    try await self.chargingService.updateBatteryLevel(batteryLevel: batteryLevel)
                                    self.isFirstTime = false
                                    print("Success updating battery levels")
                                } else {
                                    try await self.chargingService.createBatteryLevel(batteryLevel: self.batteryLevel ?? 0)
                                    self.isFirstTime = false
                                    print("Success creating battery levels")
                                }
                                
                            } else {
                                try await self.chargingService.createBatteryLevel(batteryLevel: self.batteryLevel ?? 0)
                                self.isFirstTime = false
                                print("Success creating battery levels")
                            }
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        batterySubscription = Timer.publish(every: 895, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                guard let userID = Auth.auth().currentUser?.uid else { return }
                
                if self.batteryLevel != Int(roundf(interface.batteryLevel * 100)) {
                    
                    
                    self.batteryLevel = Int(roundf(self.interface.batteryLevel * 100))
                    
                    
                    Task {
                        if let batteryRecords = try? await self.chargingService.fetchBatteryLevel(), !batteryRecords.isEmpty {
                            
                            if let specificBatteryRecord = batteryRecords.first(where: { $0.seniorId == userID }) {
                                let batteryLevel = BatteryLevel(seniorId: userID, watchBatteryLevel: specificBatteryRecord.watchBatteryLevel, iphoneBatteryLevel: self.batteryLevel?.description, watchLastUpdatedAt: specificBatteryRecord.watchLastUpdatedAt, iphoneLastUpdatedAt: Date.now.description, watchBatteryState: specificBatteryRecord.watchBatteryState, iphoneBatteryState: specificBatteryRecord.iphoneBatteryState)
                                
                                try await self.chargingService.updateBatteryLevel(batteryLevel: batteryLevel)
                                print("Success updating battery levels")
                            } else {
                                try await self.chargingService.createBatteryLevel(batteryLevel: self.batteryLevel ?? 0)
                                print("Success creating battery levels")
                            }
                            
                        } else {
                            try await self.chargingService.createBatteryLevel(batteryLevel: self.batteryLevel ?? 0)
                            print("Success creating battery levels")
                        }
                    }
                }
            })
        
        chargingStateSubscription = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                guard let userID = Auth.auth().currentUser?.uid else { return }
                
                if self.batteryCharging?.description != self.interface.batteryState.description && self.batteryLevel != nil && self.isFirstTime == false {
                    
                    self.batteryCharging = self.interface.batteryState
                    
                    Task {
                        if let batteryRecords = try? await self.chargingService.fetchBatteryLevel() {
                            
                            guard let specificBatteryRecord = batteryRecords.first(where: { $0.seniorId == userID }) else {
                                print("Can't find specific battery record")
                                return }
                            
                            let batteryLevelRecord: BatteryLevel = BatteryLevel(seniorId: userID, watchBatteryLevel: specificBatteryRecord.watchBatteryLevel, iphoneBatteryLevel: self.batteryLevel?.description, watchLastUpdatedAt: specificBatteryRecord.watchLastUpdatedAt, iphoneLastUpdatedAt: Date.now.description, watchBatteryState: specificBatteryRecord.watchBatteryState, iphoneBatteryState: self.batteryCharging?.description)
                            
                            try await self.chargingService.updateBatteryLevel(batteryLevel: batteryLevelRecord)
                            print("Success updating batteryState")
                        }
                    }
                }
            }
    }
    
    func cancelBatteryMonitoringIphone() {
        batterySubscription?.cancel()
        batterySubscription = nil
        chargingStateSubscription?.cancel()
        chargingStateSubscription = nil
        
        print("Battery subsription cancelled")
        
    }
    
}

extension UIDevice.BatteryState {
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
    
    static func getBatteryStateFromString(string: String) -> UIDevice.BatteryState? {
        var intEquivalent = 1
        
        if string == "unknown" {
            intEquivalent = 0
        } else if string == "unplugged" {
            intEquivalent = 1
        } else if string == "full" {
            intEquivalent = 3
        } else if string == "charging" {
            intEquivalent = 2
        } else {
            intEquivalent = 1
        }
        
        let state = UIDevice.BatteryState(rawValue: intEquivalent)
        return state
    }
}
