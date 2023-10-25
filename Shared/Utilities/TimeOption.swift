//
//  TimeOption.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 22/10/23.
//

import Foundation

enum TimeOption: String, CaseIterable, Identifiable {
    case date, hour
    var id: Self { self }
}
