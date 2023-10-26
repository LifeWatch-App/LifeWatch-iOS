//
//  HeartRateChart.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 26/10/23.
//

import Foundation

struct HeartRateChart: Identifiable, Equatable {
    var id = UUID()
    var day: Date = Date()
    var avgHeartRate: Int = 0
}

let heartRateDummyData: [HeartRateChart] = [
    HeartRateChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 15)) ?? Date(), avgHeartRate: 120),
    HeartRateChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 16)) ?? Date(), avgHeartRate: 110),
    HeartRateChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 17)) ?? Date(), avgHeartRate: 90),
    HeartRateChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 18)) ?? Date(), avgHeartRate: 100),
    HeartRateChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 19)) ?? Date(), avgHeartRate: 70),
    HeartRateChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 20)) ?? Date(), avgHeartRate: 80),
    HeartRateChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 21)) ?? Date(), avgHeartRate: 125),
    
    HeartRateChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 22)) ?? Date(), avgHeartRate: 110),
    HeartRateChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 23)) ?? Date(), avgHeartRate: 100),
    HeartRateChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 24)) ?? Date(), avgHeartRate: 95),
    HeartRateChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 25)) ?? Date(), avgHeartRate: 120),
    HeartRateChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 26)) ?? Date(), avgHeartRate: 60),
    HeartRateChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 27)) ?? Date(), avgHeartRate: 90),
    HeartRateChart(day: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 28)) ?? Date(), avgHeartRate: 115),
]
