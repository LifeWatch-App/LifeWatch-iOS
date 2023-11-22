//
//  LiveLocation.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 02/11/23.
//

import Foundation
import FirebaseFirestoreSwift


struct LiveLocation: Hashable, Codable {
    @DocumentID var id: String?
    var seniorId: String?
    var locationName: String?
    var longitude: Double?
    var latitude: Double?
    var isOutside: Bool?
    var isDistanceFilter: Bool?
    var createdAt: Double?
    var addressArray: [String]?
}
