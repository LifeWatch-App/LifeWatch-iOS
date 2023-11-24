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
    
    func setupSubscribers() {
        $isFirstTime
            .receive(on: DispatchQueue.main)
            .sink { [weak self] firstTime in
                guard let self = self else { return }
                guard let userID = Auth.auth().currentUser?.uid else { return }
                if firstTime {
                    if self.batteryLevel != Int(roundf(interface.batteryLevel * 100)) && self.batteryCharging?.description != self.interface.batteryState.description {
                        
                        self.batteryCharging = self.interface.batteryState
                        self.batteryLevel = Int(roundf(self.interface.batteryLevel * 100))
                        
                        
                        Task {
                            if let batteryRecords = try? await self.chargingService.fetchBatteryLevel(), !batteryRecords.isEmpty {
                                
                                if let specificBatteryRecord = batteryRecords.first(where: { $0.seniorId == userID }) {
                                    let batteryLevel = BatteryLevel(seniorId: userID, watchBatteryLevel: specificBatteryRecord.watchBatteryLevel, iphoneBatteryLevel: self.batteryLevel?.description, watchLastUpdatedAt: specificBatteryRecord.watchLastUpdatedAt, iphoneLastUpdatedAt: Date.now.description, watchBatteryState: specificBatteryRecord.watchBatteryState, iphoneBatteryState: self.batteryCharging?.description)
                                    
                                    try await self.chargingService.updateBatteryLevel(batteryLevel: batteryLevel)
                                    self.isFirstTime = false
                                    print("Success updating battery first time")
                                } else {
                                    let batteryLevel = BatteryLevel(seniorId: userID, iphoneBatteryLevel: self.batteryLevel?.description, iphoneLastUpdatedAt: Date.now.description, iphoneBatteryState: self.batteryCharging?.description)
                                    try await self.chargingService.createBatteryLevel(batteryLevel: batteryLevel)
                                    self.isFirstTime = false
                                    print("Success creating battery first time")
                                }
                                
                            } else {
                                let batteryLevel = BatteryLevel(seniorId: userID, iphoneBatteryLevel: self.batteryLevel?.description, iphoneLastUpdatedAt: Date.now.description, iphoneBatteryState: self.batteryCharging?.description)
                                try await self.chargingService.createBatteryLevel(batteryLevel: batteryLevel)
                                self.isFirstTime = false
                                print("Success creating battery first time")
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
                            }
                        }
                    }
                }
            })
        
        chargingStateSubscription = Timer.publish(every: 3, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                guard let userID = Auth.auth().currentUser?.uid else { return }
                
                if self.batteryCharging?.description != self.interface.batteryState.description && self.batteryLevel != nil && self.isFirstTime == false && self.batteryCharging != nil {
                    
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
