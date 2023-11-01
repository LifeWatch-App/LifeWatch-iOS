//
//  BatteryMonitorViewModel.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 28/10/23.
//

import Foundation
import Firebase
import Combine

final class BatteryMonitorViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let service = BatteryChargingService.shared
    @Published var batteryInfo: BatteryLevel?

    init() {
        service.observeBatteryStateLevelSpecific()
        setupSubscribers()
    }

    func setupSubscribers() {
        service.$documentChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                guard let self = self else { return }
                self.batteryInfo = self.loadInitialBatteryLevel(documents: documentChanges)
            }
            .store(in: &cancellables)
    }

    private func loadInitialBatteryLevel(documents: [DocumentChange]) -> BatteryLevel? {
        return try? documents.first?.document.data(as: BatteryLevel.self)
    }
}
