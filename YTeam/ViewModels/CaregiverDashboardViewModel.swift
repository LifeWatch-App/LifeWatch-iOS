//
//  CaregiverEmergencyViewModel.swift
//  YTeam
//
//  Created by Yap Justin on 18/10/23.
//

import Foundation
import Combine
import Firebase
import FirebaseAuth
import AVFoundation
import FirebaseStorage

class CaregiverDashboardViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate  {
    @Published var invites: [Invite] = []
    @Published var user: User?
    @Published var userData: UserData?
    private let authService = AuthService.shared 
    private let batteryService = BatteryChargingService.shared
    @Published var batteryInfo: BatteryLevel?
    @Published var latestLocationInfo: LiveLocation?
    @Published var idleInfo: [Idle] = []
    private var cancellables = Set<AnyCancellable>()

    @Published var showWalkieTalkie: Bool = false
    @Published var routines: [Routine] = []
    @Published var heartRate = 90
    @Published var location = "Outside"
    @Published var inviteEmail = ""

    override init() {
        super.init()
        batteryService.observeIdleSpecific()
        batteryService.observeLiveLocationSpecific()
        batteryService.observeBatteryStateLevelSpecific()
        setupSubscribers()
        // add dummy data
        routines = routinesDummyData
    }

    private func setupSubscribers() {
        authService.$user
            .combineLatest(authService.$userData, authService.$invites)
            .sink { [weak self] user, userData, invites in
                self?.user = user
                self?.userData = userData
                self?.invites = invites
            }
            .store(in: &cancellables)

        batteryService.$batteryDocumentChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                guard let self = self else { return }
                self.batteryInfo = self.loadInitialBatteryLevel(documents: documentChanges)
            }
            .store(in: &cancellables)

        batteryService.$idleDocumentChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                guard let self = self else { return }
                self.idleInfo = self.loadInitialIdleLevel(documents: documentChanges)
            }
            .store(in: &cancellables)

        batteryService.$latestLocationDocumentChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                guard let self = self else { return }
                self.latestLocationInfo = self.loadLatestLiveLocation(documents: documentChanges)
            }
            .store(in: &cancellables)
    }
    
    func sendRequestToSenior() {
        AuthService.shared.sendRequestToSenior(email: inviteEmail)
    }
    
    func signOut() {
        AuthService.shared.signOut()
    }

    private func loadLatestLiveLocation(documents: [DocumentChange]) -> LiveLocation? {
        return try? documents.first?.document.data(as: LiveLocation.self)
    }

    private func loadInitialBatteryLevel(documents: [DocumentChange]) -> BatteryLevel? {
        return try? documents.first?.document.data(as: BatteryLevel.self)
    }

    private func loadInitialIdleLevel(documents: [DocumentChange]) -> [Idle] {
        var idles: [Idle] = []
        for document in documents {
            guard let document = try? document.document.data(as: Idle.self) else {
                print("Not able to decode")
                return []
            }
            idles.append(document)
        }

        return idles
    }
}
