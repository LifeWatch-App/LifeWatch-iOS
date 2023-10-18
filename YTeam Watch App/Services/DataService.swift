//
//  LocationDataService.swift
//  YTeam Watch App
//
//  Created by Kevin Sander Utomo on 13/10/23.
//

import Foundation

final class DataService {
    static let shared = DataService()

    func fetch<T: Codable>(endPoint: Endpoint, httpMethod: HTTPMethod) async throws -> T {
        guard let url = URL(string: "\(APIConstants.baseURL)\(endPoint.endPointDescription)") else {
            print("URL is invalid")
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.methodDescription

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Server response is invalid")
                throw APIError.invalidResponse
            }

            guard (200..<300).contains(httpResponse.statusCode) else {
                print("Server error with status code: \(httpResponse.statusCode)")
                throw APIError.invalidResponseCode(code: httpResponse.statusCode.description)
            }

            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            print("Error: \(error)")
            throw APIError.unknownError
        }
    }

    func delete(endPoint: Endpoint, httpMethod: HTTPMethod) async throws {
        guard let url = URL(string: "\(APIConstants.baseURL)\(endPoint.endPointDescription)") else {
            print("URL is invalid")
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.methodDescription

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Server response is invalid")
                throw APIError.invalidResponse
            }

            guard (200..<300).contains(httpResponse.statusCode) else {
                print("Server error with status code: \(httpResponse.statusCode)")
                throw APIError.invalidResponseCode(code: httpResponse.statusCode.description)
            }
            print("Successfully Performed Deletion Request")
        } catch {
            print("Error: \(error)")
            throw APIError.unknownError
        }
    }

    func set<T: Codable>(endPoint: Endpoint, fields: T, httpMethod: HTTPMethod) async throws {
        let firestoreURL = "\(APIConstants.baseURL)\(endPoint.endPointDescription)"

        guard let url = URL(string: firestoreURL) else {
            print("URL is invalid")
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.methodDescription
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let document = Document(fields: fields)
        print(document)
        let encodedData = try JSONEncoder().encode(document)
        print(try JSONSerialization.jsonObject(with: encodedData))
        request.httpBody = encodedData

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Server response is invalid")
                throw APIError.invalidResponse
            }

            guard (200..<300).contains(httpResponse.statusCode) else {
                print("Server error with status code: \(httpResponse.statusCode)")
                throw APIError.invalidResponseCode(code: httpResponse.statusCode.description)
            }

            print("Success Sending \(httpMethod.methodDescription) Request")
        } catch {
            print("Error: \(error)")
            throw APIError.unknownError
        }
    }

}
