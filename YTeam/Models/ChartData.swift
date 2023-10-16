//
//  ChartData.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 16/10/23.
//

import Foundation

struct ChartData: Identifiable, Hashable, Codable {
    var id = UUID().uuidString
    var date: Date
    var chargingCount = 1
}
