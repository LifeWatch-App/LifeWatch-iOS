//
//  ConsultationViewModel.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 15/11/23.
//

import Foundation
import Combine

class ConsultationViewModel: ObservableObject {
    @Published var messages: [Message] = [
        Message(id: UUID(), role: .system, content: "You are a medical counselor, you will help me understand about medical topics. You don't have enough information about other topics to give advice and will not give any advice for other topics. When someone asks you a question unrelated to medical, simply respond with I'm not sure.", createdAt: Date()),
        Message(id: UUID(), role: .assistant, content: "Hello there, I'm an AI medical counselor available to answer questions on medical topics. How may I assist you right now?", createdAt: Date())
    ]
    @Published var messageText: String = ""
    
    @Published var isLoading: Bool = false
    
    func sendMessage() {
        let newMessage = Message(id: UUID(), role: .user, content: messageText, createdAt: Date())
        messages.append(newMessage)
        messageText = ""
        
        isLoading = true
        
        Task {
            defer {
                isLoading = false
            }
            
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
