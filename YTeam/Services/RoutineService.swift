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
    @Published var deletedRoutine: [RoutineData] = []
//    init() {
//        Task{try? await observeAllRoutines()}
//    }
    
    /// Observes all falls by adding a snapshot listener to the firebase and updates the `heartAnomalies` properties only if user is `logged in`.
    ///
    /// ```
    /// HeartAnomalyService.observeAllAnomalies().
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: If user is logged in, add a snapshot listener to the database and filter it based on the UID.
    func observeAllRoutines(userData: UserData?) {
        print("UserData: ", userData)
        let uid: String?
        if userData?.role == "caregiver" {
            uid = UserDefaults.standard.string(forKey: "selectedSenior")
        } else {
            uid = Auth.auth().currentUser?.uid
        }

        let query = FirestoreConstants.routinesCollection
            .whereField("seniorId", isEqualTo: uid ?? "")
        
        query.addSnapshotListener { [weak self] snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added || $0.type == .modified }) else { return }
            let routines = changes.compactMap({ try? $0.document.data(as: RoutineData.self) })
            self?.routines = routines
        }
    }
    
    func observeAllDeletedRoutines(userData: UserData?) {
        let uid: String?
        if userData?.role == "caregiver" {
            uid = UserDefaults.standard.string(forKey: "selectedSenior")
        } else {
            uid = Auth.auth().currentUser?.uid
        }

        let query = FirestoreConstants.routinesCollection
            .whereField("seniorId", isEqualTo: uid ?? "")
        
        query.addSnapshotListener { [weak self] snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .removed }) else { return }
            let routines = changes.compactMap({ try? $0.document.data(as: RoutineData.self) })
            print("Routines", routines)
            self?.deletedRoutine = routines
        }
    }
    
    func removeDeletedRoutines() {
        self.deletedRoutine = []
    }
    
    @MainActor
    func sendRoutine(routine: RoutineData) async throws {
        let routinesCollection = FirestoreConstants.routinesCollection
        
        guard let encodedRoutineData = try? Firestore.Encoder().encode(routine) else { return }
        
        try? await routinesCollection.document().setData(encodedRoutineData)
    }
    
    @MainActor
    func updateRoutine(routine: RoutineData) async throws {
        guard let encodedData = try? Firestore.Encoder().encode(routine) else { return }
        let documents = try await FirestoreConstants.routinesCollection.whereField("id", isEqualTo: routine.id).getDocuments().documents.first
        
        try await documents?.reference.updateData(encodedData)
    }
    
    @MainActor
    func deleteRoutine(routine: RoutineData) async throws {
        guard (try? Firestore.Encoder().encode(routine)) != nil else { return }
        let documents = try await FirestoreConstants.routinesCollection.whereField("id", isEqualTo: routine.id).getDocuments().documents.first
        
        try await documents?.reference.delete()
    }
}
