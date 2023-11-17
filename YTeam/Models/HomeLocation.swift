//
//  HomeLocation.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 15/11/23.
//

import Foundation
import FirebaseFirestoreSwift

struct HomeLocation: Hashable, Codable {
    @DocumentID var id: String?
    var latitude: Double?
    var longitude: Double?
    var radius: Int?
    var seniorId: String?
    var lastUpdatedAt: Double?
}
