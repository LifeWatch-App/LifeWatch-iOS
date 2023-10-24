//
//  Inactivity.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 23/10/23.
//

import Foundation
import FirebaseFirestoreSwift

struct Idle: Codable, Hashable {
    @DocumentID var id: String?
    let startTime: Double?
    let endTime: Double?
    let seniorId: String?
    let taskState: String?
}
