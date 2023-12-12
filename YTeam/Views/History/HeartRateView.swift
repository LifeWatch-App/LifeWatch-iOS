//
//  HeartRateView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 05/11/23.
//

import SwiftUI
import Charts

struct HeartRateView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.calendar) var calendar
    @ObservedObject var historyViewModel: HistoryViewModel
    
    func endOfDay(for date: Date) -> Date {
        calendar.date(byAdding: .day, value: 1, to: date)!
    }
    
    @State var rawSelectedDate: Date? = nil
    var selectedDate: HeartRateChart? {
        if let rawSelectedDate {
            return historyViewModel.heartRateData.first {
                let endOfDay = endOfDay(for: $0.day)
                
                return ($0.day ... endOfDay).contains(rawSelectedDate)
            }
        }
        
        return nil
    }
    
    var body: some View {
        VStack {
            VStack {
                if (historyViewModel.loading == true) {
                    ProgressView()
                } else {
                    HistoryWeekPicker(historyViewModel: historyViewModel)
                    ScrollView {
                        VStack {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Average Heart Rate This Week")
                                        .foregroundStyle(.secondary)
                                    Text("\(historyViewModel.avgHeartRate) BPM")
                                        .font(.headline)
                                }
                                Spacer()
                            }
                            .opacity(selectedDate == nil ? 1.0 : 0.0)
                            
                            Chart {
                                ForEach(historyViewModel.heartRateData) {
                                    LineMark(x: .value("Date", $0.day, unit: .day), y: .value("Avg. Heart Rate", $0.avgHeartRate)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 2))
                                    
//                                    PointMark(x: .value("Date", $0.day, unit: .day), y: .value("Avg. Heart Rate", $0.avgHeartRate)
//                                    )
//                                    .clipShape(RoundedRectangle(cornerRadius: 2))
                                }
                                
                                if let rawSelectedDate {
                                    RuleMark(
                                        x: .value("Selected", rawSelectedDate, unit: .day)
                                    )
                                    .foregroundStyle(Color(.systemGray6))
                                    .offset(yStart: -8, yEnd: -1)
                                    .zIndex(-1)
                                    .annotation(
                                        position: .top, spacing: 0,
                                        overflowResolution: .init(
                                            x: .fit(to: .chart),
                                            y: .disabled
                                        )
                                    ) {
                                        HStack {
                                            Text("Avg. Heart Rate:")
                                                .foregroundStyle(.accent)
                                            
                                            Text("\(selectedDate?.avgHeartRate ?? 0) BPM")
                                                .font(.headline)
                                        }
                                        .padding(12)
                                        .background(Color(.systemGray6))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                            .chartLegend(.hidden)
                            .chartXSelection(value: $rawSelectedDate)
                            .chartXAxis {
                                AxisMarks(values: historyViewModel.heartRateData.map { $0.day }) { date in
                                    AxisValueLabel(format: .dateTime.weekday(), horizontalSpacing: 10)
                                }
                            }
                            .frame(height: 200)
                        }
                        
                        .padding()
                        .background(colorScheme == .light ? .white : Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        // Heart Rate Card Here
                        
                        ForEach(historyViewModel.groupedHeartAnomalies, id: \.0) { (time: String, anomalies: [HeartAnomaly]) in
                            VStack{
                                HStack{
                                    Text(time)
                                        .font(.headline)
                                    Spacer()
                                }
                                .padding(.top, 8)
                                ForEach(0..<anomalies.count, id: \.self) { index in
                                    if anomalies[index].anomaly == "lowHeart" {
                                        HistoryCard(option: .lowHeartRate, time: Date.unixToTime(unix: anomalies[index].time))
                                    } else if anomalies[index].anomaly == "highHeart" {
                                        HistoryCard(option: .highHeartRate, time: Date.unixToTime(unix: anomalies[index].time))
                                    } else {
                                        HistoryCard(option: .irregularHeartRate, time: Date.unixToTime(unix: anomalies[index].time))
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding(.top, 8)
        .padding(.horizontal)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Heart Rate History")
    }
}

#Preview {
    HeartRateView(historyViewModel: HistoryViewModel())
        .preferredColorScheme(.dark)
}
