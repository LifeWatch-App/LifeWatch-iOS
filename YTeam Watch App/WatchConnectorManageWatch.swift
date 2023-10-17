//
//  WatchConnectorManager.swift
//  CobaApp Watch App
//
//  Created by Kevin Sander Utomo on 10/10/23.
//

import Foundation
import WatchConnectivity

final class WatchConnectorManager: NSObject, WCSessionDelegate {
    var session: WCSession
    @Published var chargingRange: [ChargingRange] = []
    @Published var userRecord: UserRecord?

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
        //TODO: Check if user data exists in UserDefault or not, if yes get that user, if not save it in user default the one that is passed from watchconnectivity
        //TODO: When user signs out in iOS, we want to send data to the watch which has a state which is isLogin = false and the data passed is nil
        //TODO: Check if the data passed from watchconnectivity, has a state which is isLogin = false and the data passed is nil, then we want to delete the one in UserDefaults
//        DispatchQueue.main.async {
//            if let messagingHistoryEncapsulator = message["charging_history"] {
//                guard let messagingHistory = try? JSONDecoder().decode([ChargingRange].self, from: messagingHistoryEncapsulator as! Data) else {
//                    print("Failed to decode the data")
//                    return
//                }
//                self.chargingRange = messagingHistory
//            }
//        }
    }
}

