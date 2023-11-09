//
//  RoutineService.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 09/11/23.
//

import Foundation
import Firebase

class RoutineService {
    static let shared: RoutineService = RoutineService()
    
    @Published var routines: [RoutineData] = []
    
    init() {
        Task{try? await observeAllRoutines()}
    }
    
    /// Observes all falls by adding a snapshot listener to the firebase and updates the `heartAnomalies` properties only if user is `logged in`.
    ///
    /// ```
    /// HeartAnomalyService.observeAllAnomalies().
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: If user is logged in, add a snapshot listener to the database and filter it based on the UID.
    @MainActor
    func observeAllRoutines() async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let query = FirestoreConstants.routinesCollection
                                    .whereField("seniorId", isEqualTo: userId)
        
        query.addSnapshotListener { [weak self] snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            let routines = changes.compactMap({ try? $0.document.data(as: RoutineData.self) })
            self?.routines = routines
        }
    }
    
    @MainActor
    func sendRoutine(routine: RoutineData) async throws {
        let routinesCollection = FirestoreConstants.routinesCollection
        
        guard let encodedRoutineData = try? Firestore.Encoder().encode(routine) else { return }
        
        try? await routinesCollection.document().setData(encodedRoutineData)
    }
}
