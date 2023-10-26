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
}

struct Description: Codable, Hashable {
    let stringValue: String?
    let doubleValue: Double?
    let intValue: Int?
    let doubleValue: Double?
    let timeStampValue: String?
    
    init(stringValue: String? = nil, doubleValue: Double? = nil, intValue: Int? = nil, timeStampValue: String? = nil) {
        self.stringValue = stringValue
        self.doubleValue = doubleValue
        self.intValue = intValue
        self.timeStampValue = timeStampValue
    }
}
