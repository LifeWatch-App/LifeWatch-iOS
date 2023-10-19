//
//  AuthService.swift
//  YTeam
//
//  Created by Yap Justin on 13/10/23.
//
import Firebase
import FirebaseAuth

class AuthService {
    let db = Firestore.firestore()
    static let shared = AuthService()
    @Published var user: User?
    @Published var userData: UserData?
    @Published var invites: [Invite] = []
    @Published var isLoading = false
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
                print("Login Success")
            }
        }
    }
    
    func signUp(email: String, password: String) {
        //TODO: Send user record to watch using WatchConnectivity
        //TODO: When launch app check if user data exists in UserDefault or not, if yes get that user, if not save it in user default the one that is passed from watchconnectivity
        isLoading = true
        
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
                        
                        self!.isLoading = false
                    }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            
            // Remove FCM token from firebase
            self.db.collection("users").document(AuthService.shared.user!.uid).updateData([
                "fcmToken": NSNull()
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("FCM token successfully updated")
                }
            }
            
            AuthService.shared.userData = nil
            AuthService.shared.invites = []
            AuthService.shared.user = nil
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func getUserData() {
        isLoading = true
        
        db.collection("users").document(AuthService.shared.user!.uid).getDocument { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                AuthService.shared.userData = try? querySnapshot!.data(as: UserData.self)
                
                if AuthService.shared.userData != nil {
                    // Check and update FCM token if needed
                    // Get the FCM token form user defaults
                    guard let fcmToken = UserDefaults.standard.value(forKey: "fcmToken") else{
                        return
                    }
                    if (fcmToken as! String != AuthService.shared.userData?.fcmToken ?? "") {
                        self.db.collection("users").document(AuthService.shared.user!.uid).updateData([
                            "fcmToken": fcmToken
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("FCM token successfully updated")
                            }
                        }
                    }
                    
                    // Set invites listener
                    self.invitesListener = self.db.collection("invites").whereField(AuthService.shared.userData!.role == "senior" ? "seniorId" : "caregiverId", isEqualTo: AuthService.shared.user!.uid)
                        .addSnapshotListener { querySnapshot, error in
                            guard let documents = querySnapshot?.documents else {
                                print("No documents in invites")
                                return
                            }
                            
                            if documents.count == 0 {
                                self.isLoading = false
                            }
                            
                            self.invites = []
                            
                            for (index, document) in documents.enumerated() {
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
                                            }
                                            
                                            if (index == documents.count - 1) {
                                                self.isLoading = false
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
        let email = email.lowercased()
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
