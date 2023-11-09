//
//  AddSymptomViewModel.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 06/11/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

final class AddSymptomViewModel: ObservableObject {
    @Published var notes = ""
    @Published var time = Date.now

    @Published var selectedSymptom: String?

    func createSymptomDataRecord() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let symptomRecord: Symptom = Symptom(name: selectedSymptom, seniorId: uid, note: notes, time: Date.now.timeIntervalSince1970)

        do {
            let encodedData = try Firestore.Encoder().encode(symptomRecord)
            try await FirestoreConstants.symptomsCollection.document().setData(encodedData)
            print("Successfully created battery level record!")
        } catch {
            print("Error decoding with: \(error)")
        }
    }
}
