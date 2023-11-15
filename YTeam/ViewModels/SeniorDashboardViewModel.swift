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
    
    private var routineData: [RoutineData] = []
    private let routineService: RoutineService = RoutineService.shared
    
    init() {
        setupSubscribers()
        symptomService.observeSymptomsToday()
        // add dummy data
//        routines = routinesDummyData
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
        
        routineService.$routines
            .receive(on: DispatchQueue.main)
            .sink { [weak self] routines in
                guard let self else { return }
                for (_, routine) in routines.enumerated() {
                    if let concurrentIndex = self.routineData.firstIndex(where: {$0.id == routine.id}) {
                        self.routineData[concurrentIndex] = routine
                    } else {
                        self.routineData.append(routine)
                    }
                    self.convertRoutineDataToRoutine()
                }
            }
            .store(in: &cancellables)
        
        symptomService.$symptomsDocumentChangesToday
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                guard let self = self else { return }
                self.symptoms.insert(contentsOf: self.loadInitialSymptoms(documents: documentChanges), at: 0)
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
        
        if (self.routines.count > 1) {
            self.routines.sort { (routine1, routine2) -> Bool in
                let time1 = routine1.time[0]
                let time2 = routine2.time[0]
                
                return time1 < time2
            }
        }
      
        symptomService.$symptomsDocumentChangesToday
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                print(documentChanges)
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
