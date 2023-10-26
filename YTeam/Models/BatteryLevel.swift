//
//  BatteryLevel.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 24/10/23.
//

import Foundation
import FirebaseFirestoreSwift

struct BatteryLevel: Hashable, Codable {
    @DocumentID var id: String?
    var seniorId: String?
    var watchBatteryLevel: String?
    var iphoneBatteryLevel: String?
    var watchLastUpdatedAt: String?
    var iphoneLastUpdatedAt: String?
    var watchBatteryState: String?
    var iphoneBatteryState: String?
}
