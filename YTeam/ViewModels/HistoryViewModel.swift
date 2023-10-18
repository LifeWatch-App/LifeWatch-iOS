//
//  HistoryViewModel.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 16/10/23.
//

import SwiftUI

class HistoryViewModel: ObservableObject {
    @Published var selectedHistoryMenu: HistoryMenu = .inactivity
    
    @Published var fallCount: Int = 4
    @Published var sosCount: Int = 1
    
    @Published var inactivityData: [InactivityChart] = [InactivityChart]()
    
    var currentWeek: [Date] = []
    var currentDay: Date = Date()
    
    var totalIdleTime: String = ""
    var totalChargingTime: String = ""
    
    init() {
        fetchCurrentWeek()
    }
    
    func changeWeek(type: ChangeWeek) {
        if type == .next {
            currentDay = Calendar.current.date(byAdding: .day, value: 7, to: currentDay) ?? Date()
        } else {
            currentDay = Calendar.current.date(byAdding: .day, value: -7, to: currentDay) ?? Date()
        }
        
        fetchCurrentWeek()
    }
    
    func fetchCurrentWeek() {
        currentWeek = []
        
        let calendar = Calendar.current

        let week = calendar.dateInterval(of: .weekOfMonth, for: self.currentDay)

        guard let firstWeekDay = week?.start else {
            return
        }

        (0...6).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: firstWeekDay) {
//                weekday = calendar.date(byAdding: .hour, value: 7, to: weekday) ?? Date()
                currentWeek.append(weekday)
            }
        }
        
        withAnimation {
            fetchCurrentWeekData()
        }
//        print(currentWeek)
    }
    
    func fetchCurrentWeekData() {
        inactivityData = []
        var tempDate = currentWeek.first ?? Date()

        while tempDate <= currentWeek.last ?? Date() {
            var inactivity = [InactivityChart(), InactivityChart()]
            
            inactivityDummyData.forEach { data in
                if data.day == tempDate {
                    if data.type == "Idle" {
                        inactivity[0].day = data.day
                        inactivity[0].minutes = data.minutes
                        inactivity[0].type = data.type
                    } else {
                        inactivity[1].day = data.day
                        inactivity[1].minutes = data.minutes
                        inactivity[1].type = data.type
                    }
                }
            }
            
            (0...1).forEach { i in
                if inactivity[i].minutes == 0 {
                    inactivity[i].day = tempDate
                    if i == 0 {
                        inactivity[i].type = "Idle"
                    } else {
                        inactivity[i].type = "Charging"
                    }
                }
                inactivityData.append(inactivity[i])
            }
            
            tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate) ?? Date()
        }
        
        countTotalWeekData()
    }
    
    func countTotalWeekData() {
        var totalIdle = 0
        var totalCharging = 0
        
        inactivityData.forEach { data in
            if data.type == "Idle" {
                totalIdle += data.minutes
            } else {
                totalCharging += data.minutes
            }
        }
        
        totalIdleTime = convertToHoursMinutes(minutes: totalIdle)
        totalChargingTime = convertToHoursMinutes(minutes: totalCharging)
    }
    
    func extractDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
    
    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current

        return calendar.isDate(currentDay, inSameDayAs: date)
    }
    
    func convertToHoursMinutes(minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)h \(remainingMinutes)m"
    }
    
//    func createDate(year: Int, month: Int, day: Int = 1) -> Date {
//        Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
//    }
}

enum HistoryMenu: String, CaseIterable, Identifiable {
    case emergency, inactivity
    var id: Self { self }
}

enum HistoryCardOption: String, CaseIterable, Identifiable {
    case fell, pressed, idle, charging
    var id: Self { self }
}

enum ChangeWeek: String, CaseIterable {
    case next, previous
}

struct HoursMinutes {
    var hours: Int = 0
    var minutes: Int = 0
}
