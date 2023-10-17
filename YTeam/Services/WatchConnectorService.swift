//
//  WatchConnectorManager.swift
//  CobaApp Watch App
//
//  Created by Kevin Sander Utomo on 10/10/23.
//

import Foundation
import WatchConnectivity

final class WatchConnectorService: NSObject, WCSessionDelegate {
    var session: WCSession
    static let shared = WatchConnectorService()

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        //
    }

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
}

