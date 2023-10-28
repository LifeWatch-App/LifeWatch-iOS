//
//  AuthService.swift
//  YTeam
//
//  Created by Yap Justin on 13/10/23.
//
import Firebase
import FirebaseAuth
import Foundation
import AuthenticationServices
import CryptoKit

class AuthService: NSObject, ObservableObject, ASAuthorizationControllerDelegate  {
    let db = Firestore.firestore()
    static let shared = AuthService()
    @Published var user: User?
    @Published var userData: UserData?
    @Published var invites: [Invite] = []
    @Published var isLoading = false
    @Published var loginProviders: [String] = []
    @Published var isDeleteAppleAccount = false
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
                print("Login Success")
            }
            
            self.loginProviders = []
            if let providerData = Auth.auth().currentUser?.providerData {
                for item in providerData {
                    self.loginProviders.append(item.providerID)
                }
            }
        }
    }
    
    func signUp(email: String, password: String) {
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
                            self!.isLoading = false
                        }
                        else {
                            print("Document added")
                            self!.isLoading = false
                        }
                        
                        self?.loginProviders = []
                        if let providerData = Auth.auth().currentUser?.providerData {
                            for item in providerData {
                                self?.loginProviders.append(item.providerID)
                            }
                        }
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
            
            self.userData = nil
            //            self.invites = []
            self.user = nil
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
                            print("bba")
                            
                            if documents.count == 0 {
                                self.isLoading = false
                            }
                            
                            print("invo: ", documents)
                            
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
                    
                    self.loginProviders = []
                    if let providerData = Auth.auth().currentUser?.providerData {
                        for item in providerData {
                            self.loginProviders.append(item.providerID)
                        }
                    }
                } else {
                    guard let fcmToken = UserDefaults.standard.value(forKey: "fcmToken") else{
                        return
                    }
                    print("cccb")
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
                                self!.userData = UserData(id: AuthService.shared.user!.uid, email: AuthService.shared.user!.email!, role: nil, fcmToken: fcmToken as! String)
                                self!.isLoading = false
                            }
                            
                            self?.loginProviders = []
                            if let providerData = Auth.auth().currentUser?.providerData {
                                for item in providerData {
                                    self?.loginProviders.append(item.providerID)
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
    
    func deleteAccountWithPassword(password: String) {
        let credential = EmailAuthProvider.credential(withEmail: user!.email!, password: password)
        Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (result, error) in
            if let err = error {
                print("Error reauthenticating: \(err)")
            } else {
                self.deleteUserData()
            }
         })
    }
    
    func deleteAccountWithApple() {
        isDeleteAppleAccount = true
        startSignInWithAppleFlow()
    }
    
    func deleteUserData() {
        self.isLoading = true
        if userData?.role == "senior" {
            self.db.collection("users").document(AuthService.shared.user!.uid).delete() { err in
                if let err = err {
                    print("Error removing user data: \(err)")
                }
                else {
                    print("User data successfully removed!")
                }
                
                self.db.collection("invites").whereField("caregiverId", isEqualTo: AuthService.shared.user!.uid).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting invites documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            document.reference.delete()
                        }
                        
                        print("Invites data successfully removed!")
                    }
                    
                    self.db.collection("falls").whereField("seniorId", isEqualTo: AuthService.shared.user!.uid).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting falls documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                document.reference.delete()
                            }
                            
                            print("Falls data successfully removed!")
                        }
                        
                        self.db.collection("charges").whereField("seniorId", isEqualTo: AuthService.shared.user!.uid).getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print("Error getting charges documents: \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    document.reference.delete()
                                }
                                
                                print("Charges data successfully removed!")
                            }
                            
                            self.db.collection("idles").whereField("seniorId", isEqualTo: AuthService.shared.user!.uid).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print("Error getting idles documents: \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        document.reference.delete()
                                    }
                                    
                                    print("Idles data successfully removed!")
                                }
                                
                                self.db.collection("batteryLevels").whereField("seniorId", isEqualTo: AuthService.shared.user!.uid).getDocuments() { (querySnapshot, err) in
                                    if let err = err {
                                        print("Error getting battery levels documents: \(err)")
                                    } else {
                                        for document in querySnapshot!.documents {
                                            document.reference.delete()
                                        }
                                        
                                        print("Battery levels data successfully removed!")
                                    }
                                    
                                    self.db.collection("sos").whereField("seniorId", isEqualTo: AuthService.shared.user!.uid).getDocuments() { (querySnapshot, err) in
                                        if let err = err {
                                            print("Error getting sos documents: \(err)")
                                        } else {
                                            for document in querySnapshot!.documents {
                                                document.reference.delete()
                                            }
                                            
                                            print("Sos data successfully removed!")
                                        }
                                        
                                        Auth.auth().currentUser?.delete { err in
                                            if let err = err {
                                                print("Error deleting user account: \(err)")
                                            } else {
                                                print("User account deletion successful")
                                            }
                                            
                                            self.isLoading = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            self.db.collection("users").document(AuthService.shared.user!.uid).delete() { err in
                if let err = err {
                    print("Error removing user data: \(err)")
                }
                else {
                    print("User data successfully removed!")
                }
                
                self.db.collection("invites").whereField("caregiverId", isEqualTo: AuthService.shared.user!.uid).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting invites documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            document.reference.delete()
                        }
                        
                        print("Invites data successfully removed!")
                    }
                    
                    Auth.auth().currentUser?.delete { err in
                        if let err = err {
                            print("Error deleting user account: \(err)")
                        } else {
                            print("User account deletion successful")
                        }
                        
                        self.isLoading = false
                    }
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
    
    var currentNonce: String?
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // Single-sign-on with Apple
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if (error != nil) {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error?.localizedDescription)
                    return
                }
                
                if self.isDeleteAppleAccount {
                    self.deleteUserData()
                    self.isDeleteAppleAccount = false
                }
                
                self.db.collection("users").document(AuthService.shared.user!.uid).getDocument { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        AuthService.shared.userData = try? querySnapshot!.data(as: UserData.self)
                    }
                }
                
                print("Apple sign in!")
                
                self.loginProviders = []
                if let providerData = Auth.auth().currentUser?.providerData {
                    for item in providerData {
                        self.loginProviders.append(item.providerID)
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
}
