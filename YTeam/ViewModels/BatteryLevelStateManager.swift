//
//  BatteryLevelStateManager.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 24/10/23.
//

import Foundation
import Combine
import SwiftUI


final class BatteryLevelStateViewModel: ObservableObject {
    private let interface = UIDevice.current
    @Published private(set) var userData: UserData?
    private(set) var chargingRangesForWatch: [ChargingRange] = []
    private var cancellables = Set<AnyCancellable>()
    private var batterySubscription: AnyCancellable?
    private let chargingService: BatteryChargingService = BatteryChargingService.shared
    private let authSerivce: AuthService = AuthService()
    @Published private(set) var batteryLevel: Int?
    @Published private(set) var batteryCharging: UIDevice.BatteryState = .unplugged
    @Published private(set) var currentRange: ChargingRange?

    init() {
        initializerFunction()
        setupSubscribers()
    }

    deinit {
        batterySubscription?.cancel()
        batterySubscription = nil
    }

    private func initializerFunction() {
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

    private func setupSubscribers() {
        authSerivce.$userData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userData in
                self?.userData = userData
            }
            .store(in: &cancellables)

        if self.userData?.role == "senior" {
            batterySubscription = Timer.publish(every: 5, on: .main, in: .common)
                .autoconnect()
                .sink(receiveValue: { [weak self] _ in
                    guard let self = self else { return }

                    if self.batteryLevel != Int(roundf(interface.batteryLevel * 100)) {
                        self.batteryLevel = Int(roundf(interface.batteryLevel * 100))

                        //TODO: Fetch Data from firebase to check if the record exists
                        //TODO: If the record doesnt exist create a new one

                        
                    }
                })
        }
    }

}
