//
//  HistoryWeekPicker.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 05/11/23.
//

import SwiftUI

struct HistoryWeekPicker: View {
    @ObservedObject var historyViewModel: HistoryViewModel
    
    var body: some View {
        HStack {
            Button {
                historyViewModel.changeWeek(type: .previous)
            } label: {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white, .accent)
            }
            
            Spacer()
            
            Text("\(historyViewModel.extractDate(date: historyViewModel.currentWeek.first ?? Date(), format: "dd MMM yyyy")) - \(historyViewModel.extractDate(date: historyViewModel.currentWeek.last ?? Date(), format: "dd MMM yyyy"))")
                .fontWeight(.semibold)
                .font(.system(size: 20))
                .padding(.horizontal, 2)
            
            Spacer()
            
            Button {
                historyViewModel.changeWeek(type: .next)
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white, !historyViewModel.isToday(date: Date()) ? .accent : .gray)
            }
            .disabled(historyViewModel.isToday(date: Date()))
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    HistoryWeekPicker(historyViewModel: HistoryViewModel())
}
