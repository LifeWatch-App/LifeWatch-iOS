//
//  Invite.swift
//  YTeam
//
//  Created by Yap Justin on 12/10/23.
//

import Foundation
import FirebaseFirestoreSwift

struct Invite: Identifiable, Codable, Hashable {
    static func == (lhs: Invite, rhs: Invite) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    @DocumentID var id: String?
    var seniorId: String?
    var caregiverId: String?
    var accepted: Bool?
    var seniorData: UserData?
    var caregiverData: UserData?
}
