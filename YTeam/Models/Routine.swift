//
//  Routine.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 04/11/23.
//

import Foundation

struct Routine: Identifiable {
    var id = UUID()
    var type = ""
    var time: Date = Date()
    var activity: String?
    var description: String?
    var medicine: String?
    var medicineAmount: String?
    var medicineUnit: MedicineUnit?
    var isDone: Bool = false
}

// dummy data
let routinesDummyData: [Routine] = [
    Routine(type: "Medicine", time: Date(), medicine: "OBH Combi", medicineAmount: "200", medicineUnit: .Mililitre, isDone: true),
    Routine(type: "Medicine", time: Date(), medicine: "OBH Combi", medicineAmount: "200", medicineUnit: .Mililitre, isDone: true),
    Routine(type: "Medicine", time: Date(), medicine: "Panadol", medicineAmount: "2", medicineUnit: .Tablet, isDone: true),
    Routine(type: "Activity", time: Date(), activity: "Jogging", description: "10 km", isDone: true),
    Routine(type: "Activity", time: Date(), activity: "Eat", description: "Order from Gofood Delivery", isDone: true),
    Routine(type: "Activity", time: Date(), activity: "Eat", description: "Order from Gofood Delivery", isDone: false),
    Routine(type: "Activity", time: Date(), activity: "Eat", description: "Order from Gofood Delivery", isDone: false),
]
