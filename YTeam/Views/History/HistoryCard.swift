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
            Image(systemName: option == .fell ? "figure.fall" : option == .pressed ? "sos.circle.fill" : option == .idle ? "moon.fill" : option == .charging ? "bolt.fill" : "arrow.down.heart.fill")
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(option == .fell || option == .idle ? .accent : option == .pressed || option == .lowHeartRate ? Color("emergency-pink") : Color("secondary-orange"))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Text(option == .fell ? "Fell" : option == .pressed ? "Pressed" : option == .idle ? "Idle" : option == .charging ? "Charging" : option == .lowHeartRate ? "Low Heart Rate Detected" : option == .highHeartRate ? "High Heart Rate Detected" : "Irregular Heart Rate Detected")
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


struct SymptomCard: View {
    @Environment(\.colorScheme) var colorScheme

    var symptomName: String
    var time: String

    var body: some View {
        HStack{
            Image(symptomName)
                .resizable()
                .frame(width: 40, height: 40)
//                .background(option == .fell || option == .idle ? .accent : option == .pressed || option == .lowHeartRate ? Color("emergency-pink") : Color("secondary-orange"))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(symptomName)
                .padding(.leading, 8.0)

            Spacer()
            Group{
                Image(systemName: "clock")

                Text(time)
            }
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(colorScheme == .light ? .white : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
