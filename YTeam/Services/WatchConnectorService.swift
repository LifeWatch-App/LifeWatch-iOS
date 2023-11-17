//
//  WatchConnectorManager.swift
//  CobaApp Watch App
//
//  Created by Kevin Sander Utomo on 10/10/23.
//

import Foundation
import Firebase
import Combine
import WatchConnectivity

final class WatchConnectorService: NSObject, WCSessionDelegate {
    var session: WCSession
    static let shared = WatchConnectorService()
    private let service = AuthService.shared
    var cancellables = Set<AnyCancellable>()
    @Published var user: User?
    @Published var userData: UserData?

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        setupSubsribers()
        session.activate()
        print("watch detectedd")
    }

    func setupSubsribers() {
        service.$user
            .combineLatest(service.$userData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user, userData in
                self?.user = user
                self?.userData = userData
            }
            .store(in: &cancellables)
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            let encoder = JSONEncoder()
            let userRecord = UserRecord(userID: user?.uid)
            if let encodedData = try? encoder.encode(userRecord) {
                if (user?.uid == nil && userData == nil) || (user?.uid != nil && userData?.role == "senior") {
                    session.sendMessage(["user_auth": encodedData], replyHandler: nil)
                    print("Message sent")
                }
            }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("watch detected")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        //
    }

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
}

