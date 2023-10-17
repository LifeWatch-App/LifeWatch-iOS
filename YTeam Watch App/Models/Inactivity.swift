//
//  Inactivity.swift
//  YTeam Watch App
//
//  Created by Maximus Aurelius Wiranata on 17/10/23.
//

import Foundation

struct Inactivity: Codable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    var id: Description?
    let startTime: Description?
    let endTime: Description?
}
