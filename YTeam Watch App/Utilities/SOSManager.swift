//
//  SOSManager.swift
//  YTeam Watch App
//
//  Created by Kenny Jinhiro Wibowo on 07/11/23.
//

import Foundation

class SOSManager: ObservableObject {
    @Published var showSOS: Bool = false
    private var decoder: JSONDecoder = JSONDecoder()
    private let service = DataService.shared
    
    static var shared: SOSManager = SOSManager()
    
    func sendSOS() {
        guard let data = UserDefaults.standard.data(forKey: "user-auth") else { return }
        let userRecord = try? self.decoder.decode(UserRecord.self, from: data)
        let timeDescription: Double = Date.now.timeIntervalSince1970
        
        if (userRecord != nil) {
            let sos = SOS(seniorId: Description(stringValue: userRecord?.userID), time: Description(doubleValue: timeDescription))
            Task { try? await service.set(endPoint: MultipleEndPoints.sos, fields: sos, httpMethod: .post) }
        }
    }
}
