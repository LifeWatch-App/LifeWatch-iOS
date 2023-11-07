//
//  CaregiverEmergencyViewModel.swift
//  YTeam
//
//  Created by Yap Justin on 18/10/23.
//

import Foundation
import Combine
import FirebaseAuth
import AVFoundation
import FirebaseStorage

class CaregiverDashboardViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate  {
    @Published var invites: [Invite] = []
    @Published var user: User?
    @Published var userData: UserData?
    private let service = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var showWalkieTalkie: Bool = false
    
    @Published var routines: [Routine] = []
    @Published var watchBattery: Double = 80
    @Published var watchIsCharging = true
    @Published var phoneBattery: Double = 90
    @Published var phoneIsCharging = false
    @Published var isActive = false
    @Published var inactivityTime = 30
    @Published var heartRate = 90
    @Published var location = "Outside"
    @Published var inviteEmail = ""

    override init() {
        super.init()
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
    
    func sendRequestToSenior() {
        AuthService.shared.sendRequestToSenior(email: inviteEmail)
    }
    
    func signOut() {
        AuthService.shared.signOut()
    }
}
