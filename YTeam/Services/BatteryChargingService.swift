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

    func fetchBatteryLevel() async throws -> [BatteryLevel] {
        let snapshot = try await FirestoreConstants.batteryLevelCollection.getDocuments()

        var batteryLevels = snapshot.documents.compactMap({ try? $0.data(as: BatteryLevel.self)})

        return batteryLevels
    }

    func fetchChargingRecord() async throws -> [ChargingRange] {
        let snapshot = try await FirestoreConstants.chargingCollection.getDocuments()
        var chargingRanges = snapshot.documents.compactMap({ try? $0.data(as: ChargingRange.self)})
        return chargingRanges
    }

    func createBatteryLevel(batteryLevel: Int) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let batteryLevelRecord: BatteryLevel = BatteryLevel(seniorID: uid, iphoneBatteryLevel: batteryLevel.description, iphoneLastUpdatedAt: Date.now.description)
        guard let encodedData = try? Firestore.Encoder().encode(batteryLevelRecord) else { return }
        try await FirestoreConstants.batteryLevelCollection.document().setData(encodedData)
    }

    func updateBatteryLevel() {
        //fetch battery level of current user
        //send the new data with the updated data
    }

    func createChargingRecord() {

    }

    func updateChargingRecord() {

    }
}
