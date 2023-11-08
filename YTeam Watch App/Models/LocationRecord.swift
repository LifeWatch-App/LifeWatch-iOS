//
//  LocationRecord.swift
//  YTeam Watch App
//
//  Created by Kevin Sander Utomo on 26/10/23.
//

import Foundation


struct HomeLocationRecord: Hashable, Codable {
    var seniorId: Description?
    var longitude: Description?
    var latitude: Description?
    var radius: Description?
    var lastUpdatedAt: Description?
}

struct LiveLocationRecord: Hashable, Codable {
    var seniorId: Description?
    var locationName: Description?
    var longitude: Description?
    var latitude: Description?
    var isOutside: Description?
    var createdAt: Description?
}


