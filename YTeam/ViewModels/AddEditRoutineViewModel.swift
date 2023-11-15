//
//  AddRoutineViewModel.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 06/11/23.
//

import Foundation
import FirebaseAuth

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
    
    private var routine: RoutineData = RoutineData()
    private let routineService: RoutineService = RoutineService.shared
    
    func convertRoutineDataIntoRoutine(editOrAdd: String) {
        print("Edit or Add: ", editOrAdd)
        guard let seniorId = Auth.auth().currentUser?.uid else { return }
                
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
            self.routine = RoutineData(id: UUID().uuidString, seniorId: seniorId, type: self.type, time: unixArray, activity: self.activity, description: self.description, medicine: self.medicine, medicineAmount: self.medicineAmount, medicineUnit: unitMedicine, isDone: isDoneArray)
            
            Task {await self.sendRoutine()}
        }
        
        if (editOrAdd == "edit") {
            self.routine = RoutineData(id: routineId, seniorId: seniorId, type: self.type, time: unixArray, activity: self.activity, description: self.description, medicine: self.medicine, medicineAmount: self.medicineAmount, medicineUnit: unitMedicine, isDone: isDoneArray)
            
            Task {await self.updateRoutine()}
        }
    }
    
    func sendRoutine() async {
        Task {try? await self.routineService.sendRoutine(routine: self.routine)}
    }
    
    func updateRoutine() async {
        Task {try? await self.routineService.updateRoutine(routine: self.routine)}
    }
}

enum MedicineUnit: String, CaseIterable, Identifiable {
    var id: Self { self }
    case Tablet, Pill, Gram, Litre, Mililitre, CC
}
