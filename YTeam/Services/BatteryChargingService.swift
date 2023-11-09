//
//  ChargingService.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 24/10/23.
//

import Foundation
import Firebase

final class BatteryChargingService {
    static let shared = BatteryChargingService()
    @Published var batteryDocumentChanges = [DocumentChange]()
    @Published var idleDocumentChanges = [DocumentChange]()
    @Published var latestLocationDocumentChanges = [DocumentChange]()
    @Published var heartRateDocumentChanges = [DocumentChange]()

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

    func createBatteryLevel(batteryLevel: Int) async throws {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let currentUid = UserDefaults.standard.string(forKey: "selectedSenior") else { return }
        let batteryLevelRecord: BatteryLevel = BatteryLevel(seniorId: currentUid, iphoneBatteryLevel: batteryLevel.description, iphoneLastUpdatedAt: Date.now.description)
        do {
            let encodedData = try Firestore.Encoder().encode(batteryLevelRecord)
            try await FirestoreConstants.batteryLevelCollection.document().setData(encodedData)
            print("Successfully created battery level record!")
        } catch {
            print("Error decoding with: \(error)")
        }

    }

    func updateBatteryLevel(batteryLevel: BatteryLevel) async throws {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let currentUid = UserDefaults.standard.string(forKey: "selectedSenior") else { return }
        guard let encodedData = try? Firestore.Encoder().encode(batteryLevel) else { return }
        let documents = try await FirestoreConstants.batteryLevelCollection.whereField("seniorId", isEqualTo: currentUid).getDocuments().documents.first
        try await documents?.reference.updateData(encodedData)
    }

    func createChargingRecord(chargingRange: ChargingRange) async throws {
        guard let encodedData = try? Firestore.Encoder().encode(chargingRange) else { return }
        try await FirestoreConstants.chargesCollection.document().setData(encodedData)
    }

    func updateChargingRecord(chargingRange: ChargingRange) async throws {
//        guard let uid = Auth.auth().currentUser?.uid else { return }

        guard let currentUid = UserDefaults.standard.string(forKey: "selectedSenior") else { return }
        guard let encodedData = try? Firestore.Encoder().encode(chargingRange) else { return }
        let documents = try await FirestoreConstants.chargesCollection.whereField("seniorId", isEqualTo: currentUid).getDocuments().documents.first
        try await documents?.reference.updateData(encodedData)
    }

    func deleteChargingRecord(startCharging: String) async throws {
//        guard let uid = Auth.auth().currentUser?.uid else { return }

        guard let currentUid = UserDefaults.standard.string(forKey: "selectedSenior") else { return }

        print(startCharging )
        let documents = try await FirestoreConstants.chargesCollection
            .whereField("seniorId", isEqualTo: currentUid)
            .whereField("startCharging", isEqualTo: startCharging)
            .getDocuments().documents

        print(documents)

        for document in documents {
            try await document.reference.delete()
        }
    }

    func observeBatteryStateLevelSpecific() {
//        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let currentUid = UserDefaults.standard.string(forKey: "selectedSenior") else { return }
        
        let query = FirestoreConstants.batteryLevelCollection
            .whereField("seniorID", isEqualTo: currentUid)
            .limit(to: 1)

        query.addSnapshotListener { querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            self.batteryDocumentChanges = changes
        }
    }

    func observeIdleSpecific() {
//        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let currentUid = UserDefaults.standard.string(forKey: "selectedSenior") else { return }

        let query = FirestoreConstants.idlesCollection
            .whereField("seniorId", isEqualTo: currentUid)

        query.addSnapshotListener { querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            self.idleDocumentChanges = changes
        }
    }

    func observeLiveLocationSpecific() {
//        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let currentUid = UserDefaults.standard.string(forKey: "selectedSenior") else { return }

        let query = FirestoreConstants.liveLocationsCollection
            .whereField("seniorId", isEqualTo: currentUid)
            .order(by: "createdAt", descending: true)
            .limit(to: 1)

        query.addSnapshotListener { querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            self.latestLocationDocumentChanges = changes
        }
    }

    func observeHeartRateSpecific() {
        guard let currentUid = UserDefaults.standard.string(forKey: "selectedSenior") else { return }

        let query = FirestoreConstants.heartbeatCollection
            .whereField("seniorId", isEqualTo: currentUid)
            .order(by: "time", descending: true)
            .limit(to: 1)

        query.addSnapshotListener { querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            self.heartRateDocumentChanges = changes
        }
    }
}
