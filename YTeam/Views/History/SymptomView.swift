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
                            SymptomCards()
                            
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
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(symptomList, id: \.self) { symptom in
                    VStack(alignment: .leading) {
                        HStack {
                            Image(symptom)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            
                            Spacer()
                        }
                        
                        Text(symptom)
                            .font(.subheadline)
                            .minimumScaleFactor(0.5)
                        
                        HStack {
                            Text("0")
                                .font(.title)
                                .bold()
                            
                            Text("times")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                                .padding(.leading, -4)
                        }
                    }
                    .padding(12)
                    .frame(width: 110)
                    .background(colorScheme == .light ? .white : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.leading)
        }
        
    }
}

#Preview {
    SymptomView(historyViewModel: HistoryViewModel())
}
