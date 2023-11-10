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
                        .padding(.horizontal)
                    
                    ScrollView {
                        VStack {
                            SymptomCards(historyViewModel: historyViewModel)
                            
                            // foreach symptom here
                            
                            Spacer()
                        }
                    }
                }
                .padding(.top, 8)
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Symptoms History")
            }
        }
    }
}

struct SymptomCards: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var historyViewModel: HistoryViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(historyViewModel.filteredSymptoms.sorted { $0.value > $1.value }, id: \.key) { key, value in
                    VStack(alignment: .leading) {
                        HStack {
                            Image("\(key)")
                                .resizable()
                                .frame(width: 36, height: 36)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            
                            Spacer()
                        }
                        
                        Text("\(key)")
                            .font(.system(size: 16))
                            .minimumScaleFactor(0.5)
                        
                        Spacer()
                        
                        HStack {
                            Text("\(value)")
                                .font(.system(size: 28))
                                .bold()
                            
                            Text("times")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 16))
                        }
                    }
                    .padding(12)
                    .frame(width: 110, height: 145)
                    .background(colorScheme == .light ? .white : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal)
        }
        
    }
}

#Preview {
    SymptomView(historyViewModel: HistoryViewModel())
}
