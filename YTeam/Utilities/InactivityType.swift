//
//  InactivityType.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 24/10/23.
//

import Foundation

enum InactivityType: String, CaseIterable, Identifiable {
    case idle, active
    var id: Self { self }
}
