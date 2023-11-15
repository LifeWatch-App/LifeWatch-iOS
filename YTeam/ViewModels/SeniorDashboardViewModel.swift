//
//  SeniorEmergencyViewModel.swift
//  YTeam
//
//  Created by Yap Justin on 18/10/23.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseStorage
import Firebase
import AVFoundation

class SeniorDashboardViewModel: ObservableObject {
    @Published var invites: [Invite] = []
    @Published var user: User?
    @Published var userData: UserData?
    private let service = AuthService.shared
    private let symptomService = SymptomService.shared
    private let sosService: SOSService = SOSService.shared
    private var cancellables = Set<AnyCancellable>()

    @Published var showAddSymptom: Bool = false
    @Published var showSOS: Bool = false
    @Published var showWalkieTalkie: Bool = false

    @Published var routines: [Routine] = []
    @Published var symptoms: [Symptom] = []

    init() {
        setupSubscribers()
        symptomService.observeSyptoms()
        routines = routinesDummyData
        //        symptoms = symptomsDummyData
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

       symptomService.$symptomsDocumentChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                guard let self = self else { return }
                self.symptoms.insert(contentsOf: self.loadInitialSymptoms(documents: documentChanges), at: 0)
            }
            .store(in: &cancellables)
    }

    func sendSOS() throws {
        Task{ try? await sosService.sendSOS() }
    }

    func acceptInvite(id: String) {
        AuthService.shared.acceptInvite(id: id)
    }

    func denyInvite(id: String) {
        AuthService.shared.denyInvite(id: id)
    }

    func signOut() {
        AuthService.shared.signOut()
    }

    private func loadInitialSymptoms(documents: [DocumentChange]) -> [Symptom] {
        var symptoms: [Symptom] = []
        for document in documents {
            do {
                let symptom = try document.document.data(as: Symptom.self)
                symptoms.append(symptom)
            } catch {
                print("Error: \(error)")
            }
        }
        return symptoms
    }
}
