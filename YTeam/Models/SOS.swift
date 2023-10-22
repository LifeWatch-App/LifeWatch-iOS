//
//  SOS.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 22/10/23.
//

import Foundation
import FirebaseFirestoreSwift

struct SOS: Codable, Hashable, Emergency {
    @DocumentID var id: String?
    let seniorId: String
    let time: Double
}
