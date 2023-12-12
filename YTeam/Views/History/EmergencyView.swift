//
//  EmergencyView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 05/11/23.
//

import SwiftUI

struct EmergencyView: View {
    @ObservedObject var historyViewModel: HistoryViewModel
    
    var body: some View {
        VStack {
            if (historyViewModel.loading == true) {
                ProgressView()
            } else {
                VStack {
                    HistoryWeekPicker(historyViewModel: historyViewModel)
                    ScrollView {
                    HStack{
                        DetectedFallCard(fallCount: $historyViewModel.fallsCount)
                        SOSCard(sosCount: $historyViewModel.sosCount)
                    }
                    
                    ForEach(historyViewModel.groupedEmergencies, id: \.0) { (time: String, emergencies: [Emergency]) in
                        VStack{
                            HStack{
                                Text(time)
                                    .font(.headline)
                                Spacer()
                            }
                            .padding(.top, 8)
                            ForEach(0..<emergencies.count, id: \.self) { index in
                                if let fall = emergencies[index] as? Fall {
                                    HistoryCard(option: .fell, time: Date.unixToTime(unix: fall.time))
                                        .listRowSeparator(.hidden)
                                } else if let sos = emergencies[index] as? SOS {
                                    HistoryCard(option: .pressed, time: Date.unixToTime(unix: sos.time))
                                        .listRowSeparator(.hidden)
                                }
                            }
                        }
                    }
                }
                }
                
                Spacer()
            }
        }
        .padding(.top, 8)
        .padding(.horizontal)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Emergency History")
    }
}

struct DetectedFallCard: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var fallCount: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack{
                    Image(systemName: "figure.fall")
                        .font(.title3)
                    Text("Falls")
                }
                .foregroundStyle(.accent)
                
                Text("\(fallCount)")
                    .font(.title)
                    .bold()
                    .padding(.top, 8)
            }
            
            Spacer()
        }
        .padding()
        .background(colorScheme == .light ? .white : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct SOSCard: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var sosCount: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack{
                    Image(systemName: "sos.circle.fill")
                        .font(.title3)
                    Text("SOS Button")
                }
                .foregroundStyle(Color("emergency-pink"))
                
                Text("\(sosCount)")
                    .font(.title)
                    .bold()
                    .padding(.top, 8)
            }
            
            Spacer()
        }
        .padding()
        .background(colorScheme == .light ? .white : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    EmergencyView(historyViewModel: HistoryViewModel())
//        .preferredColorScheme(.dark)
}
