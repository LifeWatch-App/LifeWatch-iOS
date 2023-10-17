//
//  Invite.swift
//  YTeam
//
//  Created by Yap Justin on 12/10/23.
//

import Foundation

struct Invite: Identifiable, Codable, Hashable {
    var id: String?
    var seniorEmail: String?
    var caregiverEmail: String?
    var accepted: Bool?
}
