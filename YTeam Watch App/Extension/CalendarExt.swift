//
//  Calendarext.swift
//  CobaApp
//
//  Created by Kevin Sander Utomo on 11/10/23.
//

import Foundation

extension Calendar {
    private func intervalOfWeek(for date: Date) -> DateInterval? {
        dateInterval(of: .weekOfYear, for: date)
    }

    private func startOfWeek(for date: Date) -> Date? {
        intervalOfWeek(for: date)?.start
    }

    func daysWithSameWeekOfYear(as date: Date) -> [Date] {
        guard let startOfWeek = startOfWeek(for: date.strippedDate) else {
            return []
        }

        return (0 ... 6).reduce(into: []) { result, daysToAdd in
            result.append(Calendar.current.date(byAdding: .day, value: daysToAdd, to: startOfWeek))
        }
        .compactMap { $0 }
    }
}
