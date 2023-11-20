//
//  SymptomService.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 14/11/23.
//

import Foundation
import Firebase
import Combine

final class SymptomService {
    static let shared = SymptomService()
    @Published var symptomsDocumentChanges = [DocumentChange]()
    @Published var symptomsDocumentChangesToday = [DocumentChange]()
    private var symptomsListener: [ListenerRegistration] = []
    @Published var symptomsLatestDocumentChanges = [DocumentChange]()
    @Published var userData: UserData?
    private let authService = AuthService.shared
    
    func deinitializerFunction() {
        symptomsListener.forEach({ $0.remove() })
        symptomsListener = []
        symptomsDocumentChanges = []
        symptomsDocumentChangesToday = []
        symptomsLatestDocumentChanges = []
    }

    func observeSymptoms(userData: UserData?) {
        let uid: String?
        if userData?.role == "caregiver" {
            uid = UserDefaults.standard.string(forKey: "selectedSenior")
        } else {
            uid = Auth.auth().currentUser?.uid
        }

        guard let uid else { return }

        let query = FirestoreConstants.symptomsCollection
            .whereField("seniorId", isEqualTo: uid)
            .order(by: "time", descending: true)
        
        symptomsListener.append(query.addSnapshotListener { [weak self] querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            self?.symptomsDocumentChanges = changes
        })
    }
    
    func observeSymptomsToday() {
        print("Called function here")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let currentDate = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: currentDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let query = FirestoreConstants.symptomsCollection
            .whereField("seniorId", isEqualTo: uid)
            .whereField("time", isGreaterThanOrEqualTo: startOfDay.timeIntervalSince1970)
            .whereField("time", isLessThanOrEqualTo: endOfDay.timeIntervalSince1970)
            .order(by: "time", descending: true)
        
        symptomsListener.append(query.addSnapshotListener { [weak self] querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            self?.symptomsDocumentChangesToday = changes
            print("DocumentData", self?.symptomsDocumentChangesToday.count)
        })
    }
    
    func observeLatestSyptoms(userData: UserData?) {
        let uid: String?
        if userData?.role == "caregiver" {
            uid = UserDefaults.standard.string(forKey: "selectedSenior")
        } else {
            uid = Auth.auth().currentUser?.uid
        }

        guard let uid else { return }
        let currentDate = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: currentDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let query = FirestoreConstants.symptomsCollection
            .whereField("seniorId", isEqualTo: uid)
            .whereField("time", isGreaterThanOrEqualTo: startOfDay.timeIntervalSince1970)
            .whereField("time", isLessThanOrEqualTo: endOfDay.timeIntervalSince1970)
            .order(by: "time", descending: true)
            .limit(to: 1)
        
        symptomsListener.append(query.addSnapshotListener { [weak self] querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            self?.symptomsLatestDocumentChanges = changes
        })
    }
}
