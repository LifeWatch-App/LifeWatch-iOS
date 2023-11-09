//
//  HistoryView.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 16/10/23.
//

import SwiftUI
import Charts

struct HistoryView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var historyViewModel: HistoryViewModel = HistoryViewModel()
    
    @State var showChangeSenior = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HistoryWeekPicker(historyViewModel: historyViewModel)
                
                ScrollView {
                    VStack {
                        HStack(alignment: .bottom) {
                            Text("Symptoms")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            NavigationLink {
                                SymptomView(historyViewModel: historyViewModel)
                            } label: {
                                Text("Details")
                                    .font(.headline)
                                    .foregroundStyle(.accent)
                            }
                        }
                        
                        VStack(spacing: 16) {
                            ForEach(historyViewModel.symptoms.sorted { $0.value > $1.value }.prefix(3), id: \.key) { key, value in
                                HStack {
                                    Image("\(key)")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                    
                                    Text("\(key)")
                                        .font(.headline)
                                        .padding(.leading, 4)
                                    
                                    Spacer()
                                    
                                    Text("\(value)")
                                        .font(.title3)
                                        .bold()
                                }
                            }
                        }
                        .padding()
                        .background(colorScheme == .light ? .white : Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.bottom)
                    
                    VStack {
                        HStack(alignment: .bottom) {
                            Text("Emergency")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            NavigationLink {
                                EmergencyView(historyViewModel: historyViewModel)
                            } label: {
                                Text("Details")
                                    .font(.headline)
                                    .foregroundStyle(.accent)
                            }
                        }
                        
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "figure.fall")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundStyle(.white)
                                    .padding(8)
                                    .background(.accent)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                
                                Text("Detected Falls")
                                    .font(.headline)
                                    .padding(.leading, 4)
                                
                                Spacer()
                                
                                Text("\(historyViewModel.fallsCount)")
                                    .font(.title3)
                                    .bold()
                            }
                            
                            Divider()
                            
                            HStack {
                                Image(systemName: "sos.circle.fill")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundStyle(.white)
                                    .padding(8)
                                    .background(Color("emergency-pink"))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                
                                Text("SOS Button Pressed")
                                    .font(.headline)
                                    .padding(.leading, 4)
                                
                                Spacer()
                                
                                Text("\(historyViewModel.sosCount)")
                                    .font(.title3)
                                    .bold()
                            }
                        }
                        .padding()
                        .background(colorScheme == .light ? .white : Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.bottom)
                    
                    VStack {
                        HStack(alignment: .bottom) {
                            Text("Heart Rate")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            NavigationLink {
                                HeartRateView(historyViewModel: historyViewModel)
                            } label: {
                                Text("Details")
                                    .font(.headline)
                                    .foregroundStyle(.accent)
                            }
                        }
                        
                        VStack {
                            Chart {
                                ForEach(historyViewModel.heartRateData) {
                                    LineMark(x: .value("Date", $0.day, unit: .day), y: .value("Avg. Heart Rate", $0.avgHeartRate)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 2))
                                    
                                    PointMark(x: .value("Date", $0.day, unit: .day), y: .value("Avg. Heart Rate", $0.avgHeartRate)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 2))
                                }
                            }
                            .chartLegend(.hidden)
                            .chartXAxis {
                                AxisMarks(values: historyViewModel.heartRateData.map { $0.day }) { date in
                                    AxisValueLabel(format: .dateTime.weekday(), horizontalSpacing: 10)
                                }
                            }
                            .frame(height: 150)
                        }
                        .padding()
                        .background(colorScheme == .light ? .white : Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.bottom)
                    
                    VStack {
                        HStack(alignment: .bottom) {
                            Text("Inactivity")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            NavigationLink {
                                InactivityView(historyViewModel: historyViewModel)
                            } label: {
                                Text("Details")
                                    .font(.headline)
                                    .foregroundStyle(.accent)
                            }
                        }
                        
                        VStack {
                            Chart {
                                ForEach(historyViewModel.inactivityData) {
                                    BarMark(x: .value("Date", $0.day, unit: .day), y: .value("Minutes", $0.minutes)
                                    )
                                    .foregroundStyle(by: .value("Type", $0.type))
                                    .clipShape(RoundedRectangle(cornerRadius: 2))
                                }
                            }
                            .chartForegroundStyleScale(
                                ["Idle": .accent, "Charging": Color("secondary-orange")]
                            )
                            .chartLegend(.hidden)
                            .chartXAxis {
                                AxisMarks(values: historyViewModel.inactivityData.map { $0.day }) { date in
                                    AxisValueLabel(format: .dateTime.weekday(), horizontalSpacing: 10)
                                }
                            }
                            .frame(height: 150)
                        }
                        .padding()
                        .background(colorScheme == .light ? .white : Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.bottom, 8)
                }
            }
            .padding(.horizontal)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("History")
            .toolbar {
                
            }
        }
    }
}


#Preview {
    NavigationStack {
        HistoryView()
            .preferredColorScheme(.dark)
    }
}
