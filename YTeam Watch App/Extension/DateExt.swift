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
    
    static func unixToString(unix: Double, timeOption: TimeOption) -> String {
        let date = Date(timeIntervalSince1970: unix)
        let dateFormatter = DateFormatter()
        
        if (timeOption == .date) {
            dateFormatter.dateFormat = "d MMMM yyyy"
        }
        
        if (timeOption == .hour) {
            dateFormatter.dateFormat = "HH:mm:ss"
        }
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }

    static func unixToTime(unix: Double) -> String {
        let date = Date(timeIntervalSince1970: unix)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.string(from: date)
    }

    static func unixToDate(unix: Double) -> Date {
        let date = Date(timeIntervalSince1970: unix)
        return date
    }

    static func dateToUnix(date: Date) -> Double {
        return date.timeIntervalSince1970
    }


    static func timeDifference(unix: Double) -> (timeString: String, timeDifference: Double) {
        let currentTime = Date().timeIntervalSince1970
        let timeDifference = currentTime - unix
        if timeDifference < 60 {
            // Less than a minute
            let seconds = Int(timeDifference)
            return ("\(seconds)", timeDifference)
        } else if timeDifference < 3600 {
            // Less than an hour
            let minutes = Int(timeDifference / 60)
            return ("\(minutes)", timeDifference)
        } else if timeDifference < 86400 {
            // Less than a day
            let hours = Int(timeDifference / 3600)
            return ("\(hours)", timeDifference)
        } else {
            // More than a day
            let days = Int(timeDifference / 86400)
            return ("\(days)", timeDifference)
        }
    }

}
