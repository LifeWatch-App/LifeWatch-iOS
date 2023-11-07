//
//  HeartAnomaly.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 05/11/23.
//

import Foundation
import FirebaseFirestoreSwift

struct HeartAnomaly: Codable, Hashable {
    let anomaly: String
    let seniorId: String
    let time: Double
}
