//
//  LocationSearchItems.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 06/12/23.
//

import Foundation
import CoreLocation

struct LocationSearchItem: Identifiable, Hashable {
    var id = UUID().uuidString
    var place: CLPlacemark
}
