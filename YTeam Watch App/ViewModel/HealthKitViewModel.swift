//
//  HealthKitViewModel.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 30/10/23.
//

import Foundation
import HealthKit

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
        if (!HKHealthStore.isHealthDataAvailable()) {
            self.dataAvailable = true
        }
        
        self.healthStore.requestAuthorization(toShare: nil, read: self.heartRateQuantitySet) { (success, error) in
            if success {
                self.authorized = true
            }
        }
        
        if (self.healthStore.authorizationStatus(for: self.heartRateQuantityType) == .sharingAuthorized) {
            self.authorized = true
        }
        
        self.startHeartbeatUpdate()
    }
    
    func checkAuthorization() {
        if (self.healthStore.authorizationStatus(for: self.heartRateQuantityType) != .sharingAuthorized) {
            self.healthStore.requestAuthorization(toShare: nil, read: self.heartRateQuantitySet) { (success, error) in
                if success {
                    self.authorized = true
                }
            }
        }
    }
    
    func startHeartbeatUpdate() {
        checkAuthorization()
        debugPrint(self.healthStore.authorizationStatus(for: self.heartRateQuantityType))
        guard self.authorized == true else {return}
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { query, samples, deletedObjects, anchor, error in
            if let quantitySamples = samples as? [HKQuantitySample] {
                if let heartRateValue = quantitySamples.last?.quantity.doubleValue(for: HKUnit(from: "count/min")) {
                    self.heartRate = Int(heartRateValue)
                }
            }
        }
        
        debugPrint("I reached here!")
        self.healthStore.execute(query)
    }
}
