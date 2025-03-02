//
//  ChargingService.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 24/10/23.
//

import Foundation
import Combine
import Firebase

final class BatteryChargingService {
    static let shared = BatteryChargingService()
    @Published var batteryDocumentChanges = [DocumentChange]()
    @Published var userData: UserData?
    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    private var batteryListener: [ListenerRegistration] = []


    func deinitializerFunction() {
        batteryListener.forEach({ $0.remove() })
        batteryListener = []
        batteryDocumentChanges = []
    }

    func fetchBatteryLevel() async throws -> [BatteryLevel] {
        let snapshot = try await FirestoreConstants.batteryLevelCollection.getDocuments()
        let batteryLevels = snapshot.documents.compactMap({ try? $0.data(as: BatteryLevel.self) })
        return batteryLevels
    }
    
    func fetchChargingRecord() async throws -> [ChargingRange] {
        let snapshot = try await FirestoreConstants.chargesCollection.getDocuments()
        let chargingRanges = snapshot.documents.compactMap({ try? $0.data(as: ChargingRange.self) })
        return chargingRanges
    }
    
    func createBatteryLevel(batteryLevel: BatteryLevel) async throws {
        do {
            let encodedData = try Firestore.Encoder().encode(batteryLevel)
            try await FirestoreConstants.batteryLevelCollection.document().setData(encodedData)
            print("Successfully created battery level record!")
        } catch {
            print("Error decoding with: \(error)")
        }
        
    }
    
    func updateBatteryLevel(batteryLevel: BatteryLevel) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
//        guard let encodedData = try? Firestore.Encoder().encode(batteryLevel) else { return }
        let documents = try await FirestoreConstants.batteryLevelCollection.whereField("seniorId", isEqualTo: uid).getDocuments().documents.first
        guard let batteryState = batteryLevel.iphoneBatteryState, let iphonebatteryLevel = batteryLevel.iphoneBatteryLevel, let lastUpdated = batteryLevel.iphoneLastUpdatedAt else { return }
        try await documents?.reference.updateData([
            "iphoneBatteryState": batteryState,
            "iphoneBatteryLevel": iphonebatteryLevel,
            "iphoneLastUpdatedAt": lastUpdated,
        ])
    }
    
    func createChargingRecord(chargingRange: ChargingRange) async throws {
        guard let encodedData = try? Firestore.Encoder().encode(chargingRange) else { return }
        try await FirestoreConstants.chargesCollection.document().setData(encodedData)
    }
    
    func updateChargingRecord(chargingRange: ChargingRange) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let encodedData = try? Firestore.Encoder().encode(chargingRange) else { return }
        let documents = try await FirestoreConstants.chargesCollection.whereField("seniorId", isEqualTo: uid).getDocuments().documents.first
        try await documents?.reference.updateData(encodedData)
    }
    
    func deleteChargingRecord(startCharging: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let documents = try await FirestoreConstants.chargesCollection
            .whereField("seniorId", isEqualTo: uid)
            .whereField("startCharging", isEqualTo: startCharging)
            .getDocuments().documents
        
        print(documents)
        
        for document in documents {
            try await document.reference.delete()
        }
    }
    
    func observeBatteryStateLevelSpecific() {
        guard let uid = UserDefaults.standard.string(forKey: "selectedSenior") else { return }
        let query = FirestoreConstants.batteryLevelCollection
            .whereField("seniorId", isEqualTo: uid)
            .limit(to: 1)
        
        batteryListener.append(query.addSnapshotListener { [weak self] querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            self?.batteryDocumentChanges = changes
        })
    }
}
