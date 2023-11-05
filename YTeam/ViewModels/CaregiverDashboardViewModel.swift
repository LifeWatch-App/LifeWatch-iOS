//
//  CaregiverEmergencyViewModel.swift
//  YTeam
//
//  Created by Yap Justin on 18/10/23.
//

import Foundation
import Combine
import FirebaseAuth

class CaregiverDashboardViewModel: ObservableObject {
    @Published var invites: [Invite] = []
    @Published var user: User?
    @Published var userData: UserData?
    private let service = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var routines: [Routine] = []
    @Published var watchBattery: Double = 80
    @Published var watchIsCharging = true
    @Published var phoneBattery: Double = 90
    @Published var phoneIsCharging = false
    @Published var isActive = false
    @Published var inactivityTime = 30
    @Published var heartRate = 90
    @Published var location = "Outside"

    init() {
        setupSubscribers()
        
        // add dummy data
        routines = routinesDummyData
    }

    private func setupSubscribers() {
        service.$user
            .combineLatest(service.$userData, service.$invites)
            .sink { [weak self] user, userData, invites in
                self?.user = user
                self?.userData = userData
                self?.invites = invites
            }
            .store(in: &cancellables)
    }
    
    func sendRequestToSenior(email: String) {
        AuthService.shared.sendRequestToSenior(email: email)
    }
    
    func signOut() {
        AuthService.shared.signOut()
    }
}
