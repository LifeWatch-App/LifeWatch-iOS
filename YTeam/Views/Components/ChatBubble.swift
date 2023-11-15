//
//  ChatBubble.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 15/11/23.
//

import SwiftUI

struct ChatBubble: Shape {
    let sender: MessageSender
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [
                .topRight,
                .topLeft,
                sender == .me ? .bottomLeft : .bottomRight
            ],
            cornerRadii: CGSize(width: 16, height: 16))
        
        return Path(path.cgPath)
    }
}

#Preview {
    ChatBubble(sender: .me)
}
