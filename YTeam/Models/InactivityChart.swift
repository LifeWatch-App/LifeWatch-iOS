//
//  InactivityChart.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 16/10/23.
//

import Foundation

struct InactivityChart: Identifiable, Equatable {
    var id = UUID()
    var day: Date = Date()
    var minutes: Int = 0
    var type: String = "Idle"
}

// Dummy Data
//let inactivityDummyData: [InactivityChart] = [
//     idle
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 8)) ?? Date(), minutes: 270, type: "Idle"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 9)) ?? Date(), minutes: 350, type: "Idle"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 10)) ?? Date(), minutes: 200, type: "Idle"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 11)) ?? Date(), minutes: 150, type: "Idle"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 12)) ?? Date(), minutes: 280, type: "Idle"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 13)) ?? Date(), minutes: 330, type: "Idle"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 14)) ?? Date(), minutes: 340, type: "Idle"),
//    
////     charging
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 8)) ?? Date(), minutes: 200, type: "Charging"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 9)) ?? Date(), minutes: 410, type: "Charging"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 10)) ?? Date(), minutes: 300, type: "Charging"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 11)) ?? Date(), minutes: 250, type: "Charging"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 12)) ?? Date(), minutes: 220, type: "Charging"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 13)) ?? Date(), minutes: 100, type: "Charging"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 14)) ?? Date(), minutes: 200, type: "Charging"),
//    
////     idle
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 15)) ?? Date(), minutes: 200, type: "Idle"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 16)) ?? Date(), minutes: 300, type: "Idle"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 17)) ?? Date(), minutes: 400, type: "Idle"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 18)) ?? Date(), minutes: 350, type: "Idle"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 19)) ?? Date(), minutes: 200, type: "Idle"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 20)) ?? Date(), minutes: 300, type: "Idle"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 21)) ?? Date(), minutes: 350, type: "Idle"),
    
//     charging
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 15)) ?? Date(), minutes: 200, type: "Charging"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 16)) ?? Date(), minutes: 400, type: "Charging"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 17)) ?? Date(), minutes: 200, type: "Charging"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 18)) ?? Date(), minutes: 350, type: "Charging"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 19)) ?? Date(), minutes: 320, type: "Charging"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 20)) ?? Date(), minutes: 200, type: "Charging"),
//    InactivityChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 21)) ?? Date(), minutes: 100, type: "Charging"),
//]
