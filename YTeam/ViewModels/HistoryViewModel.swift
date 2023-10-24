//
//  HistoryViewModel.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata and Kenny Jinhiro on 16/10/23.
//

import SwiftUI
import FirebaseAuth
import Combine

class HistoryViewModel: ObservableObject {
    @Published var selectedHistoryMenu: HistoryMenu = .inactivity
    @Published var falls: [Fall] = []
    @Published var sos: [SOS] = []
    @Published var idles: [Idle] = []
    @Published var charges: [Charge] = []
    @Published var groupedEmergencies: [(String, [Emergency])] = []
    @Published var loading: Bool = true
    @Published var loggedIn: Bool = false
    @Published var fallsCount: Int = 0
    @Published var sosCount: Int = 0
    @Published var inactivityData: [InactivityChart] = []
    @Published var currentWeek: [Date] = []
    
    var currentDay: Date = Date()
    var totalIdleTime: String = ""
    var totalChargingTime: String = ""
    
    private var inactivityDataTemp: [InactivityChart] = []
    private let fallService: FallService = FallService.shared
    private let sosService: SOSService = SOSService.shared
    private let inactivityService: InactivityService = InactivityService.shared
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
                fetchCurrentWeek()
                updateGroupedEmergencies()
            }
            .store(in: &cancellables)
        
        sosService.$sos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sos in
                guard let self else {return}
                
                self.sos.append(contentsOf: sos)
                fetchCurrentWeek()
                updateGroupedEmergencies()
            }
            .store(in: &cancellables)
        
        inactivityService.$idles
            .receive(on: DispatchQueue.main)
            .sink { [weak self] idle in
                guard let self else {return}
                
                self.idles.append(contentsOf: idle)
                fetchCurrentWeek()
                convertInactivitesToInactivityCharts()
            }
            .store(in: &cancellables)
        
        inactivityService.$charges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] charge in
                guard let self else {return}
                
                self.charges.append(contentsOf: charge)
                fetchCurrentWeek()
                convertInactivitesToInactivityCharts()
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
            
            guard let firstDay = self.currentWeek.first else {return}
            guard let lastDay = self.currentWeek.last else {return}
            
            let sortedUnixKeys = mappedKeys.sorted {$0 > $1}
            let sortedKeys = sortedUnixKeys.compactMap { unix -> String? in
                if (
                    uniqueKeys.insert(Date.unixToString(unix: unix, timeOption: .date)).inserted &&
                    Date(timeIntervalSince1970: unix) >= firstDay &&
                    Date(timeIntervalSince1970: unix) <= lastDay
                ){
                    return Date.unixToString(unix: unix, timeOption: .date)
                }
                return nil
            }
            
            self.groupedEmergencies = sortedKeys.map {($0, emergencyDictionary[$0]!)}
            
            var falls: Int = 0
            var sos: Int = 0
            
            for (_, emergencies) in groupedEmergencies {
                for emergency in emergencies {
                    if let _ = emergency as? Fall {
                        falls += 1
                    } else if let _ = emergency as? SOS {
                        sos += 1
                    }
                }
            }
            
            self.fallsCount = falls
            self.sosCount = sos
            self.loading = false
        }
    }
    
    /// Updates internal properties such as `currentDay` and `currentWeek`.
    ///
    /// ```
    /// HistoryViewModel.changeWeek()
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: Updated `currentDay` and `currentWeek` .
    func changeWeek(type: ChangeWeek) {
        if type == .next {
            currentDay = Calendar.current.date(byAdding: .day, value: 7, to: currentDay) ?? Date()
        } else {
            currentDay = Calendar.current.date(byAdding: .day, value: -7, to: currentDay) ?? Date()
        }
        
        self.fetchCurrentWeek()
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
            updateGroupedEmergencies()
        }
//        print(currentWeek)
    }
    
    func convertInactivitesToInactivityCharts() {
        let inactivities: [Any] = self.idles + self.charges
        self.inactivityDataTemp = inactivities.map { inactivity in
            let calendar = Calendar.current
            
            if let fall = inactivity as? Idle{
                let difference: Int = Int((fall.endTime ?? 0) - (fall.startTime ?? 0))
                let minutes: Int = difference / 60
                
                var startDate = Date(timeIntervalSince1970: (fall.startTime ?? 0))
                var dateComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
                dateComponents.hour = 0
                dateComponents.minute = 0

                startDate = calendar.date(from: dateComponents) ?? Date()
                
                return InactivityChart(day: startDate, minutes: minutes, type: "Idle")
            } else if let charge = inactivity as? Charge{
                let difference: Int = Int((charge.endCharging ?? 0) - (charge.startCharging ?? 0))
                let minutes: Int = difference / 60
                
                var startDate = Date(timeIntervalSince1970: (charge.startCharging ?? 0))
                var dateComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
                dateComponents.hour = 0
                dateComponents.minute = 0

                startDate = calendar.date(from: dateComponents) ?? Date()
                
                return InactivityChart(day: startDate, minutes: minutes, type: "Charging")
            }
            return InactivityChart()
        }
        
        self.inactivityDataTemp = self.inactivityDataTemp.filter { $0.minutes > 0}
        
        var inactivityDictionary: [Date: [InactivityChart]] = [:]

        for inactivity in self.inactivityDataTemp {
            let inactivityDate = inactivity.day
            if var inactivityArray = inactivityDictionary[inactivityDate] {
                inactivityArray.append(inactivity)
                inactivityDictionary[inactivityDate] = inactivityArray
            } else {
                inactivityDictionary[inactivityDate] = [inactivity]
            }
        }
        
        var inactivityDataGrouped: [InactivityChart] = []
        
        for (inactivityDate, inactivities) in inactivityDictionary {
            var totalMinutesIdle = 0
            var totalMinutesCharging = 0
            
            for inactivity in inactivities {
                if (inactivity.type == "Idle") {
                    totalMinutesIdle += inactivity.minutes
                } else {
                    totalMinutesCharging += inactivity.minutes
                }
            }
            
            inactivityDataGrouped.append(InactivityChart(day: inactivityDate, minutes: totalMinutesIdle, type: "Idle"))
            inactivityDataGrouped.append(InactivityChart(day: inactivityDate, minutes: totalMinutesCharging, type: "Charging"))
        }
        
        self.inactivityDataTemp = inactivityDataGrouped.filter { $0.minutes > 0}
    }
    
    func fetchCurrentWeekData() {
        self.loading = true
        self.inactivityData = []
        var tempDate = currentWeek.first ?? Date()
        
        while tempDate <= currentWeek.last ?? Date() {
            var inactivity = [InactivityChart(), InactivityChart()]
            
            self.inactivityDataTemp.forEach { data in
                if (data.day == tempDate && data.minutes != 0) {
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
                self.inactivityData.append(inactivity[i])
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
        self.loading = false
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
