//
//  AddRoutineViewModel.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 06/11/23.
//

import Foundation

class AddRoutineViewModel: ObservableObject {
    @Published var type = "Medicine"
    @Published var times: [Date] = [Date(), Date(), Date()]
    @Published var timeAmount = 1
    @Published var activity = ""
    @Published var description = ""
    @Published var medicine = ""
    @Published var medicineAmount = "" {
        didSet {
            let filtered = medicineAmount.filter { $0.isNumber }
            
            if medicineAmount != filtered {
                medicineAmount = filtered
            }
        }
    }
    @Published var medicineUnit: MedicineUnit = .Tablet
}

enum MedicineUnit: String, CaseIterable, Identifiable {
    var id: Self { self }
    case Tablet, Pill, Gram, Litre, Mililitre, CC
}
