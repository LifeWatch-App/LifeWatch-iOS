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
                        ForEach(consultationViewModel.messages.filter({$0.role != .system}), id: \.id) { message in
                            messageView(message: message)
                        }
                        
                        if consultationViewModel.isLoading {
                            HStack(alignment: .bottom){
                                Image("Robot")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 28)
                                ProgressView()
                                    .padding()
                                    .background(colorScheme == .light ? .white : Color(.systemGray6))
                                    .clipShape(ChatBubble(sender: .assistant))
                                
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }
                
                Group {
                    Divider()
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    Text("This medical AI is intended solely for educational purposes and should not be used as a substitute for professional medical advice.")
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                    Button("Click here for more information") {
                        consultationViewModel.showDisclaimerSheet.toggle()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                }
                .font(.caption)
                
                HStack {
                    TextField("Enter a message", text: $consultationViewModel.messageText)
                        .padding()
                        .background(colorScheme == .light ? .white : Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Button {
                        consultationViewModel.sendMessage()
                    } label: {
                        Text("Send")
                            .foregroundStyle(.white)
                            .padding()
                            .background(!consultationViewModel.isLoading ? .accent : .secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(consultationViewModel.isLoading)
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
            }
            .sheet(isPresented: $consultationViewModel.showDisclaimerSheet) {
                DisclaimerView()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("AI Health Consultation")
            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    NavigationLink {
//                        EmptyView()
//                    } label: {
//                        Image(systemName: "clock.arrow.circlepath")
//                            .font(.headline)
//                    }
//                }
//            }
        }
    }
    
    func messageView(message: Message) -> some View {
        HStack {
            if message.role == .user {
                Spacer()
                
                Text(message.content)
                    .foregroundStyle(.white)
                    .padding()
                    .background(.blue)
                    .clipShape(ChatBubble(sender: message.role))
                    .frame(maxWidth: UIScreen.main.bounds.width / 1.4, alignment: .trailing)
            } else if message.role == .assistant {
                HStack(alignment: .bottom){
                    Image("Robot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28)
                    Text(message.content)
                        .padding()
                        .background(colorScheme == .light ? .white : Color(.systemGray6))
                        .clipShape(ChatBubble(sender: message.role))
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
