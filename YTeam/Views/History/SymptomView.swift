//
//  SymptomView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 05/11/23.
//

import SwiftUI

struct SymptomView: View {
    @ObservedObject var historyViewModel: HistoryViewModel
    
    var body: some View {
        VStack {
            if (historyViewModel.loading == true) {
                ProgressView()
            } else {
                VStack {
                    HistoryWeekPicker(historyViewModel: historyViewModel)
                    
                    Spacer()
                }
                .padding(.top, 8)
                .padding(.horizontal)
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Symptoms History")
            }
        }
    }
}

#Preview {
    SymptomView(historyViewModel: HistoryViewModel())
}
