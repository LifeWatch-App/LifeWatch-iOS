//
//  Charge.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 18/10/23.
//

import Foundation
import FirebaseFirestoreSwift

struct Charge: Codable, Hashable {
    @DocumentID var id: String?
    let startCharging: Double?
    let endCharging: Double?
    let seniorId: String?
    let taskState: String?
}
