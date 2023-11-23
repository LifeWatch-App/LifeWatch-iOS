//
//  User.swift
//  YTeam
//
//  Created by Yap Justin on 12/10/23.
//

import Foundation
import FirebaseFirestoreSwift

struct UserData: Identifiable, Codable, Hashable {
    static func == (lhs: UserData, rhs: UserData) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    @DocumentID var id: String?
    var name: String?
    var email: String?
    var role: String?
    var fcmToken: String?
    var pttToken: String?
    var udid: String?
}
