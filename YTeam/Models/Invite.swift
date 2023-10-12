//
//  Invite.swift
//  YTeam
//
//  Created by Yap Justin on 12/10/23.
//

import Foundation
import FirebaseFirestoreSwift

struct Invite: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var seniorEmail: String?
    var caregiverEmail: String?
    var isAccepted: Bool?
}
