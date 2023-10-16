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
        //TODO: Send user record to watch using WatchConnectivity
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                print("success")
            }
        }
    }
    
    func signUp(email: String, password: String) {
        //TODO: Send user record to watch using WatchConnectivity
        //TODO: When launch app check if user data exists in UserDefault or not, if yes get that user, if not save it in user default the one that is passed from watchconnectivity
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                print("success")
                
                // Get the FCM token form user defaults
                guard let fcmToken = UserDefaults.standard.value(forKey: "fcmToken") else{
                    return
                }
                
                self.db
                    .collection("users")
                    .document(AuthService.shared.user!.uid)
                    .setData([
                        "email": AuthService.shared.user!.email!,
                        "role": NSNull(),
                        "fcmToken": fcmToken
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
            AuthService.shared.invites = []
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
                    self.invitesListener = self.db.collection("invites").whereField(AuthService.shared.userData!.role == "senior" ? "seniorId" : "caregiverId", isEqualTo: AuthService.shared.user!.uid)
                        .addSnapshotListener { querySnapshot, error in
                            guard let documents = querySnapshot?.documents else {
                                print("No documents in invites")
                                return
                            }
                            
                            self.invites = []
                            
                            for document in documents {
                                var invite = try? document.data(as: Invite.self)
                                
                                self.db.collection("users").document(invite!.seniorId!).getDocument { (querySnapshot, err) in
                                    if let err = err {
                                        print("Error getting documents: \(err)")
                                    } else {
                                        invite?.seniorData = try? querySnapshot?.data(as: UserData.self)
                                        
                                        self.db.collection("users").document(invite!.caregiverId!).getDocument { (querySnapshot, err) in
                                            if let err = err {
                                                print("Error getting documents: \(err)")
                                            } else {
                                                invite?.caregiverData = try? querySnapshot?.data(as: UserData.self)
                                                self.invites.append(invite!)
                                                print("aaa")
                                            }
                                        }
                                    }
                                }
                            }
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
        db.collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let userData = try? document.data(as: UserData.self)
                        
                        self.db.collection("invites")
                            .whereField("seniorId", isEqualTo: userData!.id!)
                            .whereField("caregiverId", isEqualTo: AuthService.shared.user!.uid)
                            .getDocuments(completion: { snapshot, error in
                                if let err = error {
                                    print("Error getting document: \(err)")
                                    return
                                }
                                
                                guard let docs = snapshot?.documents else { return }
                                
                                if docs.isEmpty {
                                    var ref: DocumentReference? = nil
                                    ref = self.db.collection("invites").addDocument(data: [
                                        "seniorId": userData!.id!,
                                        "caregiverId": AuthService.shared.user!.uid,
                                        "accepted": false
                                    ]) { err in
                                        if let err = err {
                                            print("Error adding document: \(err)")
                                        } else {
                                            print("Invite added with ID: \(ref!.documentID)")
                                        }
                                    }
                                }
                            })
                    }
                }
            }
    }
    
    func acceptInvite(id: String) {
        db.collection("invites").document(id).updateData([
            "accepted": true
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
}
