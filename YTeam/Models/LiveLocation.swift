//
//  LiveLocation.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 02/11/23.
//

import Foundation


struct LiveLocation: Hashable, Codable {
    var seniorId: String?
    var locationName: String?
    var longitude: Double?
    var latitude: Double?
    var isOutside: Bool?
    var createdAt: Double?
    var addressArray: [String]?
}
