//
//  FallHistory.swift
//  YTeam Watch App
//
//  Created by Kenny Jinhiro Wibowo on 16/10/23.
//

import Foundation

struct FallHistory: Codable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    var id: Description?
    let time: Description?
}
