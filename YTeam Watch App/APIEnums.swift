//
//  APIEnums.swift
//  YTeam Watch App
//
//  Created by Kevin Sander Utomo on 13/10/23.
//

import Foundation

protocol Endpoint {
    var endPointDescription: String { get }
}

//enum SingleEndpoints: Endpoint {
//    case userprofile(userID: String)
//
//    var endPointDescription: String {
//        switch self {
//        case let .pokemon(pokemonID):
//            return "/userProfiles/\(pokemonID)"
//        }
//    }
//}

enum MultipleEndPoints: Endpoint {
    case userprofile

    var endPointDescription: String {
        switch self {
        case .userprofile:
            return "/userProfiles/"
        }
    }
}

enum APIError: LocalizedError {
    case invalidURL, invalidResponse, invalidResponseCode(code: String), unknownError, invalidData, errorParsingJSON

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL that has been provided is invalid!"
        case .invalidResponse:
            return "The response that has been provided is invalid!"
        case .invalidResponseCode(let code):
            return "The code that has been provided is out of bounds: \(code)!"
        case .unknownError:
            return "There is an unknown error that occured!"
        case .invalidData:
            return "Your data is empty or not available!"
        case .errorParsingJSON:
            return "There is an error when trying to parse JSON!"
        }
    }
}

enum HTTPMethod: String {
    case get, post, patch, delete

    var methodDescription: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .patch:
            return "PATCH"
        case .delete:
            return "DELETE"
        }
    }
}
