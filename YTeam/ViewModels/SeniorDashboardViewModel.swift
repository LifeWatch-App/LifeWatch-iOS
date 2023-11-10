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
import AVFoundation

class SeniorDashboardViewModel: ObservableObject {
    @Published var invites: [Invite] = []
    @Published var user: User?
    @Published var userData: UserData?
    private let service = AuthService.shared
    private let sosService: SOSService = SOSService.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var showAddSymptom: Bool = false
    @Published var showSOS: Bool = false
    @Published var showWalkieTalkie: Bool = false
    
    @Published var routines: [Routine] = []
    @Published var symptoms: [Symptom] = []
    
    private var routineData: [RoutineData] = []
    private let routineService: RoutineService = RoutineService.shared
    
    init() {
        setupSubscribers()
        
        // add dummy data
        routines = routinesDummyData
        symptoms = symptomsDummyData
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
        
        routineService.$routines
            .receive(on: DispatchQueue.main)
            .sink { [weak self] routine in
                guard let self else { return }
                
                self.routineData.append(contentsOf: routine)
                self.convertRoutineDataToRoutine()
            }
            .store(in: &cancellables)
    }
    
    func convertRoutineDataToRoutine() {
        self.routines = self.routineData.map { routine in
            var medicineUnit: MedicineUnit
            var routineTime: [Date] = []
            
            for time in routine.time {
                routineTime.append( Date(timeIntervalSince1970: time))
            }
            
            switch (routine.medicineUnit) {
            case "CC":
                medicineUnit = .CC
            case "Pill":
                medicineUnit = .Pill
            case "Gram":
                medicineUnit = .Gram
            case "Litre":
                medicineUnit = .Litre
            case "Mililitre":
                medicineUnit = .Mililitre
            default:
                medicineUnit = .Tablet
            }
            
            return Routine(id: routine.id, type: routine.type, time: routineTime, activity: routine.activity, description: routine.description, medicine: routine.medicine, medicineAmount: routine.medicineAmount, medicineUnit: medicineUnit, isDone: routine.isDone)
        }
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
}
