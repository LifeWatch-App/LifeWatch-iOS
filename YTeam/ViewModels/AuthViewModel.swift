//
//  AuthRepository.swift
//  YTeam
//
//  Created by Yap Justin on 12/10/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class AuthViewModel: ObservableObject {
    let db = Firestore.firestore()
    var invitesListener: ListenerRegistration?
    var user: User? {
        didSet {
            objectWillChange.send()
        }
    }
    @Published var userData: UserData?
    @Published var invites: [Invite] = []
    
    func listenToAuthState() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else {
                return
            }
            self.user = user
        }
    }
    
    func login(email: String,
               password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                print("success")
            }
        }
    }
    
    func signUp(
        email: String,
        password: String
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                print("success")
                
                self.db
                    .collection("users")
                    .document(self.user!.uid)
                    .setData([
                        "email": self.user!.email!,
                        "role": NSNull()
                    ]) { [weak self] err in
                        guard self != nil else { return }
                        if let err = err {
                            print("Error adding document: \(err)")
                        }
                        else {
                            print("Document added")
                        }
                    }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            invitesListener?.remove()
            userData = nil
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func getUserData() {
        db.collection("users").document(user!.uid).getDocument { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                print(querySnapshot!.data() ?? "nil")
                self.userData = try? querySnapshot!.data(as: UserData.self)
                
                if self.userData != nil {
                    self.invitesListener = self.db.collection("invites").whereField(self.userData!.role == "senior" ? "seniorEmail" : "caregiverEmail", isEqualTo: self.user!.email!)
                        .addSnapshotListener { querySnapshot, error in
                            guard let documents = querySnapshot?.documents else {
                                print("No documents in invites")
                                return
                            }
                            self.invites = documents.compactMap { queryDocumentSnapshot in
                                let result = Result { try queryDocumentSnapshot.data(as: Invite.self) }
                                
                                switch result {
                                case .success(let invite):
                                    return invite
                                case .failure(let error):
                                    print("Error decoding document: \(error.localizedDescription)")
                                    return nil
                                }
                            }
                            
                            print(self.invites)
                        }
                }
            }
        }
    }
    
    func setRole(role: String) {
        db.collection("users").document(user!.uid).updateData([
            "role": role
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                self.userData?.role = role
            }
        }
    }
    
    func sendRequestToSenior(email: String) {
        var ref: DocumentReference? = nil
        ref = db.collection("invites").addDocument(data: [
            "seniorEmail": email,
            "caregiverEmail": user!.email!,
            "accepted": false
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Invite added with ID: \(ref!.documentID)")
            }
        }
    }
}
