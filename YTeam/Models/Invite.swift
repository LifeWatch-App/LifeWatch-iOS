//
//  Invite.swift
//  YTeam
//
//  Created by Yap Justin on 12/10/23.
//

import Foundation
import FirebaseFirestoreSwift

struct Invite: Identifiable, Codable { 
    @DocumentID var id: String?
    var seniorId: String?
    var caregiverId: String?
    var accepted: Bool?
    var seniorData: UserData?
    var caregiverData: UserData?
}
