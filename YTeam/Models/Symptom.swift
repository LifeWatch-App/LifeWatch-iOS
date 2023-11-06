//
//  Symptom.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 04/11/23.
//

import Foundation

struct Symptom : Identifiable {
    var id = UUID()
    var name: String = ""
    var note: String?
    var time: Date = Date()
}

// dummy data
let symptomsDummyData: [Symptom] = [
    Symptom(name: "Cough", time: Date()),
    Symptom(name: "Fever", note: "39 degrees celcius", time: Date()),
]
