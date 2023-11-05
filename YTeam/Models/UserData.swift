//
//  User.swift
//  YTeam
//
//  Created by Yap Justin on 12/10/23.
//

import Foundation
import FirebaseFirestoreSwift

struct UserData: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String?
    var role: String?
    var fcmToken: String?
    var pttToken: String?
}
