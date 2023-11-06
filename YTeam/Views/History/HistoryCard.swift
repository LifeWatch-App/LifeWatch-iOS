//
//  HistoryCard.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 05/11/23.
//

import SwiftUI

struct HistoryCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    var option: HistoryCardOption
    var time: String
    var finishedTime: String?
    
    var body: some View {
        HStack{
            Image(systemName: option == .fell ? "figure.fall" : option == .pressed ? "sos.circle.fill" : option == .idle ? "moon.fill" : "bolt.fill")
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(option == .fell || option == .idle ? .accent : Color("emergency-pink"))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Text(option == .fell ? "Fell" : option == .pressed ? "Pressed" : option == .idle ? "Idle" : "Charging")
                .padding(.leading, 8.0)
            Spacer()
            Group{
                Image(systemName: "clock")
                
                if (option == .idle || option == .charging){
                    Text("\(time) - \(finishedTime ?? "")")
                } else {
                    Text(time)
                }
            }
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(colorScheme == .light ? .white : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
