//
//  SymptomService.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 14/11/23.
//

import Foundation
import Firebase

final class SymptomService {
    static let shared = SymptomService()
    @Published var symptomsDocumentChanges = [DocumentChange]()
    @Published var symptomsLatestDocumentChanges = [DocumentChange]()

    func observeSyptoms() {
        guard let uid = UserDefaults.standard.string(forKey: "selectedSenior") else { return }
        //        guard let uid = Auth.auth().currentUser?.uid else { return }

        let query = FirestoreConstants.symptomsCollection
            .whereField("seniorId", isEqualTo: uid)
            .order(by: "time", descending: true)

        query.addSnapshotListener { querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            self.symptomsDocumentChanges = changes
        }
    }

    func observeLatestSyptoms() {
        guard let uid = UserDefaults.standard.string(forKey: "selectedSenior") else { return }
        //        guard let uid = Auth.auth().currentUser?.uid else { return }
        let currentDate = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: currentDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        print("StartOfDay", startOfDay.timeIntervalSince1970)
        print("EndOfDay", endOfDay.timeIntervalSince1970)

        let query = FirestoreConstants.symptomsCollection
            .whereField("seniorId", isEqualTo: uid)
            .whereField("time", isGreaterThanOrEqualTo: startOfDay.timeIntervalSince1970)
            .whereField("time", isLessThanOrEqualTo: endOfDay.timeIntervalSince1970)
            .order(by: "time", descending: true)
            .limit(to: 1)

        query.addSnapshotListener { querySnapshot, error in
            guard let changes = querySnapshot?.documentChanges.filter({ $0.type == .modified || $0.type == .added }) else { return }
            self.symptomsLatestDocumentChanges = changes
        }
    }
}
