//
//  ConsultationView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 15/11/23.
//

import SwiftUI

struct ConsultationView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var consultationViewModel = ConsultationViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVStack {
                        ForEach(consultationViewModel.chatMessages, id: \.id) { message in
//                        ForEach(ChatMessage.sampleMessages, id: \.id) { message in
                            messageView(message: message)
                        }
                    }
                    .padding()
                }
                
                HStack {
                    TextField("Enter a message", text: $consultationViewModel.messageText)
                        .padding()
                        .background(colorScheme == .light ? .white : Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Button {
                        consultationViewModel.sendMessage()
                    } label: {
                        Text("Send")
                            .foregroundStyle(.white)
                            .padding()
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding([.horizontal, .bottom])
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("AI Health Consultation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        EmptyView()
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.headline)
                    }
                }
            }
        }
    }
    
    func messageView(message: ChatMessage) -> some View {
        HStack {
            if message.sender == .me {
                Spacer()
                
                Text(message.content)
                    .foregroundStyle(.white)
                    .padding()
                    .background(.blue)
                    .clipShape(ChatBubble(sender: message.sender))
                    .frame(maxWidth: UIScreen.main.bounds.width / 1.4, alignment: .trailing)
            } else if message.sender == .gpt {
                HStack(alignment: .bottom){
                    Image("Robot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28)
                    Text(message.content)
                        .padding()
                        .background(colorScheme == .light ? .white : Color(.systemGray6))
                        .clipShape(ChatBubble(sender: message.sender))
                        .frame(maxWidth: UIScreen.main.bounds.width / 1.5, alignment: .leading)
                }
                
                Spacer()
            }
        }
        .padding(.bottom, 4)
    }
}

#Preview {
    ConsultationView()
}
