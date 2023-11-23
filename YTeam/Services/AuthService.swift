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
import SwiftUI

class AuthService: NSObject, ObservableObject, ASAuthorizationControllerDelegate  {
    let db = Firestore.firestore()
    static let shared = AuthService()
    @Published var user: User?
    @Published var userData: UserData?
    @Published var invites: [Invite] = []
    @Published var isLoading = true
    @Published var loginProviders: [String] = []
    @Published var selectedInviteId: String?
    @Published var isDeleteAppleAccount = false
    @Published var loginMessage = ""
    @Published var signUpMessage = ""
    var invitesListener: ListenerRegistration?
    
    
    func listenToAuthState() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else {
                return
            }
            withAnimation {
                self.user = user
            }
            if user == nil {
                withAnimation {
                    self.isLoading = false
                }
            }
        }
    }
    
    func login(email: String, password: String) {
        withAnimation {
            isLoading = true
        }
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                print("login error", error?.localizedDescription ?? "")
                withAnimation {
                    self.isLoading = false
                }
                self.loginMessage = error?.localizedDescription ?? ""
            } else {
                self.loginMessage = ""
                print("Login Success")
                let udid: String = UIDevice().identifierForVendor!.uuidString
                
                self.db.collection("users").document(AuthService.shared.user!.uid).updateData([
                    "udid": UIDevice().identifierForVendor?.uuidString
                ]) { err in
                    if let err = err {
                        print("Error updating udid: \(err)")
                    } else {
                        print("UDID successfully updated to: ", udid)
                    }
                }
            }
            
            self.loginProviders = []
            if let providerData = Auth.auth().currentUser?.providerData {
                for item in providerData {
                    self.loginProviders.append(item.providerID)
                }
            }
        }
    }
    
    func signUp(name: String, email: String, password: String) {
        //TODO: When launch app check if user data exists in UserDefault or not, if yes get that user, if not save it in user default the one that is passed from watchconnectivity
        withAnimation {
            isLoading = true
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                print("sign up error", error?.localizedDescription ?? "")
                withAnimation {
                    self.isLoading = false
                }
                self.signUpMessage = error?.localizedDescription ?? ""
            } else {
                print("success")
                self.signUpMessage = ""
                
                // Get the FCM token form user defaults
                guard let fcmToken = UserDefaults.standard.value(forKey: "fcmToken") else{
                    return
                }
                
                self.db
                    .collection("users")
                    .document(AuthService.shared.user!.uid)
                    .setData([
                        "name": name,
                        "email": AuthService.shared.user!.email!,
                        "role": NSNull(),
                        "fcmToken": fcmToken
                    ]) { [weak self] err in
                        guard self != nil else { return }
                        if let err = err {
                            print("Error adding document: \(err)")
                            withAnimation {
                                self!.isLoading = false
                            }
                        }
                        else {
                            print("Document added")
                            withAnimation {
                                self!.isLoading = false
                            }
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
        withAnimation {
            self.isLoading = true
        }
        
        self.db.collection("users").document(AuthService.shared.user!.uid).updateData([
            "fcmToken": NSNull(),
            "pttToken": NSNull(),
            "udid": NSNull()
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Tokens successfully cleared")
            }

            self.removeListeners()
            
            do {
                try Auth.auth().signOut()
                
                withAnimation {
                    self.isLoading = false
                }
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        }
    }
    
    func getUserData() {
        withAnimation {
            isLoading = true
        }
        
        db.collection("users").document(AuthService.shared.user!.uid).getDocument { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                withAnimation {
                    self.isLoading = false
                }
            } else {
                AuthService.shared.userData = try? querySnapshot!.data(as: UserData.self)
                
                let udid: String = UIDevice().identifierForVendor!.uuidString
                
                if AuthService.shared.userData != nil {
                    if AuthService.shared.userData!.udid ?? "" != udid {
                        self.signOut()
                    }
                    
                    let fcmToken = UserDefaults.standard.value(forKey: "fcmToken")
                    if fcmToken != nil {
                        if (fcmToken as! String != AuthService.shared.userData?.fcmToken ?? "") {
                            self.updateFCMToken(fcmToken: fcmToken! as! String)
                        }
                    }
                    let pttToken = UserDefaults.standard.value(forKey: "pttToken")
                    if (pttToken != nil) {
                        if (pttToken as! String != AuthService.shared.userData?.pttToken ?? "") {
                            self.updatePTTToken(pttToken: pttToken! as! String)
                        }
                    }
                    
                    self.loginProviders = []
                    if let providerData = Auth.auth().currentUser?.providerData {
                        for item in providerData {
                            self.loginProviders.append(item.providerID)
                        }
                    }
                    
                    withAnimation {
                        self.isLoading = false
                    }
                } else {
                    guard let fcmToken = UserDefaults.standard.value(forKey: "fcmToken") else{
                        return
                    }
                    guard let pttToken = UserDefaults.standard.value(forKey: "pttToken") else{
                        return
                    }
                    let udid: String = UIDevice().identifierForVendor!.uuidString
                    
                    self.db
                        .collection("users")
                        .document(AuthService.shared.user!.uid)
                        .setData([
                            "name": "Unknown",
                            "email": AuthService.shared.user!.email!,
                            "role": NSNull(),
                            "fcmToken": fcmToken,
                            "pttToken": pttToken,
                            "udid": udid
                        ]) { [weak self] err in
                            guard self != nil else { return }
                            if let err = err {
                                print("Error adding document: \(err)")
                                withAnimation {
                                    self!.isLoading = false
                                }
                            }
                            else {
                                print("Document added")
                                self!.userData = UserData(id: AuthService.shared.user!.uid, email: AuthService.shared.user!.email!, role: nil, fcmToken: fcmToken as! String, pttToken: pttToken as! String, udid: udid)
                                withAnimation {
                                    self!.isLoading = false
                                }
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
    
    func updatePTTToken(pttToken: String) {
        print("gggg")
        print(AuthService.shared.user!.uid)
        print(pttToken)
        self.db.collection("users").document(AuthService.shared.user!.uid).updateData([
            "pttToken": pttToken
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("PTT token successfully updated to: ", pttToken)
            }
        }
    }
    
    func updateFCMToken(fcmToken: String) {
        print("dddd")
        print(AuthService.shared.user!.uid)
        print(fcmToken)
        self.db.collection("users").document(AuthService.shared.user!.uid).updateData([
            "fcmToken": fcmToken
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("FCM token successfully updated to: ", fcmToken)
            }
        }
    }
    
    func addInvitesListener() {
        print("added listeners")
        self.invitesListener = self.db.collection("invites").whereField(AuthService.shared.userData!.role == "senior" ? "seniorId" : "caregiverId", isEqualTo: AuthService.shared.user!.uid)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No documents in invites")
                    return
                }
                
                if documents.count == 0 {
                    withAnimation {
                        self.isLoading = false
                    }
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
                                    
                                    if !self.invites.isEmpty {
                                        if let selectedSeniorId = UserDefaults.standard.string(forKey: "selectedSenior") {
                                            if self.selectedInviteId != selectedSeniorId {
                                                self.selectedInviteId = selectedSeniorId
                                            }
                                            
                                        } else {
                                            print("Called invites from empty")
                                            self.selectedInviteId = self.invites.first?.seniorId
                                            UserDefaults.standard.set(self.invites.first?.seniorId, forKey: "selectedSenior")
                                        }
                                    } else {
                                        self.selectedInviteId = nil
                                    }
                                }
                                
                                if (index == documents.count - 1) {
                                    withAnimation {
                                        self.isLoading = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
    }
    
    func setRole(role: String) {
        withAnimation {
            self.isLoading = true
        }
        db.collection("users").document(AuthService.shared.user!.uid).updateData([
            "role": role
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                AuthService.shared.userData?.role = role
            }
            
            withAnimation {
                self.isLoading = false
            }
        }
    }
    
    func setName(name: String) {
        withAnimation {
            self.isLoading = true
        }
        db.collection("users").document(AuthService.shared.user!.uid).updateData([
            "name": name
        ]) { err in
            if let err = err {
                print("Error updating name: \(err)")
            } else {
                print("Name successfully updated")
                AuthService.shared.userData?.name = name
            }
            
            withAnimation {
                self.isLoading = false
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
        withAnimation {
            self.isLoading = true
        }
        if userData?.role == "senior" {
            self.db.collection("users").document(AuthService.shared.user!.uid).delete() { err in
                if let err = err {
                    print("Error removing user data: \(err)")
                }
                else {
                    print("User data successfully removed!")
                }
                
                self.db.collection("invites").whereField("seniorId", isEqualTo: AuthService.shared.user!.uid).getDocuments() { (querySnapshot, err) in
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
                                        
                                        self.removeListeners()
                                        
                                        Auth.auth().currentUser?.delete { err in
                                            if let err = err {
                                                print("Error deleting user account: \(err)")
                                            } else {
                                                print("User account deletion successful")
                                                
                                            }
                                            
                                            withAnimation {
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
                    
                    self.removeListeners()
                    
                    Auth.auth().currentUser?.delete { err in
                        if let err = err {
                            print("Error deleting user account: \(err)")
                        } else {
                            print("User account deletion successful")
                            UserDefaults.standard.removeObject(forKey: "selectedSenior")
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
    
    func denyInvite(id: String) {
        db.collection("invites").document(id).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed")
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
                
                let udid: String = UIDevice().identifierForVendor!.uuidString
                
                self.db.collection("users").document(AuthService.shared.user!.uid).updateData([
                    "udid": UIDevice().identifierForVendor?.uuidString
                ]) { err in
                    if let err = err {
                        print("Error updating udid: \(err)")
                    } else {
                        print("UDID successfully updated to: ", udid)
                    }
                }
                
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
    
    func removeListeners() {
        if self.invitesListener != nil {
            self.invitesListener!.remove()
        }

        self.invites = []
        self.selectedInviteId = nil
        self.userData = nil
        self.user = nil
        
        UserDefaults.standard.removeObject(forKey: "selectedSenior")
        FallService.shared.deinitializerFunction()
        SOSService.shared.deinitializerFunction()
        InactivityService.shared.deinitializerFunction()
        HeartAnomalyService.shared.deinitializerFunction()
        HeartbeatService.shared.deinitializerFunction()
        LocationService.shared.deinitializerFunction()
        BatteryChargingService.shared.deinitializerFunction()
        DashboardLocationService.shared.deinitializerFunction()
        HeartRateService.shared.deinitializerFunction()
        IdleService.shared.deinitializerFunction()
        RoutineService.shared.deinitializerFunction()
        SymptomService.shared.deinitializerFunction()
    }
}
