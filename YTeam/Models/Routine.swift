//
//  Routine.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 04/11/23.
//

import Foundation

struct Routine {
    var name: String = ""
    var type: String = ""
    var description: String = ""
    var time: Date = Date()
}

// dummy data
let routines = [
    Routine(name: "Minum Obat", type: "medicine", description: "2 Tablet", time: Date()),
    Routine(name: "Minum Obat", type: "medicine", description: "2 Tablet", time: Date()),
    Routine(name: "Minum Obat", type: "activity", description: "2 Tablet", time: Date()),
    Routine(name: "Minum Obat", type: "activity", description: "2 Tablet", time: Date()),
]
