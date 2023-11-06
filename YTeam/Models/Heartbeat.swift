//
//  Heartbeat.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 06/11/23.
//

import Foundation
import FirebaseFirestoreSwift

struct Heartbeat: Codable, Hashable {
    let seniorId: String
    let time: Double
    let bpm: Int
}
