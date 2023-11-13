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
    let authService = AuthService.shared
    let batteryService = BatteryChargingService.shared
    @Published var batteryInfo: BatteryLevel?
    @Published var latestLocationInfo: LiveLocation?
    @Published var selectedInviteId: String?
    @Published var idleInfo: [Idle] = []
    @Published var heartBeatInfo: Heartbeat?
    @Published var latestSymptomInfo: Symptom?
    private var cancellables = Set<AnyCancellable>()
    @Published var showWalkieTalkie: Bool = false
    @Published var routines: [Routine] = []
    //    @Published var heartRate = 90
    @Published var inviteEmail = ""

    override init() {
        super.init()
        setupSubscribers()
        routines = routinesDummyData
    }

    private func setupSubscribers() {
        authService.$user
            .combineLatest(authService.$userData, authService.$invites)
            .sink { [weak self] user, userData, invites in
                guard let self = self else { return }
                if self.user != user {
                    self.user = user
                }

                if self.userData != userData {
                    self.userData = userData
                }

                if self.invites != invites {
                    self.invites = invites
                }
            }
            .store(in: &cancellables)

        authService.$selectedInviteId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedInviteId in
                guard let self = self else { return }
                if self.selectedInviteId != selectedInviteId {
                    self.selectedInviteId = selectedInviteId
                }
            }
            .store(in: &cancellables)

        $selectedInviteId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedInviteId in
                guard let self = self else { return }
                self.batteryService.observeIdleSpecific()
                self.batteryService.observeLiveLocationSpecific()
                self.batteryService.observeBatteryStateLevelSpecific()
                self.batteryService.observeHeartRateSpecific()
                self.batteryService.observeLatestSyptoms()
            }
            .store(in: &cancellables)

        batteryService.$symptomsLatestDocumentChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                guard let self = self else { return }
                self.latestSymptomInfo = self.loadLatestSymptom(documents: documentChanges)
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

        batteryService.$heartRateDocumentChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                guard let self = self else { return }
                self.heartBeatInfo = loadInitialHeartBeat(documents: documentChanges)
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

    private func loadLatestSymptom(documents: [DocumentChange]) -> Symptom? {
        return try? documents.first?.document.data(as: Symptom.self)
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

    private func loadInitialHeartBeat(documents: [DocumentChange]) -> Heartbeat? {
        return try? documents.first?.document.data(as: Heartbeat.self)
    }
}
