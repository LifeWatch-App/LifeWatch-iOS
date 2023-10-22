//
//  Fall.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 17/10/23.
//

import Foundation
import FirebaseFirestoreSwift

struct Fall: Codable, Hashable, Emergency {
    @DocumentID var id: String?
    let seniorId: String
    let time: Double
}
