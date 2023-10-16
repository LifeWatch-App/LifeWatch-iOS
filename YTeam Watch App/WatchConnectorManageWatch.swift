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

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }


    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //
    }
}

