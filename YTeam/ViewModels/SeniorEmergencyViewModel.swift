//
//  SeniorEmergencyViewModel.swift
//  YTeam
//
//  Created by Yap Justin on 18/10/23.
//

import Foundation
import Combine
import FirebaseAuth

class SeniorEmergencyViewModel: ObservableObject {
    @Published var invites: [Invite] = []
    @Published var user: User?
    @Published var userData: UserData?
    private let service = AuthService.shared
    private let sosService: SOSService = SOSService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSubscribers()
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
    
    func sendSOS() {
        Task {try? await sosService.sendSOS()}
    }
    
    func acceptInvite(id: String) {
        AuthService.shared.acceptInvite(id: id)
    }
    
    func signOut() {
        AuthService.shared.signOut()
    }

}
