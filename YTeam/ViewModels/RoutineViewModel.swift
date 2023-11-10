//
//  RoutineViewModel.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 05/11/23.
//

import Foundation
import Combine

class RoutineViewModel: ObservableObject {
    @Published var showAddRoutine: Bool = false
    @Published var showEditRoutine: Bool = false
    
    @Published var currentWeek: [Date] = []
    @Published var currentDay: Date = Date()
    
    @Published var routines: [Routine] = []
    @Published var progressCount: Double = 0
    
    private var routineData: [RoutineData] = []
    private var cancellables = Set<AnyCancellable>()
    
    private let routineService: RoutineService = RoutineService.shared
    
    init() {
        setupRoutineSubscribers()
        fetchCurrentWeek()
//        routines = routinesDummyData
        countProgress()
    }
    
    func setupRoutineSubscribers() {
        routineService.$routines
            .receive(on: DispatchQueue.main)
            .sink { [weak self] routine in
                guard let self else { return }
                
                self.routineData.append(contentsOf: routine)
                print(routineData)
                self.fetchCurrentWeek()
            }
            .store(in: &cancellables)
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
        
        self.convertRoutineDataToRoutine()
    }
    
    func convertRoutineDataToRoutine() {
        self.routines = self.routineData.map { routine in
            var medicineUnit: MedicineUnit
            var routineTime: [Date] = []
            
            for time in routine.time {
                routineTime.append( Date(timeIntervalSince1970: time))
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
            
            return Routine(id: routine.id, type: routine.type, time: routineTime, activity: routine.activity, description: routine.description, medicine: routine.medicine, medicineAmount: routine.medicineAmount, medicineUnit: medicineUnit, isDone: routine.isDone)
        }
        
        self.countProgress()
    }
    
    func updateRoutine(routine: Routine, index: Int) {
        //Add Update Routine
    }
    func countProgress() {
        var totalProgress: Double = 0
        
        routines.forEach { routine in
            routine.isDone.forEach { done in
                if done == true {
                    progressCount += 1
                }
                totalProgress += 1
            }
        }
        
        if totalProgress == 0 {
            totalProgress += 1
        }
        
        progressCount = (progressCount / totalProgress)
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
    
    func extractDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
}
