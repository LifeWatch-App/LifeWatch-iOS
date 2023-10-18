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
}

