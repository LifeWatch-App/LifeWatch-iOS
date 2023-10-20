//
//  Charge.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 18/10/23.
//

import Foundation

struct Charge: Codable, Hashable {
    let seniorId: String
    let startCharging: String
    let endCharging: String
    let taskState: String
}
