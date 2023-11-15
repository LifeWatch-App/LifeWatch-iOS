//
//  ConsultationViewModel.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 15/11/23.
//

import Foundation
import Combine

class ConsultationViewModel: ObservableObject {
    @Published var chatMessages: [ChatMessage] = []
    @Published var messageText: String = ""

    @Published var cancellables = Set<AnyCancellable>()
    
    func sendMessage() {
        let myMessage = ChatMessage(id: UUID().uuidString, content: messageText, dateCreated: Date(), sender: .me)
        chatMessages.append(myMessage)
        
        OpenAIService.shared.sendMessage(message: messageText).sink { completion in
            
        } receiveValue: { response in
            guard let textResponse = response.choices.first?.text.trimmingCharacters(in: .whitespacesAndNewlines.union(.init(charactersIn: "\""))) else { return }
            
            let gptMessage = ChatMessage(id: response.id, content: textResponse, dateCreated: Date(), sender: .gpt)
            
            self.chatMessages.append(gptMessage)
        }
        .store(in: &cancellables)
        
        messageText = ""
    }
}
