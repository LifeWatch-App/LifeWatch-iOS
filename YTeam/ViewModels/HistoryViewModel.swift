//
//  HistoryViewModel.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata and Kenny Jinhiro on 16/10/23.
//

import SwiftUI
import FirebaseAuth
import Firebase
import Combine

final class HistoryViewModel: ObservableObject {
    @Published var userData: UserData?
    @Published var falls: [Fall] = []
    @Published var sos: [SOS] = []
    @Published var idles: [Idle] = []
    @Published var viewHasAppeared = false
    @Published var selectedUserId: String?
    @Published var comparator: String?
    @Published var charges: [Charge] = []
    @Published var heartAnomalies: [HeartAnomaly] = []
    @Published var heartbeats: [Heartbeat] = []
    @Published var groupedEmergencies: [(String, [Emergency])] = []
    @Published var groupedInactivities: [(String, [Any])] = []
    @Published var groupedHeartAnomalies: [(String, [HeartAnomaly])] = []
    @Published var groupedSymptoms: [(String, [Symptom])] = []
    @Published var filteredSymptoms: [String: Int] = [:]
    @Published var loading: Bool = true
    @Published var loggedIn: Bool = false
    @Published var fallsCount: Int = 0
    @Published var sosCount: Int = 0
    @Published var idleCount: Int = 0
    @Published var isLoading: Bool = true
    @Published var chargeCount: Int = 0
    @Published var inactivityData: [InactivityChart] = []
    @Published var heartRateData: [HeartRateChart] = []
    @Published var currentWeek: [Date] = []
    @Published var totalIdleTime: String = ""
    @Published var totalChargingTime: String = ""
    @Published var avgHeartRate: Int = 0
    @Published var shouldReloadData = false
    @Published var symptomsTest: [Symptom] = []
    
    @Published var testIsLoading: Bool = true
    
    private var currentDay: Date = Date()
    private var inactivityDataTemp: [InactivityChart] = []
    private var heartbeatDataTemp: [HeartRateChart] = []
    private let authService = AuthService.shared
    
    private var guardLoading = true
    
    
    private let fallService = FallService.shared
    private let sosService = SOSService.shared
    private let inactivityService = InactivityService.shared
    private let heartAnomalyService = HeartAnomalyService.shared
    private let heartbeatService = HeartbeatService.shared
    private let symptomService = SymptomService.shared
    
    private var symptomFinish = false
    private var chargeFinish = false
    private var anomaliesFinish = false
    private var idleFinish = false
    private var heartFinish = false
    private var fallFinish = false
    private var sosFinish = false
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
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
    func setupSubscribers() {
        authService.$selectedInviteId
            //.removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] id in
                print("Entered history auth: \(id)")

                if self?.selectedUserId != id && id != nil {
                    self?.selectedUserId = id
                    self?.shouldReloadData = true
                }
            }
            .store(in: &cancellables)
        
        $viewHasAppeared
            .removeDuplicates()
            .combineLatest(authService.$userData, $selectedUserId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] viewAppeared, userData, id in
                print("Entered view has appeared")
                if id != nil && userData?.role != nil && viewAppeared == true {
                        self?.viewHasAppeared = false
                    //Need to check whether the id is the same as the previous
                    if self?.shouldReloadData == true {
                        if self?.isLoading == false {
                            withAnimation {
                                self?.guardLoading = true
                                self?.isLoading = true
//                                self?.falls = []
//                                self?.sos = []
//                                self?.idles = []
//                                self?.charges = []
//                                self?.heartAnomalies = []
//                                self?.heartbeats = []
//                                self?.groupedEmergencies = []
//                                self?.groupedInactivities = []
//                                self?.groupedHeartAnomalies = []
//                                self?.groupedSymptoms = []
//                                self?.filteredSymptoms = [:]
//                                self?.fallsCount = 0
//                                self?.sosCount = 0
//                                self?.idleCount = 0
//                                self?.chargeCount = 0
//                                self?.inactivityData = []
//                                self?.heartRateData = []
//                                self?.currentWeek = []
//                                self?.totalIdleTime  = ""
//                                self?.totalChargingTime = ""
//                                self?.avgHeartRate = 0
//                                self?.symptomsTest = []
//                                self?.symptomsTest = []
//                                self?.idles = []
//                                self?.charges = []
//                                self?.falls = []
//                                self?.sos = []
//                                self?.heartbeats = []
//                                self?.heartAnomalies = []
//                                self?.symptomFinish = false
//                                self?.chargeFinish = false
//                                self?.anomaliesFinish = false
//                                self?.idleFinish = false
//                                self?.heartFinish = false
//                                self?.fallFinish = false
//                                self?.sosFinish = false
                                self?.symptomsTest = []
                                self?.idles = []
                                self?.charges = []
                                self?.falls = []
                                self?.sos = []
                                self?.heartbeats = []
                                self?.heartAnomalies = []
                            }
                        }

                        self?.inactivityService.observeAllInactivity(userData: userData)
                        self?.sosService.observeAllSOS(userData: userData)
                        self?.symptomService.observeSymptoms(userData: userData)
                        self?.fallService.observeAllFalls(userData: userData)
                        self?.heartAnomalyService.observeAllAnomalies(userData: userData)
                        self?.heartbeatService.observeAllHeartbeats(userData: userData)
                        self?.fetchCurrentWeek()
                        self?.shouldReloadData = false

                    }
                }
            }
            .store(in: &cancellables)
        
        fallService.$falls
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fall in
                guard let self else { return }
                
                self.falls.append(contentsOf: fall)
                self.fetchCurrentWeek()
                self.fallFinish = true
                self.checkFinishLoading()
            }
            .store(in: &cancellables)
        
        sosService.$sos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sos in
                guard let self else {return}
                
                self.sos.append(contentsOf: sos)
                self.fetchCurrentWeek()
                self.sosFinish = true
                self.checkFinishLoading()
            }
            .store(in: &cancellables)
        
        inactivityService.$idles
            .receive(on: DispatchQueue.main)
            .sink { [weak self] idle in
                guard let self else {return}
                print("Idle", idle)
                self.idles.append(contentsOf: idle)
                self.fetchCurrentWeek()
                self.idleFinish = true
                self.checkFinishLoading()
            }
            .store(in: &cancellables)
        
        inactivityService.$charges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] charge in
                guard let self else {return}
                print("Charge", charge)
                self.charges.append(contentsOf: charge)
                self.fetchCurrentWeek()
                self.chargeFinish = true
                self.checkFinishLoading()
            }
            .store(in: &cancellables)
        
        heartAnomalyService.$heartAnomalies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] anomaly in
                guard let self else {return}
                
                self.heartAnomalies.append(contentsOf: anomaly)
                self.fetchCurrentWeek()
                self.anomaliesFinish = true
                self.checkFinishLoading()
            }
            .store(in: &cancellables)
        
        heartbeatService.$heartbeats
            .receive(on: DispatchQueue.main)
            .sink { [weak self] heartbeat in
                guard let self else {return}
                
                self.heartbeats.append(contentsOf: heartbeat)
                self.fetchCurrentWeek()
                self.heartFinish = true
                self.checkFinishLoading()
            }
            .store(in: &cancellables)
        
        symptomService.$symptomsDocumentChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                guard let self else {return}
                self.symptomsTest.append(contentsOf: self.loadInitialSymptoms(documents: documentChanges))
                self.fetchCurrentWeek()
                self.symptomFinish = true
                self.checkFinishLoading()
            }
            .store(in: &cancellables)
    }
    
    
    private func loadInitialSymptoms(documents: [DocumentChange]) -> [Symptom] {
        var symptoms: [Symptom] = []
        for document in documents {
            do {
                let symptom = try document.document.data(as: Symptom.self)
                symptoms.append(symptom)
            } catch {
                print("Error: \(error)")
            }
        }
        print(symptoms)
        return symptoms
    }
    
    func updateSymptoms() {
        self.filteredSymptoms = [:]
        let unixRanges = currentWeek.map({ Date.dateToUnix(date: $0) })
        guard let upperUnixRange = unixRanges.first, let lowerUnixRange = unixRanges.last else { return }
        let filteredSyptoms = symptomsTest.filter { symptom in
            guard let symptomTime = symptom.time else { return false }
            return symptomTime >= upperUnixRange && symptomTime <= lowerUnixRange
        }
        
        for value in filteredSyptoms {
            if let symptomName = value.name {
                if self.filteredSymptoms[symptomName] != nil {
                    self.filteredSymptoms[symptomName]! += 1
                } else {
                    self.filteredSymptoms[symptomName] = 1
                }
            }
        }
    }
    
    
    /// Updates internal properties such as `loggedIn, falls, sos, fallsCount, sosCount, and groupedEmergencies` and is only called in `setupEmergencySubscriber`.
    ///
    /// ```
    /// HistoryViewModel.updateGroupedEmergenices().
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: Updated `falls, sos, fallsCount, sosCount, and groupedEmergencies`.
    func updateGroupedEmergencies() {
        self.checkAuth()
        
        if (self.loggedIn == true) {
            var emergencies: [Any] = self.falls + self.sos
            
            emergencies = emergencies.sorted { a, b in
                if let a = a as? Fall, let b = b as? SOS {
                    return a.time > b.time
                } else if let a = a as? SOS, let b = b as? Fall {
                    return a.time > b.time
                } else if let a = a as? Fall, let b = b as? Fall {
                    return a.time > b.time
                } else if let a = a as? SOS, let b = b as? SOS {
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
    
    /// Updates internal properties such as `idleCount, chargesCount, and groupedInactivities` and is only called in `setupEmergencySubscriber`.
    ///
    /// ```
    /// HistoryViewModel.updateGroupedInactivities().
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: Updated `idleCount, chargesCount, and groupedInactivities`.
    func updateGroupedInactivities() {
        self.checkAuth()
        
        if (self.loggedIn == true) {
            let filteredIdles: [Idle] = self.idles.filter {$0.taskState == "ended"}
            let filteredCharges: [Charge] = self.charges.filter {$0.taskState == "ended"}
            
            var inactivities: [Any] = filteredIdles + filteredCharges
            inactivities = inactivities.sorted { a, b in
                if let a = a as? Idle, let b = b as? Charge {
                    return a.startTime ?? 0 > b.startCharging ?? 0
                } else if let a = a as? Charge, let b = b as? Idle {
                    return a.startCharging ?? 0 > b.startTime ?? 0
                } else if let a = a as? Idle, let b = b as? Idle {
                    return a.startTime ?? 0 > b.startTime ?? 0
                } else if let a = a as? Charge, let b = b as? Charge {
                    return a.startCharging ?? 0 > b.startCharging ?? 0
                } else {
                    return false
                }
            }
            
            var inactivityDictionary: [String: [Any]] = [:]
            
            for inactivity in inactivities {
                if let idle = inactivity as? Idle {
                    let dateString = Date.unixToString(unix: idle.startTime ?? 0, timeOption: .date)
                    if var inactivities = inactivityDictionary[dateString] {
                        inactivities.append(idle)
                        inactivityDictionary[dateString] = inactivities
                    } else {
                        inactivityDictionary[dateString] = [idle]
                    }
                } else if let charging = inactivity as? Charge {
                    let dateString = Date.unixToString(unix: charging.startCharging ?? 0, timeOption: .date)
                    if var inactivities = inactivityDictionary[dateString] {
                        inactivities.append(charging)
                        inactivityDictionary[dateString] = inactivities
                    } else {
                        inactivityDictionary[dateString] = [charging]
                    }
                }
            }
            
            var uniqueKeys = Set<String>()
            
            let mappedKeys = inactivities.map { a in
                if let a = a as? Idle{
                    return a.startTime
                } else if let a = a as? Charge{
                    return a.startCharging
                } else {
                    return 0.0
                }
            }
            
            guard let firstDay = self.currentWeek.first else {return}
            guard let lastDay = self.currentWeek.last else {return}
            
            let sortedUnixKeys = mappedKeys.sorted {$0 ?? 0 > $1 ?? 0}
            let sortedKeys = sortedUnixKeys.compactMap { unix -> String? in
                if (
                    uniqueKeys.insert(Date.unixToString(unix: unix ?? 0, timeOption: .date)).inserted &&
                    Date(timeIntervalSince1970: unix ?? 0) >= firstDay &&
                    Date(timeIntervalSince1970: unix ?? 0) <= lastDay
                ){
                    return Date.unixToString(unix: unix ?? 0, timeOption: .date)
                }
                return nil
            }
            
            self.groupedInactivities = sortedKeys.map {($0, inactivityDictionary[$0]!)}
            
            var idle: Int = 0
            var charge: Int = 0
            
            for (_, inactivities) in self.groupedInactivities {
                for inactivity in inactivities {
                    if let _ = inactivity as? Idle {
                        idle += 1
                    } else if let _ = inactivity as? Charge {
                        charge += 1
                    }
                }
            }
            
            self.idleCount = idle
            self.chargeCount = charge
            self.loading = false
            
            self.convertInactivitiesToInactivityCharts()
        }
    }
    
    /// Updates internal properties such as `idleCount, chargesCount, and groupedInactivities` and is only called in `setupEmergencySubscriber`.
    ///
    /// ```
    /// HistoryViewModel.updateGroupedInactivities().
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: Updated `idleCount, chargesCount, and groupedInactivities`.
    ///
    func updateGroupedHeartAnomalies() {
        self.checkAuth()
        
        if (self.loggedIn == true) {
            let filteredHeartAnomalies = self.heartAnomalies.sorted { $0.time > $1.time }
            
            guard let firstDay = self.currentWeek.first else {return}
            guard let lastDay = self.currentWeek.last else {return}
            
            var heartAnomaliesDictionary: [String: [HeartAnomaly]] = [:]
            
            for heartAnomaly in filteredHeartAnomalies {
                let dateString = Date.unixToString(unix: heartAnomaly.time , timeOption: .date)
                
                if var heartAnomalies = heartAnomaliesDictionary[dateString] {
                    heartAnomalies.append(heartAnomaly)
                    heartAnomaliesDictionary[dateString] = heartAnomalies
                } else {
                    heartAnomaliesDictionary[dateString] = [heartAnomaly]
                }
                
            }
            
            var uniqueKeys = Set<String>()
            
            let unixKeys = filteredHeartAnomalies.compactMap {$0.time}
            let sortedUnixKeys = unixKeys.sorted {$0 > $1}
            let sortedKeys = sortedUnixKeys.compactMap { unix -> String? in
                if (uniqueKeys.insert(Date.unixToString(unix: unix, timeOption: .date)).inserted &&
                    Date(timeIntervalSince1970: unix) >= firstDay &&
                    Date(timeIntervalSince1970: unix) <= lastDay) {
                    return Date.unixToString(unix: unix, timeOption: .date)
                }
                return nil
            }
            
            self.groupedHeartAnomalies = sortedKeys.map {($0, heartAnomaliesDictionary[$0]!)}
            self.loading = false
        }
    }

    func updateGroupedSymptoms() {
        self.checkAuth()

        if (self.loggedIn == true) {
            let filteredSymptoms = self.symptomsTest.sorted { $0.time ?? 0 > $1.time ?? 0 }

            guard let firstDay = self.currentWeek.first else {return}
            guard let lastDay = self.currentWeek.last else {return}

            var symptomsDictionary: [String: [Symptom]] = [:]

            for symptom in filteredSymptoms {
                let dateString = Date.unixToString(unix: symptom.time ?? 0 , timeOption: .date)

                if var symptoms = symptomsDictionary[dateString] {
                    symptoms.append(symptom)
                    symptomsDictionary[dateString] = symptoms
                } else {
                    symptomsDictionary[dateString] = [symptom]
                }

            }

            var uniqueKeys = Set<String>()

            let unixKeys = filteredSymptoms.compactMap {$0.time}
            let sortedUnixKeys = unixKeys.sorted {$0 > $1}
            let sortedKeys = sortedUnixKeys.compactMap { unix -> String? in
                if (uniqueKeys.insert(Date.unixToString(unix: unix, timeOption: .date)).inserted &&
                    Date(timeIntervalSince1970: unix) >= firstDay &&
                    Date(timeIntervalSince1970: unix) <= lastDay) {
                    return Date.unixToString(unix: unix, timeOption: .date)
                }
                return nil
            }

            self.groupedSymptoms = sortedKeys.map {($0, symptomsDictionary[$0]!)}
            self.loading = false
        }
    }

    /// Updates internal properties such as `loggedIn`and is called in HistoryViewModel only.
    ///
    /// ```
    /// HistoryViewModel.checkAuth().
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: Updated `self.loggedIn`.
    func checkAuth() {
        if ((Auth.auth().currentUser) != nil) {
            self.loggedIn = true
        } else {
            self.loggedIn = false
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
    
    /// Updates internal properties such as `currentDay` and `currentWeek`.
    ///
    /// ```
    /// HistoryViewModel.fetchCurrentWeek()
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: Updated `currentDay` and `currentWeek` .
    func fetchCurrentWeek() {
        currentWeek = []
        
        let calendar = Calendar.current
        
        let week = calendar.dateInterval(of: .weekOfMonth, for: self.currentDay)
        
        guard let firstWeekDay = week?.start else {
            return
        }
        
        (0...6).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: firstWeekDay) {
                currentWeek.append(weekday)
            }
        }
        
        currentWeek[currentWeek.count - 1] = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: currentWeek.last!) ?? currentWeek.last!
        
        withAnimation {
            self.fetchCurrentWeekData()
            self.updateSymptoms()
            self.updateGroupedSymptoms()
            self.updateGroupedEmergencies()
            self.updateGroupedInactivities()
            self.updateGroupedHeartAnomalies()
            self.convertHeartbeatsToHeartRateChart()
        }
        
        //checkFinishLoading()
    }
    
    
    
    func checkFinishLoading() {
        if symptomFinish && chargeFinish && anomaliesFinish && idleFinish && heartFinish && fallFinish && sosFinish {
            
            if self.isLoading && self.guardLoading == true {
                print("From History: Entered this statement")
                guardLoading = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        self.isLoading = false
                        print("From History: CHANGED LOADING")
                    }
                }
            }
        }
    }
    
    /// Updates internal properties such as `currentDay` and `currentWeek`.
    ///
    /// ```
    /// HistoryViewModel.fetchCurrentWeek()
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: Updated `currentDay` and `currentWeek` .
    func convertInactivitiesToInactivityCharts() {
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
        self.fetchCurrentWeekData()
    }
    
    /// Updates internal properties such as `currentDay` and `currentWeek`.
    ///
    /// ```
    /// HistoryViewModel.fetchCurrentWeek()
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: Updated `currentDay` and `currentWeek` .
    func convertHeartbeatsToHeartRateChart() {
        let calendar = Calendar.current
        
        var heartbeatDictionary: [Date: [Heartbeat]] = [:]
        
        for heartbeat in self.heartbeats {
            var heartbeatDate = Date(timeIntervalSince1970: heartbeat.time)
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: heartbeatDate)
            dateComponents.hour = 0
            dateComponents.minute = 0
            
            heartbeatDate = calendar.date(from: dateComponents) ?? Date()
            
            if var heartbeatArray = heartbeatDictionary[heartbeatDate] {
                heartbeatArray.append(heartbeat)
                heartbeatDictionary[heartbeatDate] = heartbeatArray
            } else {
                heartbeatDictionary[heartbeatDate] = [heartbeat]
            }
        }
        
        var heartrateChartList: [HeartRateChart] = []
        
        for (date, heartbeats) in heartbeatDictionary {
            var totalBpm: Double = 0
            var count: Double = 0
            var averageBpm: Double = 0
            for heartbeat in heartbeats {
                count += 1
                totalBpm += heartbeat.bpm
            }
            
            averageBpm = totalBpm / count
            heartrateChartList.append(HeartRateChart(day: date, avgHeartRate: Int(averageBpm)))
        }
        
        self.heartbeatDataTemp = heartrateChartList
        self.fetchCurrentWeekData()
    }
    
    /// Updates `inactivityData` from `inactivityDataTemp`.
    ///
    /// ```
    /// HistoryViewModel.fetchCurrentWeekData()
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: Updated `inactivityData` .
    func fetchCurrentWeekData() {
        self.inactivityData = []
        self.heartRateData = []
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
                    }
                    if i == 1 {
                        inactivity[i].type = "Charging"
                    }
                }
                self.inactivityData.append(inactivity[i])
            }
            
            var heartRate = HeartRateChart()
            self.heartbeatDataTemp.forEach { data in
                if data.day == tempDate {
                    heartRate.day = data.day
                    heartRate.avgHeartRate = data.avgHeartRate
                }
            }
            if heartRate.avgHeartRate == 0 {
                heartRate.day = tempDate
                heartRate.avgHeartRate = 0
            }
            self.heartRateData.append(heartRate)
            
            tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate) ?? Date()
        }
        
        countTotalWeekData()
        countAvgHeartRate()
    }
    
    /// Updates `totalIdleTime` and `totalChargingTime` from data.
    ///
    /// ```
    /// HistoryViewModel.countTotalWeekData()
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: Updated `totalIdleTime` and `totalChargingTime` .
    func countTotalWeekData() {
        var totalIdle = 0
        var totalCharging = 0
        
        inactivityData.forEach { data in
            if data.type == "Idle" {
                totalIdle += data.minutes
            }
            if data.type == "Charging" {
                totalCharging += data.minutes
            }
        }
        
        self.totalIdleTime = convertToHoursMinutes(minutes: totalIdle)
        self.totalChargingTime = convertToHoursMinutes(minutes: totalCharging)
        self.loading = false
    }
    
    func countAvgHeartRate() {
        avgHeartRate = 0
        var dayCount = 0
        
        heartRateData.forEach { data in
            if data.avgHeartRate > 0 {
                avgHeartRate += data.avgHeartRate
                dayCount += 1
            }
        }
        
        if dayCount == 0 {
            dayCount += 1
        }
        
        avgHeartRate = avgHeartRate / dayCount
    }
    
    //    func countSymptom() {
    //        symptomsDummyData.forEach { symptom in
    //            if var symptomType = symptoms.first(where: { (key, value)->Bool in key == symptom.name }) {
    //                symptoms[symptomType.key]! += 1
    //            }
    //        }
    //    }
    
    /// Formats Date object into String.
    ///
    /// ```
    /// HistoryViewModel.extractDate(Date.now)
    /// ```
    ///
    /// - Parameters:
    ///     - date: Date
    ///     - format: String
    /// - Returns: String
    func extractDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        
        return formatter.string(from: date)
    }
    
    /// Checks if date is today.
    ///
    /// ```
    /// HistoryViewModel.isToday(Date.now)
    /// ```
    ///
    /// - Parameters:
    ///     - date: Date
    /// - Returns: true, false
    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        
        return calendar.isDate(currentDay, inSameDayAs: date)
    }
    
    /// Returns hours and minutes in `String` from minutes in`Int` .
    ///
    /// ```
    /// HistoryViewModel.convertToHoursMinutes(minutes: 3)
    /// ```
    ///
    /// - Parameters:
    ///     - minutes: Int
    /// - Returns: "\(hours)h \(remainingMinutes)m"
    func convertToHoursMinutes(minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)h \(remainingMinutes)m"
    }
}

enum HistoryCardOption: String, CaseIterable, Identifiable {
    case fell, pressed, idle, charging, lowHeartRate, highHeartRate, irregularHeartRate
    var id: Self { self }
}

enum ChangeWeek: String, CaseIterable {
    case next, previous
}
