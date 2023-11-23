//
//  RoutineData.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 09/11/23.
//

import Foundation
import FirebaseFirestoreSwift

struct RoutineData: Codable, Hashable {
    var id: String = ""
    var seniorId: String = ""
    var type: String = ""
    var time: [Double] = []
    var activity: String = ""
    var description: String = ""
    var medicine: String = ""
    var medicineAmount: String = ""
    var medicineUnit: String = ""
    var isDone: [Bool] = []
    var uuid: [UUID] = []
}
