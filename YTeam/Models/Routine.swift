//
//  Routine.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 04/11/23.
//

import Foundation

struct Routine: Identifiable, Equatable, Codable {
    var id: String = ""
    var type: String  = ""
    var seniorId: String?
    var time: [Date] = []
    var activity: String?
    var description: String?
    var medicine: String?
    var medicineAmount: String?
    var medicineUnit: MedicineUnit?
    var isDone: [Bool] = []
}

//    var isDone: [Bool] = [false, false, false]
//    var time: [Date] = [Date(), Date(), Date()]
// dummy data
let routinesDummyData: [Routine] = [
    Routine(type: "Medicine", time: [Date(), Date()], medicine: "OBH Combi", medicineAmount: "200", medicineUnit: .Mililitre, isDone: [true, false]),
    Routine(type: "Medicine", time: [Date()], medicine: "Panadol", medicineAmount: "2", medicineUnit: .Tablet, isDone: [true]),
    Routine(type: "Activity", time: [Date()], activity: "Jogging", description: "10 km", isDone: [false]),
    Routine(type: "Activity", time: [Date(), Date(), Date()], activity: "Eat", description: "Order from Gofood Delivery", isDone: [true, false, false]),
]

let routinesDummyDataSkeleton: [Routine] = [
    Routine(id: UUID().uuidString, type: "Medicine", time: [Date(), Date()], medicine: "OBH Combi", medicineAmount: "200", medicineUnit: .Mililitre, isDone: [true, false]),
    Routine(id: UUID().uuidString, type: "Activity", time: [Date(), Date(), Date()], activity: "Eat", description: "Order from Gofood Delivery", isDone: [true, false, false])
]

let routinesDummyDataSkeleton2: [Routine] = [
    Routine(id: UUID().uuidString, type: "Medicine", time: [Date(), Date(), Date()], medicine: "OBH Combi", medicineAmount: "200", medicineUnit: .Mililitre, isDone: [true, false, false]),
    Routine(id: UUID().uuidString, type: "Activity", time: [Date(), Date(), Date()], activity: "Eat", description: "Order from Gofood Delivery", isDone: [true, false, false])
]
