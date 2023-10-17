//
//  ChargingRange.swift
//  CobaApp Watch App
//
//  Created by Kevin Sander Utomo on 10/10/23.
//

import Foundation

struct ChargingRange: Hashable, Codable {
    var userID: String?
    var startCharging: Date?
    var endCharging: Date?
    var taskState: String?

    func getValidChargingRange(startCharging: Date, endCharging: Date) -> Bool {
        let interval = endCharging.timeIntervalSince(startCharging)
        let minute = interval.truncatingRemainder(dividingBy: 3600) / 60
        return Int(minute) >= 0 ? true : false
    }

    func getFormattedStartEndTime(chargingRange: ChargingRange) -> String {
        guard let startRange = chargingRange.startCharging, let endRange = chargingRange.endCharging else { return "" }
        return "\(Date().dateFormatter.string(from: startRange)) - \(Date().dateFormatter.string(from: endRange))"

    }
}

struct ChargingRangeRecord: Hashable, Codable {
    var userID: Description?
    var startCharging: Description?
    var endCharging: Description?
    var taskState: Description?
}

//enum ChargingTask: Codable {
//    case ongoing, ended
//}

