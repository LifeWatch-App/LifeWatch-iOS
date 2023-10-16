//
//  DateExt.swift
//  YTeam Watch App
//
//  Created by Kevin Sander Utomo on 13/10/23.
//

import Foundation

extension Date {
    func formatDateToCustomString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // Assuming you want a UTC timestamp
        return dateFormatter.string(from: self)
    }
}
