//
//  AddSymptomViewModel.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 06/11/23.
//

import Foundation

class AddSymptomViewModel: ObservableObject {
    @Published var time = Date()
    @Published var notes = ""
    
    @Published var selectedSymptom: String?
}
