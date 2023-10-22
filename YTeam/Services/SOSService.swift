//
//  SOSService.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 22/10/23.
//

import Foundation
import Firebase

class SOSService {
    static let shared: SOSService = SOSService()
    
    @MainActor
    func sendSOS() async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let sosCollection = FirestoreConstants.sosCollection
        let SOS = SOS(seniorId: userId, time: Date.now.timeIntervalSince1970)
        
        guard let encodedSOSData = try? Firestore.Encoder().encode(SOS) else { return }
        
        try? await sosCollection.document().setData(encodedSOSData)
    }
}
