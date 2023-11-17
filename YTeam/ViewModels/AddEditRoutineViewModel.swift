//
//  AddRoutineViewModel.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 06/11/23.
//

import Foundation
import FirebaseAuth
import Combine

class AddEditRoutineViewModel: ObservableObject {
    @Published var type = "Medicine"
    @Published var times: [Date] = [Date(), Date(), Date()]
    @Published var timeAmount = 1
    @Published var activity = ""
    @Published var description = ""
    @Published var medicine = ""
    @Published var routineId = ""
    @Published var medicineAmount = "" {
        didSet {
            let filtered = medicineAmount.filter { $0.isNumber }
            
            if medicineAmount != filtered {
                medicineAmount = filtered
            }
        }
    }
    @Published var medicineUnit: MedicineUnit = .Tablet
    @Published var selectedUserId: String?
    
    private var routineService: RoutineService = RoutineService.shared
    private var routine: RoutineData = RoutineData()
    private var cancellables = Set<AnyCancellable>()
    private var user: UserData?
    private let authService = AuthService.shared
    init() {
        setupAuth()
    }
    
    func setupAuth() {
        authService.$selectedInviteId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] id in
                if self?.selectedUserId != id && id != nil {
                    self?.selectedUserId = id
                }
            }
            .store(in: &cancellables)

        $selectedUserId
            .combineLatest(authService.$userData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] id, userData in
                if id != nil && userData != nil {
                    self?.user = userData
                }
            }
            .store(in: &cancellables)
    }
    
    func convertRoutineDataIntoRoutine(editOrAdd: String) {
        
        let seniorId: String?
        if user?.role == "caregiver" {
            seniorId = UserDefaults.standard.string(forKey: "selectedSenior")
        } else {
            seniorId = Auth.auth().currentUser?.uid
        }
        
        var unixArray: [Double] = []
        var unitMedicine: String
        var isDoneIndex: Int = 0
        var isDoneArray: [Bool] = []
        var timeIndex: Int = 0
        
        while (timeIndex < self.timeAmount){
            unixArray.append(self.times[timeIndex].timeIntervalSince1970)
            timeIndex += 1
        }
        
        switch (self.medicineUnit) {
        case .Tablet:
            unitMedicine = "Tablet"
        case .Pill:
            unitMedicine = "Pill"
        case .Gram:
            unitMedicine = "Gram"
        case .Litre:
            unitMedicine = "Litre"
        case .Mililitre:
            unitMedicine = "Mililitre"
        case .CC:
            unitMedicine = "CC"
        }
        
        while (isDoneIndex < self.timeAmount) {
            isDoneArray.append(false)
            isDoneIndex += 1
        }
        
        
        
        if (editOrAdd == "add") {
            self.routine = RoutineData(id: UUID().uuidString, seniorId: seniorId ?? "", type: self.type, time: unixArray, activity: self.activity, description: self.description, medicine: self.medicine, medicineAmount: self.medicineAmount, medicineUnit: unitMedicine, isDone: isDoneArray)
            
            Task {await self.sendRoutine()}
        }
        
        if (editOrAdd == "edit") {
            self.routine = RoutineData(id: routineId, seniorId: seniorId ?? "", type: self.type, time: unixArray, activity: self.activity, description: self.description, medicine: self.medicine, medicineAmount: self.medicineAmount, medicineUnit: unitMedicine, isDone: isDoneArray)
            
            Task {await self.updateRoutine()}
        }
        
        if (editOrAdd == "delete") {
            self.routine = RoutineData(id: routineId, seniorId: seniorId ?? "", type: self.type, time: unixArray, activity: self.activity, description: self.description, medicine: self.medicine, medicineAmount: self.medicineAmount, medicineUnit: unitMedicine, isDone: isDoneArray)
            
            Task {await self.deleteRoutine()}
        }
    }
    
    func sendRoutine() async {
        Task {try? await self.routineService.sendRoutine(routine: self.routine)}
    }
    
    func updateRoutine() async {
        Task {try? await self.routineService.updateRoutine(routine: self.routine)}
    }
    
    func deleteRoutine() async {
        Task {try? await self.routineService.deleteRoutine(routine: self.routine)}
    }
}

enum MedicineUnit: String, CaseIterable, Identifiable {
    var id: Self { self }
    case Tablet, Pill, Gram, Litre, Mililitre, CC
}
