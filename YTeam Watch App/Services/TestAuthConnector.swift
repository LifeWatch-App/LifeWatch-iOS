//
//  WatchConnectorManager.swift
//  CobaApp Watch App
//
//  Created by Kevin Sander Utomo on 10/10/23.
//

import Foundation
import WatchConnectivity

final class TestAuthConnector: NSObject, WCSessionDelegate {
    var session: WCSession
    @Published var userRecord: UserRecord?
    private let decoder = JSONDecoder()

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let userRecordDataEncapsulator = message["user_auth"], let data = userRecordDataEncapsulator as? Data {
            do {
                let userRecordData = try JSONDecoder().decode(UserRecord.self, from: data)
                print(userRecordData)

                if let userRecord = UserDefaults.standard.data(forKey: "user-auth") {
                    let decodedUserRecord = try? self.decoder.decode(UserRecord.self, from: userRecord)
                    guard decodedUserRecord?.userID != nil, userRecordData.userID != nil else {
                        self.userRecord = nil
                        UserDefaults.standard.removeObject(forKey: "user-auth")
                        return
                    }

                    if decodedUserRecord?.userID == userRecordData.userID {
                        self.userRecord = decodedUserRecord
                    } else {
                        UserDefaults.standard.set(userRecordDataEncapsulator as! Data, forKey: "user-auth")
                        self.userRecord = userRecordData
                    }

                } else {
                    UserDefaults.standard.set(userRecordDataEncapsulator as! Data, forKey: "user-auth")
                    self.userRecord = userRecordData
                }

            } catch {
                print("Error of the decoding is: \(error)")
            }
        }
    }
}
