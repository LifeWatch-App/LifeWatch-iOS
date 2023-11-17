//
//  OpenAIService.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 15/11/23.
//

import Alamofire
import Foundation

class OpenAIService {
    static let shared = OpenAIService()
    
    let baseUrl = "https://api.openai.com/v1/chat/completions"
    
    func sendMessage(messages: [Message]) async -> OpenAIChatResponse? {
        let openAIMessages = messages.map({OpenAIChatMessage(role: $0.role, content: $0.content)})
        
        let body = OpenAIChatBody(model: "gpt-3.5-turbo", messages: openAIMessages)

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(OpenAIAPIConstant.openAIAPIKey)",
            "Content-Type": "application/json"
        ]
        
        do {
            let response = try await AF.request(baseUrl, method: .post, parameters: body, encoder: .json, headers: headers).serializingDecodable(OpenAIChatResponse.self).value
            
            return response
        } catch {
            print("Error sending request: \(error)")
            return nil
        }
    }
}

struct OpenAIChatBody: Encodable {
    let model: String
    let messages: [OpenAIChatMessage]
}

struct OpenAIChatMessage: Codable {
    let role: SenderRole
    let content: String
}

enum SenderRole: String, Codable {
    case system
    case user
    case assistant
}

struct OpenAIChatResponse: Decodable {
    let choices: [OpenAIChatChoice]
}

struct OpenAIChatChoice: Decodable {
    let message: OpenAIChatMessage
}

struct Message: Decodable {
    let id: UUID
    let role: SenderRole
    let content: String
    let createdAt: Date
}
