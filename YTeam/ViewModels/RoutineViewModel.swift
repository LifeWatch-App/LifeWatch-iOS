//
//  RoutineViewModel.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 05/11/23.
//

import Foundation
import SwiftUI
import Combine

class RoutineViewModel: ObservableObject {
    @Published var showAddRoutine: Bool = false
    @Published var showEditRoutine: Bool = false
    @Published var userRole: UserRole = .unknown
    @Published var currentWeek: [Date] = []
    @Published var viewHasAppeared = false
    @Published var currentDay: Date = Date()
    @Published var isLoading: Bool = true
    @Published var shouldReloadData: Bool = false

    @Published var routines: [Routine] = []
    @Published var dailyRoutines: [Routine] = []
    @Published var progressCount: [Double] = [0, 0, 0, 0, 0, 0, 0]

    private var routineData: [RoutineData] = []
    private var cancellables = Set<AnyCancellable>()

    private var guardLoading = true
    
    @Published var selectedUserId: String?
    private let authService = AuthService.shared

    private var routineFinish = false
    private var deleteRoutineFinish = false

    private let routineService: RoutineService = RoutineService.shared

    init() {
        setupRoutineSubscribers()
        //fetchCurrentWeek()
        //                routines = routinesDummyData

        //        countProgress()
    }

    func setupRoutineSubscribers() {
        authService.$userData
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userData in
                guard let self else {return}
                print("User Data: ", userData)

                var role: UserRole = .unknown

                if (userData?.role == "caregiver") {
                    role = .caregiver
                }

                if (userData?.role == "senior") {
                    role = .senior
                }

                self.userRole = role
            }
            .store(in: &cancellables)

        authService.$selectedInviteId
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] id in
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
                if id != nil && userData?.role != nil && viewAppeared == true {
                    self?.viewHasAppeared = false
                    if self?.shouldReloadData == true {
                        if self?.isLoading == false {
                            withAnimation {
                                self?.guardLoading = true
                                self?.isLoading = true
                                self?.routineData = []
//                                self?.routines = []
//                                self?.dailyRoutines = []
                                self?.routineFinish = false
                            }
                        }

                        self?.routineService.observeAllRoutinesDashboard(userData: userData)
                        self?.routineService.observeAllDeletedRoutinesDashboard(userData: userData)
                        self?.fetchCurrentWeek()
                        self?.shouldReloadData = false
                    }
                }
            }
            .store(in: &cancellables)

            routineService.$routinesDashboard
            .receive(on: DispatchQueue.main)
            .sink { [weak self] routines in
                guard let self else { return }

                print("RoutineCounts", routines.count)

                for (_, routine) in routines.enumerated() {
                    if let concurrentIndex = self.routineData.firstIndex(where: {$0.id == routine.id}) {
                        self.routineData[concurrentIndex] = routine
                    } else {
                        self.routineData.append(routine)
                    }

                    self.fetchCurrentWeek()
                }

                routineFinish = true
                checkFinishLoading()
            }
            .store(in: &cancellables)

        routineService.$deletedRoutineDashboard
            .receive(on: DispatchQueue.main)
            .sink { [weak self] routines in
                guard let self else { return }
                guard routines.count > 0 else {return}
                print(routines)
                if let index = self.routineData.firstIndex(where: { $0.id == routines[0].id }) {
                    self.routineData.remove(at: index)
                }
                routineService.removeDeletedRoutines()
                self.fetchCurrentWeek()
            }
            .store(in: &cancellables)
    }

    func checkFinishLoading() {
        if routineFinish {
            if self.isLoading && self.guardLoading == true {
                guardLoading = false
                print("From Routine: Entered this statement")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        self.isLoading = false
                    }
                }
            }
        }
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
                //                weekday = calendar.date(byAdding: .hour, value: 18, to: weekday) ?? Date()
                currentWeek.append(weekday)
            }
        }

        currentWeek[currentWeek.count-1] = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: currentWeek.last!) ?? currentWeek.last!

        print("Last Week: ", currentWeek)
        self.convertRoutineDataToRoutine()

        countProgress()
    }

    func convertRoutineDataToRoutine() {
        self.routines = self.routineData
            .compactMap { routine in
                var medicineUnit: MedicineUnit
                var routineTime: [Date] = []

                for time in routine.time {
                    routineTime.append(Date(timeIntervalSince1970: time))
                }

                switch (routine.medicineUnit) {
                case "CC":
                    medicineUnit = .CC
                case "Pill":
                    medicineUnit = .Pill
                case "Gram":
                    medicineUnit = .Gram
                case "Litre":
                    medicineUnit = .Litre
                case "Mililitre":
                    medicineUnit = .Mililitre
                default:
                    medicineUnit = .Tablet
                }

                return Routine(id: routine.id, type: routine.type, seniorId: routine.seniorId, time: routineTime, activity: routine.activity, description: routine.description, medicine: routine.medicine, medicineAmount: routine.medicineAmount, medicineUnit: medicineUnit, isDone: routine.isDone)
            }
            .filter { routine in
                routine.time.contains { time in
                    currentWeek.first! <= time && time <= currentWeek.last!
                }
            }
            .sorted { routine1, routine2 in
                let time1 = routine1.time[0]
                let time2 = routine2.time[0]

                return time1 < time2
            }

        self.dailyRoutineData()
    }


    func dailyRoutineData() {
        dailyRoutines = []

        for routine in self.routines {
            if isToday(date: routine.time.first ?? Date()) {
                print("Daily Routine Data Time", time)
                dailyRoutines.append(routine)
            }
        }

        print("Routines: ", dailyRoutines.count)
    }

    func countProgress() {
        progressCount = [0, 0, 0, 0, 0, 0, 0]

        for (index, day) in currentWeek.enumerated() {
            var totalProgress: Double = 0

            routines.forEach { routine in
                if isSameDate(date1: routine.time.first ?? Date(), date2: day) {
                    routine.isDone.forEach { done in
                        if done == true {
                            progressCount[index] += 1
                        }
                        totalProgress += 1
                    }
                }
            }

            if totalProgress == 0 {
                totalProgress += 1
            }

            progressCount[index] = (progressCount[index] / totalProgress)
        }

        print("Progress count:", progressCount)
    }

    func updateSingleRoutineCheck(routine: Routine) {
        let routineDataDate: [Double] = routine.time.map { time in
            return time.timeIntervalSince1970
        }

        var newIsDone: [Bool] = routine.isDone
        newIsDone[0].toggle()

        let newRoutine: RoutineData = RoutineData(id: routine.id, seniorId: routine.seniorId ?? "", type: routine.type, time: routineDataDate, activity: routine.activity ?? "", description: routine.description ?? "", medicine: routine.medicine ?? "", medicineAmount: routine.medicineAmount ?? "", medicineUnit: routine.medicineUnit?.rawValue ?? "", isDone: newIsDone)

        Task { try? await routineService.updateRoutine(routine: newRoutine)}
    }

    func updateRoutineCheck(routine: Routine, index: Int) {

        let routineDataDate: [Double] = routine.time.map { time in
            return time.timeIntervalSince1970
        }

        var newIsDone: [Bool] = routine.isDone
        newIsDone[index].toggle()

        let newRoutine: RoutineData = RoutineData(id: routine.id, seniorId: routine.seniorId ?? "", type: routine.type, time: routineDataDate, activity: routine.activity ?? "", description: routine.description ?? "", medicine: routine.medicine ?? "", medicineAmount: routine.medicineAmount ?? "", medicineUnit: routine.medicineUnit?.rawValue ?? "", isDone: newIsDone)

        Task { try? await routineService.updateRoutine(routine: newRoutine)}
    }

    func changeWeek(type: ChangeWeek) {

        if type == .next {
            currentDay = Calendar.current.date(byAdding: .day, value: 7, to: currentDay) ?? Date()
        } else {
            currentDay = Calendar.current.date(byAdding: .day, value: -7, to: currentDay) ?? Date()
        }

        self.fetchCurrentWeek()
    }

    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current

        return calendar.isDate(currentDay, inSameDayAs: date)
    }

    func isTodayAndAfter() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())

        return self.currentDay >= today
    }

    func isSameDate(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current

        return calendar.isDate(date1, inSameDayAs: date2)
    }

    func extractDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format

        return formatter.string(from: date)
    }
}
