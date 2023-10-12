//
//  FallHistoryViewModel.swift
//  YTeam
//
//  Created by Yap Justin on 12/10/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class ExampleViewModel: ObservableObject {
    let db = Firestore.firestore()
    var invitesListener: ListenerRegistration?
    var user: User? {
        didSet {
            objectWillChange.send()
        }
    }
    
    func addFallHistory() {
        var ref: DocumentReference? = nil
        ref = db.collection("fallHistory").addDocument(data: [
            "time": 1,
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Invite added with ID: \(ref!.documentID)")
            }
        }
    }
}
