//
//  InactivityChart.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 16/10/23.
//

import Foundation

struct InactivityChart: Identifiable {
    var id = UUID()
//    var date: Date = Date()
    var date: String = ""
    var value: Int = 0
    var type: String = ""
}

let inactivityDummyData: [InactivityChart] = [
    // idle
    InactivityChart(date: "01 Okt", value: 200, type: "Idle"),
    InactivityChart(date: "02 Okt", value: 300, type: "Idle"),
    InactivityChart(date: "03 Okt", value: 400, type: "Idle"),
    InactivityChart(date: "04 Okt", value: 350, type: "Idle"),
    InactivityChart(date: "05 Okt", value: 200, type: "Idle"),
    InactivityChart(date: "06 Okt", value: 300, type: "Idle"),
    InactivityChart(date: "07 Okt", value: 350, type: "Idle"),
    
    // charging
    InactivityChart(date: "01 Okt", value: 200, type: "Charging"),
    InactivityChart(date: "02 Okt", value: 400, type: "Charging"),
    InactivityChart(date: "03 Okt", value: 200, type: "Charging"),
    InactivityChart(date: "04 Okt", value: 350, type: "Charging"),
    InactivityChart(date: "05 Okt", value: 320, type: "Charging"),
    InactivityChart(date: "06 Okt", value: 200, type: "Charging"),
    InactivityChart(date: "07 Okt", value: 100, type: "Charging"),
]
