//
//  Symptom.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 04/11/23.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

struct Symptom : Hashable, Codable, Identifiable {
    @DocumentID var id: String?
    var name: String?
    var seniorId: String?
    var note: String?
    var time: Double?
}

let dummySymptomsSkeleton2: [Symptom] = [
    Symptom(name: "Headache", seniorId: "1", note: "This is the headache", time: 123),
    Symptom(name: "Fever", seniorId: "2", note: "This is the fever", time: 124),
]

let dummySymptomsSkeleton: [String: Int] = [
    "Headache": 1,
    "Cough": 2,
    "Dizziness": 2,
]

let symptomList: [String] = [
    "Headache",
    "Fever",
    "Fatigue",
    "Nausea",
    "Dizziness",
    "Shortness of Breath",
    "Indigestion",
    "Constipation",
    "Cough",
    "Skin Rashes",
    "Minor Injuries",
    "Insomnia",
    "Sore Throat"
]




// dummy data
//let symptomsDummyData: [Symptom] = [
//    Symptom(name: "Cough", time: Date()),
//    Symptom(name: "Fever", note: "39 degrees celcius", time: Date()),
//    Symptom(name: "Nausea", time: Date()),
//    Symptom(name: "Fever", note: "41 degrees celcius", time: Date()),
//]
