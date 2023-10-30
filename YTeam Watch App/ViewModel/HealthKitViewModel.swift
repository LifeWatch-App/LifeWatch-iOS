//
//  HealthKitViewModel.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 30/10/23.
//

import Foundation
import HealthKit

@MainActor
class HealthKitViewModel: ObservableObject {
    @Published var dataAvailable: Bool = false
    @Published var heartRate: Int = 0
    
    private var healthStore: HKHealthStore = HKHealthStore()
    private var authorized: Bool = false
    
    private let heartRateQuantitySet = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!])
    private let heartRateQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    
    private var myAnchor: HKQueryAnchor?
    private var updateTask: Task<Void, Never>?
    
    init() {
        if (HKHealthStore.isHealthDataAvailable()) {
            self.dataAvailable = true
        }
        
        self.healthStore.requestAuthorization(toShare: nil, read: self.heartRateQuantitySet) { (success, error) in
            if !success {
                self.dataAvailable = false
            }
        }
        
        if (self.dataAvailable) {
            self.setHeartRateObserver()
        }
    }
    
    
    @MainActor
    func setHeartRateObserver() {
        let observerQuery = HKObserverQuery(sampleType: self.heartRateQuantityType, predicate: nil) { query, completionHandler, error in
            if let error = error {
                print("Error observing heart rate: \(error.localizedDescription)")
            } else {
                self.updateHeartRate()
            }
        }

        self.healthStore.execute(observerQuery)

        self.healthStore.enableBackgroundDelivery(for: self.heartRateQuantityType, frequency: .immediate) { (success, error) in
            if !success {
                print("Failed to enable background delivery for heart rate updates: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func updateHeartRate() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { query, samples, error in
            if let sample = samples?.first as? HKQuantitySample {
                let heartRateValue = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                self.heartRate = Int(heartRateValue)
            }
        }
        
        self.healthStore.execute(query)
    }
}
