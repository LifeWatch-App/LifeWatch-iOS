//
//  FirestoreConstants.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 17/10/23.
//

import Foundation
import Firebase

/// Calls the intended collection
///  `FirestoreConstants.<collection>`
///
/// Returns: Firestore Collection Reference
struct FirestoreConstants {
    static let fallsCollection = Firestore.firestore().collection("falls")
    static let chargesCollection = Firestore.firestore().collection("charges")
    static let sosCollection = Firestore.firestore().collection("sos")
    static let idlesCollection = Firestore.firestore().collection("idles")
    static let batteryLevelCollection = Firestore.firestore().collection("batteryLevels")
    static let liveLocationsCollection = Firestore.firestore().collection("liveLocations")
    static let homeLocationCollection = Firestore.firestore().collection("homeLocations")
    static let heartAnomalyCollection = Firestore.firestore().collection("heartAnomaly")
    static let heartbeatCollection = Firestore.firestore().collection("heartbeat")
    static let pttCollection = Firestore.firestore().collection("ptt")
    static let routinesCollection = Firestore.firestore().collection("routines")
    static let symptomsCollection = Firestore.firestore().collection("symptoms")
}


