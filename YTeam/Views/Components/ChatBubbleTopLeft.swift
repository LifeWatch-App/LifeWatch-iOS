//
//  ChatBubbleTopLeft.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 21/11/23.
//

import SwiftUI

struct ChatBubbleTopLeft: Shape {
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [
                .topRight,
                .bottomLeft,
                .bottomRight
            ],
            cornerRadii: CGSize(width: 8, height: 8))
        
        return Path(path.cgPath)
    }
}

#Preview {
    ChatBubbleTopLeft()
}
