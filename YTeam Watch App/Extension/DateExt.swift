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

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }

    var dayMonthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateFormat = "dd MMM"
        return formatter
    }

    var strippedDate: Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date = Calendar.current.date(from: components)!
        return date
    }

    static func dates(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = fromDate

        while date <= toDate {
            dates.append(date)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }
    
    static func timeToString(time: String, timeOption: TimeOption) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"

        if let date = dateFormatter.date(from: time) {
            if (timeOption == .date) {
                dateFormatter.dateFormat = "d MMMM yyyy"
            } else if (timeOption == .hour) {
                dateFormatter.dateFormat = "HH:mm:ss"
            }
            let formattedDate = dateFormatter.string(from: date)
            return formattedDate
        } else {
            return "Invalid date string"
        }
    }
    
}

enum TimeOption: String, CaseIterable, Identifiable {
    case date, hour
    var id: Self { self }
}
