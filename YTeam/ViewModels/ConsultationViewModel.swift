//
//  ConsultationViewModel.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 15/11/23.
//

import Foundation
import Combine

class ConsultationViewModel: ObservableObject {
//    @Published var messages: [Message] = [Message(id: UUID(), role: .system, content: "You are a medical assistant, you will help me understand about medical topics. You don't have enough information about other topics to give advice.", createdAt: Date())]
    @Published var messages: [Message] = []
    @Published var messageText: String = ""
    
    func sendMessage() {
        let newMessage = Message(id: UUID(), role: .user, content: messageText, createdAt: Date())
        messages.append(newMessage)
        messageText = ""
        
        Task {
            let response = await OpenAIService.shared.sendMessage(messages: messages)
            guard let receivedOpenAIMessage = response?.choices.first?.message else {
                print("Had no received message")
                return
            }
            
            let receivedMessage = Message(id: UUID(), role: receivedOpenAIMessage.role, content: receivedOpenAIMessage.content, createdAt: Date())
            await MainActor.run {
                messages.append(receivedMessage)
            }
        }
    }
}
