//
//  ProfileViewModel.swift
//  YTeam
//
//  Created by Yap Justin on 26/10/23.
//

import Foundation
import FirebaseAuth
import Combine

class ProfileViewModel: ObservableObject {
    @Published var password = ""
    @Published var loginProviders: [String] = []
    @Published var user: User?
    @Published var userData: UserData?
    @Published var invites: [Invite] = []
    private let service = AuthService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSubscribers()
    }

    private func setupSubscribers() {
        service.$loginProviders
            .combineLatest(service.$invites, service.$userData, service.$user)
            .sink { [weak self] loginProviders, invites, userData, user in
                self?.loginProviders = loginProviders
                self?.invites = invites
                for invite in invites {
                    print("Invites", invite)
                }
                self?.userData = userData
                self?.user = user
            }
            .store(in: &cancellables)
    }

    func signOut() {
        UserDefaults.standard.removeObject(forKey: "selectedSenior")
        FallService.shared.deinitializerFunction()
        SOSService.shared.deinitializerFunction()
        InactivityService.shared.deinitializerFunction()
        HeartAnomalyService.shared.deinitializerFunction()
        HeartbeatService.shared.deinitializerFunction()
        LocationService.shared.deinitializerFunction()
        BatteryChargingService.shared.deinitializerFunction()
        DashboardLocationService.shared.deinitializerFunction()
        HeartRateService.shared.deinitializerFunction()
        IdleService.shared.deinitializerFunction()
        RoutineService.shared.deinitializerFunction()
        SymptomService.shared.deinitializerFunction()
        AuthService.shared.signOut()
    }

    func deleteAccountWithPassword() {
        AuthService.shared.deleteAccountWithPassword(password: password)
    }

    func deleteAccountWithApple() {
        AuthService.shared.deleteAccountWithApple()
    }

    func acceptInvite(id: String) {
        AuthService.shared.acceptInvite(id: id)
    }

    func denyInvite(id: String) {
        AuthService.shared.denyInvite(id: id)
    }
}
