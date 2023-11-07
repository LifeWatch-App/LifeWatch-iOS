//
//  CardShape.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 03/11/23.
//

import SwiftUI

struct CardShape: Shape {

    //create custom clipshape
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 8, height: 8))

        return Path(path.cgPath)
    }
}

//struct ChatBubble_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatBubble(isFromCurrentUser: true)
//    }
//}
