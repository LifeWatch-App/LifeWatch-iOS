//
//  UserProfile.swift
//  YTeam Watch App
//
//  Created by Kevin Sander Utomo on 13/10/23.
//

import Foundation

struct UserProfile: Codable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    var id: Description?
    let userId: Description?
    let userName: Description?
}

struct FirestoreQueryRecord<T: Codable>: Codable {
    let document: Document<T>?
    let readTime: String
}

struct FirebaseRecords<T: Codable>: Codable {
    let documents: [Document<T>]
}

struct Document<T: Codable>: Codable {
    let createTime: String?
    let fields: T?
    let name: String?
    let updateTime: String?
    
    init(name: String? = nil, fields: T, createTime: String? = nil, updateTime: String? = nil) {
        self.name = name
        self.fields = fields
        self.createTime = createTime
        self.updateTime = updateTime
    }

    enum CodingKeys: String, CodingKey {
        case createTime = "createTime"
        case fields = "fields"
        case name = "name"
        case updateTime = "updateTime"
    }

}

struct Description: Codable, Hashable {
    let stringValue: String?
    let doubleValue: Double?
    let intValue: Int?
    let timeStampValue: String?
    let booleanValue: Bool?

    init(stringValue: String? = nil, doubleValue: Double? = nil, intValue: Int? = nil, timeStampValue: String? = nil, booleanValue: Bool? = nil) {
        self.stringValue = stringValue
        self.doubleValue = doubleValue
        self.intValue = intValue
        self.timeStampValue = timeStampValue
        self.booleanValue = booleanValue
    }
}
