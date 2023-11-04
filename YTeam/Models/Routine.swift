//
//  Routine.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 04/11/23.
//

import Foundation

struct Routine: Identifiable {
    var id = UUID()
    var name: String = ""
    var type: String = ""
    var description: String = ""
    var isDone: Bool = false
    var time: Date = Date()
}

// dummy data
let routinesDummyData: [Routine] = [
    Routine(name: "OBH Combi", type: "medicine", description: "2 Tablet", isDone: true, time: Date()),
    Routine(name: "Paramex", type: "medicine", description: "2 Tablet", isDone: false, time: Date()),
    Routine(name: "Jogging", type: "activity", description: "2 KM", isDone: false, time: Date()),
    Routine(name: "Eat", type: "activity", description: "breakfast", isDone: false, time: Date()),
]
