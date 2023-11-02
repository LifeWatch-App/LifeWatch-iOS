//
//  HealthKitViewModel.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 30/10/23.
//

import Foundation
import HealthKit

@MainActor
class HeartManager: ObservableObject {
    @Published var dataAvailable: Bool = false
    @Published var heartRate: Int = 0
    @Published var highHeartRate: Bool = false
    @Published var lowHeartRate: Bool = false
    @Published var irregularHeartRate: Bool = false
    
    private var healthStore: HKHealthStore = HKHealthStore()
    private var authorized: Bool = false
    
    private let heartHealthKitSet = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!, HKQuantityType.categoryType(forIdentifier: .highHeartRateEvent)!, HKQuantityType.categoryType(forIdentifier: .lowHeartRateEvent)!, HKQuantityType.categoryType(forIdentifier: .irregularHeartRhythmEvent)!])
    private let heartRateQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private let highHeartEventType = HKQuantityType.categoryType(forIdentifier: .highHeartRateEvent)!
    private let lowHeartEventType = HKQuantityType.categoryType(forIdentifier: .lowHeartRateEvent)!
    private let irregularHeartEventType = HKQuantityType.categoryType(forIdentifier: .irregularHeartRhythmEvent)!
    
    private var myAnchor: HKQueryAnchor?
    private var updateTask: Task<Void, Never>?
    
    private var lowHeartRateObserverReady: Bool = false
    private var highHeartRateObserverReady: Bool = false
    private var irregularHeartRhythmObserverReady: Bool = false
    
    init() {
        if (HKHealthStore.isHealthDataAvailable()) {
            self.dataAvailable = true
        }
        
        self.healthStore.requestAuthorization(toShare: nil, read: self.heartHealthKitSet) { (success, error) in
            if !success {
                self.dataAvailable = false
            }
        }
        
        if (self.dataAvailable) {
            self.setHeartRateObserver()
            self.setHighHeartRateObserver()
            self.setLowHeartRateObserver()
            self.setIrregularHeartRateObserver()
        }
    }
    
    @MainActor
    func setLowHeartRateObserver() {
        let observerQuery = HKObserverQuery(sampleType: self.lowHeartEventType, predicate: nil) { query, completionHandler, error in
            
            if (self.lowHeartRateObserverReady) {
                self.lowHeartRate = true
                debugPrint("Low Heart Rate Detected")
            }
            
            if let error = error {
                print("Error observing heart rate: \(error.localizedDescription)")
                return
            } else {
                self.lowHeartRateObserverReady = true
            }
            
            completionHandler()
        }

        self.healthStore.enableBackgroundDelivery(for: self.lowHeartEventType, frequency: .immediate) { (success, error) in
            if !success {
                print("Failed to enable background delivery for low heart event updates: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        
        self.healthStore.execute(observerQuery)
    }
    
    @MainActor
    func setHighHeartRateObserver() {
        let observerQuery = HKObserverQuery(sampleType: self.highHeartEventType, predicate: nil) { query, completionHandler, error in
        
            if (self.highHeartRateObserverReady) {
                self.highHeartRate = true
                debugPrint("High Heart Rate Detected")
            }
            
            if let error = error {
                print("Error observing heart rate: \(error.localizedDescription)")
            } else {
                self.highHeartRateObserverReady = true
            }
            
            completionHandler()
        }

        self.healthStore.enableBackgroundDelivery(for: self.highHeartEventType, frequency: .immediate) { (success, error) in
            if !success {
                print("Failed to enable background delivery for high heart event updates: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        
        self.healthStore.execute(observerQuery)
    }
    
    @MainActor
    func setIrregularHeartRateObserver() {
        let observerQuery = HKObserverQuery(sampleType: self.irregularHeartEventType, predicate: nil) { query, completionHandler, error in
            
            if (self.irregularHeartRhythmObserverReady) {
                self.irregularHeartRate = true
                debugPrint("Irregular Heart Rate Detected")
            }
            
            if let error = error {
                print("Error observing heart rate: \(error.localizedDescription)")
            } else {
                self.irregularHeartRhythmObserverReady = true
            }
            
            completionHandler()
        }

        self.healthStore.enableBackgroundDelivery(for: self.irregularHeartEventType, frequency: .immediate) { (success, error) in
            if !success {
                print("Failed to enable background delivery for high heart event updates: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        
        self.healthStore.execute(observerQuery)
    }
    
    @MainActor
    func setHeartRateObserver() {
        let observerQuery = HKObserverQuery(sampleType: self.heartRateQuantityType, predicate: nil) { query, completionHandler, error in
            if let error = error {
                print("Error observing heart rate: \(error.localizedDescription)")
            } else {
                self.updateHeartRate()
            }
            completionHandler()
        }

        self.healthStore.enableBackgroundDelivery(for: self.heartRateQuantityType, frequency: .immediate) { (success, error) in
            if !success {
                print("Failed to enable background delivery for heart rate updates: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        
        self.healthStore.execute(observerQuery)
    }
    
    @MainActor
    func resetAbnormalHeartRateStatus() {
        self.lowHeartRate = false
        self.highHeartRate = false
        self.irregularHeartRate = false
    }
    
    func updateHeartRate() {
        let query = HKSampleQuery(sampleType: self.heartRateQuantityType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { query, samples, error in
            if let sample = samples?.first as? HKQuantitySample {
                let heartRateValue = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                debugPrint(heartRateValue)
                self.heartRate = Int(heartRateValue)
            }
        }
        
        self.healthStore.execute(query)
    }
}
