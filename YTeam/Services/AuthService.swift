//
//  AuthService.swift
//  YTeam
//
//  Created by Yap Justin on 13/10/23.
//

import Firebase
import FirebaseFirestoreSwift

class AuthService {
    let db = Firestore.firestore()
    static let shared = AuthService()
    @Published var user: User?
    @Published var userData: UserData?
    @Published var invites: [Invite] = []
    var invitesListener: ListenerRegistration?
    
    func listenToAuthState() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else {
                return
            }
            self.user = user
        }
    }
    
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                print("success")
            }
        }
    }
    
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                print("success")
                
                self.db
                    .collection("users")
                    .document(AuthService.shared.user!.uid)
                    .setData([
                        "email": AuthService.shared.user!.email!,
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
            AuthService.shared.userData = nil
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func getUserData() {
        db.collection("users").document(AuthService.shared.user!.uid).getDocument { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                print(querySnapshot!.data() ?? "nil")
                AuthService.shared.userData = try? querySnapshot!.data(as: UserData.self)
                
                if AuthService.shared.userData != nil {
                    self.invitesListener = self.db.collection("invites").whereField(AuthService.shared.userData!.role == "senior" ? "seniorEmail" : "caregiverEmail", isEqualTo: AuthService.shared.user!.email!)
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
        db.collection("users").document(AuthService.shared.user!.uid).updateData([
            "role": role
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                AuthService.shared.userData?.role = role
            }
        }
    }
    
    func sendRequestToSenior(email: String) {
        var ref: DocumentReference? = nil
        ref = db.collection("invites").addDocument(data: [
            "seniorEmail": email,
            "caregiverEmail": AuthService.shared.user!.email!,
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
