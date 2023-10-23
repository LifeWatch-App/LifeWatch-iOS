//
//  HistoryViewModel.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 16/10/23.
//

import SwiftUI
import FirebaseAuth
import Combine

class HistoryViewModel: ObservableObject {
    @Published var selectedHistoryMenu: HistoryMenu = .inactivity
    @Published var falls: [Fall] = []
    @Published var sos: [SOS] = []
    @Published var groupedEmergencies: [(String, [Emergency])] = []
    @Published var loading: Bool = true
    @Published var loggedIn: Bool = false
    @Published var fallsCount: Int = 0
    @Published var sosCount: Int = 0
    @Published var inactivityData: [InactivityChart] = [InactivityChart]()
    
    var currentWeek: [Date] = []
    var currentDay: Date = Date()
    var totalIdleTime: String = ""
    var totalChargingTime: String = ""
    
    private let fallService: FallService = FallService.shared
    private let sosService: SOSService = SOSService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupEmergencySubscriber()
        fetchCurrentWeek()
    }
    
    /// Subscribes to the FallService to check for changes, and updates `loading, loggedIn, fallsCount, falls, and groupedFalls`.
    ///
    /// ```
    /// Not to be called.
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: If user is logged in, return `sorted falls only if there are the senior's falls`.
    func setupEmergencySubscriber() {
        fallService.$falls
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fall in
                guard let self else { return }

                self.falls.append(contentsOf: fall)
                updateGroupedEmergencies()
            }
            .store(in: &cancellables)
        
        sosService.$sos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sos in
                guard let self else {return}
                
                self.sos.append(contentsOf: sos)
                updateGroupedEmergencies()
            }
            .store(in: &cancellables)
    }
    
    /// Updates internal properties such as `loggedIn, falls, sos, fallsCount, sosCount, and groupedEmergencies` and is only called in `setupEmergencySubscriber`.
    ///
    /// ```
    /// Not to be called.
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: Updated `loggedIn, falls, sos, fallsCount, sosCount, and groupedEmergencies`.
    func updateGroupedEmergencies() {
        if ((Auth.auth().currentUser) != nil) {
            self.loggedIn = true
        } else {
            self.loggedIn = false
        }
        
        if (self.loggedIn == true) {
            self.loading = true
            
            var emergencies: [Any] = self.falls + self.sos
            emergencies = emergencies.sorted { a, b in
                if let a = a as? Fall, let b = b as? SOS {
                    return a.time > b.time
                } else if let a = a as? SOS, let b = b as? Fall {
                    return a.time > b.time
                } else {
                    return false
                }
            }
            
            var emergencyDictionary: [String: [Emergency]] = [:]
            
            for emergency in emergencies {
                if let fall = emergency as? Fall {
                    let dateString = Date.unixToString(unix: fall.time, timeOption: .date)
                    if var emergencies = emergencyDictionary[dateString] {
                        emergencies.append(fall)
                        emergencyDictionary[dateString] = emergencies
                    } else {
                        emergencyDictionary[dateString] = [fall]
                    }
                } else if let sos = emergency as? SOS {
                    let dateString = Date.unixToString(unix: sos.time, timeOption: .date)
                    if var emergencies = emergencyDictionary[dateString] {
                        emergencies.append(sos)
                        emergencyDictionary[dateString] = emergencies
                    } else {
                        emergencyDictionary[dateString] = [sos]
                    }
                }
            }
            
            var uniqueKeys = Set<String>()
            
            let mappedKeys = emergencies.map { a in
                if let a = a as? Fall{
                    return a.time
                } else if let a = a as? SOS{
                    return a.time
                } else {
                    return 0.0
                }
            }
            
            let sortedUnixKeys = mappedKeys.sorted {$0 > $1}
            let sortedKeys = sortedUnixKeys.compactMap { unix -> String? in
                if (uniqueKeys.insert(Date.unixToString(unix: unix, timeOption: .date)).inserted){
                    return Date.unixToString(unix: unix, timeOption: .date)
                }
                return nil
            }
            
            self.groupedEmergencies = sortedKeys.map {($0, emergencyDictionary[$0]!)}
            debugPrint(groupedEmergencies)
            self.fallsCount = self.falls.count
            self.sosCount = self.sos.count
            self.loading = false
        }
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
