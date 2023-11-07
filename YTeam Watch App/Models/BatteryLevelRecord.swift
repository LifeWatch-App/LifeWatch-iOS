//
//  BatteryLevelRecord.swift
//  YTeam Watch App
//
//  Created by Kevin Sander Utomo on 23/10/23.
//

import Foundation

struct BatteryLevelRecord: Hashable, Codable {
    var seniorId: Description?
    var watchBatteryLevel: Description?
    var iphoneBatteryLevel: Description?
    var watchLastUpdatedAt: Description?
    var iphoneLastUpdatedAt: Description?
    var watchBatteryState: Description?
    var iphoneBatteryState: Description?
}
