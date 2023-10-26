//
//  ChargingRange.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 24/10/23.
//

import Foundation
import FirebaseFirestoreSwift

struct ChargingRange: Hashable, Codable {
    @DocumentID var id: String?
    var seniorID: String?
    var startCharging: String?
    var endCharging: String?
    var taskState: String?

    func getValidChargingRange(startCharging: String, endCharging: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        
        guard let startChargingDate = dateFormatter.date(from: startCharging) else {
            print("Fail converting to date from string")
            return false
        }
        guard let endChargingDate = dateFormatter.date(from: endCharging) else {
            print("Fail converting to date from string")
            return false
        }
        let interval = endChargingDate.timeIntervalSince(startChargingDate)
        let minute = interval.truncatingRemainder(dividingBy: 3600) / 60
        return Int(minute) >= 1 ? true : false
    }
}
