//
//  OpenAIService.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 15/11/23.
//

import Alamofire
import Combine

class OpenAIService {
    static let shared = OpenAIService()
    
    let baseUrl = "https://api.openai.com/v1/"
    
    func sendMessage(message: String) -> AnyPublisher<OpenAICompletionsResponse, Error> {
        let body = OpenAICompletionsBody(model: "gpt-3.5-turbo-instruct", prompt: message, temperature: 0.5, max_tokens: 256)
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(OpenAIAPIConstantConstant.openAIAPIKey)"
        ]
        
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            AF.request(self.baseUrl + "completions", method: .post, parameters: body, encoder: .json, headers: headers).responseDecodable(of: OpenAICompletionsResponse.self) { response in
                switch response.result {
                case .success(let result):
                    promise(.success(result))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

struct OpenAICompletionsBody: Encodable {
    let model: String
    let prompt: String
    let temperature: Float?
    let max_tokens: Int
}

struct OpenAICompletionsResponse: Decodable {
    let id: String
    let choices: [OpenAICompletionChoices]
}

struct OpenAICompletionChoices: Decodable {
    let text: String
}
