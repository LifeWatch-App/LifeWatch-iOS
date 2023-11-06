//
//  SymptomList.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 06/11/23.
//

import Foundation

struct SymptomList: Identifiable, Equatable {
    var id = UUID()
    var name: String = ""
    var image: String = ""
}

let symptomList: [SymptomList] = [
    SymptomList(name: "Headaches", image: "symtomps"),
    SymptomList(name: "Fever", image: "symtomps"),
    SymptomList(name: "Fatigue", image: "symtomps"),
    SymptomList(name: "Nausea", image: "symtomps"),
    SymptomList(name: "Dizziness", image: "symtomps"),
    SymptomList(name: "Shortness\nof Breath", image: "symtomps"),
    SymptomList(name: "Indigestion", image: "symtomps"),
    SymptomList(name: "Constipation", image: "symtomps"),
    SymptomList(name: "Cough", image: "symtomps"),
    SymptomList(name: "Skin\nRashes", image: "symtomps"),
    SymptomList(name: "Minor\nInjuries", image: "symtomps"),
    SymptomList(name: "Insomnia", image: "symtomps"),
    SymptomList(name: "Sore\nThroat", image: "symtomps"),
]
