//
//  LoginRegisterView.swift
//  YTeam
//
//  Created by Yap Justin on 10/10/23.
//

import SwiftUI
import CloudKit
import AuthenticationServices

// Start a new Login View
struct LoginRegisterView: View {
    
    // Give a login state, by default, it is false => not logined.
    @AppStorage("login") private var login = false
    
    @AppStorage("email") private var email = ""
    @AppStorage("firstName") private var firstName = ""
    @AppStorage("lastName") private var lastName = ""
    @AppStorage("userID") private var userID = ""
    
    var body: some View {
        NavigationView{
            VStack {
                if (!login && (userID == "")) {
                    Spacer()
                    
                    HStack{
                        Spacer()
                    }.ignoresSafeArea(.all)
                    
                    Spacer()
                    
                    signInWithApple
                    
                }
                else{
                    
                    
                }
                
                if userID != "" {
                    userInfo
                }
            }
            .padding()
            .toolbar {
                if (login && (userID != "")) {
                    Button(action: {
                        login = false
                        userID = ""
                        email = ""
                        firstName = ""
                        lastName = ""
                    }) {
                        Text("Sign out").foregroundColor(.white)
                    }
                }
            }
            .navigationTitle("CloudSign")
            .preferredColorScheme(.dark)
        }
    }
    
    var signInWithApple: some View {
        SignInWithAppleButton(
            // Request User FullName and Email
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]   // You can change them if needed.
            },
            // Once user complete login, get result
            onCompletion: { result in
                // Switch result
                switch result {
                    // Auth Success
                    case .success(let authResults):
                    print("auth success")
                    switch authResults.credential {
                        case let appleIDCredential as ASAuthorizationAppleIDCredential:
                            let uID = appleIDCredential.user
                        
                            if let emailAddress = appleIDCredential.email,
                            let givenName = appleIDCredential.fullName?.givenName,
                            let familyName = appleIDCredential.fullName?.familyName {
                                
                                // For New user to signup, and save the 3 records to CloudKit
                                let record = CKRecord(recordType: "UsersData", recordID: CKRecord.ID(recordName: uID))
                                record["email"] = emailAddress
                                record["firstName"] = givenName
                                record["lastName"] = familyName
                                CKContainer.default().publicCloudDatabase.save(record) { (_, _) in
                                    userID = record.recordID.recordName
                                }
                                
                                // Save to local
                                email = emailAddress
                                firstName = givenName
                                lastName = familyName
                                
                                // Change login state
                                self.login = true
                                
                            } else {
                                // For returning user to signin, fetch the saved records from Cloudkit
                                CKContainer.default().publicCloudDatabase.fetch(withRecordID: CKRecord.ID(recordName: uID)) { (record, error) in
                                    if let fetchedInfo = record {
                                        // Save to local
                                        userID = uID
                                        email = fetchedInfo["email"] as! String
                                        firstName = fetchedInfo["firstName"] as! String
                                        lastName = fetchedInfo["lastName"] as! String
                                        
                                        // Change login state
                                        self.login = true
                                    }
                                }
                            }
                        
                        // default break (don't remove)
                        default:
                            break
                        }
                    case .failure(let error):
                        print("failure", error)
                }
            }
        )
        .signInWithAppleButtonStyle(.white) // Button Style
        .frame(width:350,height:50)         // Set Button Size (Read iOS 14 beta 7 release note)
    }
    
    var userInfo: some View {
        VStack(alignment: .leading) {
            Label(NSLocalizedString("Welcome back", comment: "") + "! " + firstName + " " + lastName, systemImage: "lock.rotation.open")
                .font(.footnote)
            
            HStack {
                Label(NSLocalizedString("Your Email", comment: "") + ": ", systemImage: "envelope.circle")
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(email)
                }
            }.font(.footnote)
            
            HStack {
                Label(NSLocalizedString("User ID", comment: "") + ": ", systemImage: "person.crop.circle")
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(userID)
                }
            }.font(.footnote)
        }
        .padding()
        .background(Color("WB").opacity(0.5))
        .cornerRadius(25)
    }
}

#Preview {
    LoginRegisterView()
}
