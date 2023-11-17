//
//  InactivityView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 05/11/23.
//

import SwiftUI
import Charts

struct InactivityView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.calendar) var calendar
    @ObservedObject var historyViewModel: HistoryViewModel
    
    func endOfDay(for date: Date) -> Date {
        calendar.date(byAdding: .day, value: 1, to: date)!
    }
    
    @State var rawSelectedDate: Date? = nil
    var selectedDate: [InactivityChart]? {
        if let rawSelectedDate {
            return historyViewModel.inactivityData.filter {
                let endOfDay = endOfDay(for: $0.day)
                
                return ($0.day ... endOfDay).contains(rawSelectedDate)
            }
        }
        
        return nil
    }
    
    var body: some View {
        VStack {
            if (historyViewModel.loading == true) {
                ProgressView()
            } else {
                HistoryWeekPicker(historyViewModel: historyViewModel)
                ScrollView {
                VStack {
                    VStack(alignment: .leading) {
                        Text("Total Inactivity This Week")
                            .foregroundStyle(.secondary)
                        HStack(spacing: 20) {
                            VStack(alignment: .leading) {
                                Text("Idle")
                                    .foregroundStyle(.accent)
                                Text("\(historyViewModel.totalIdleTime)")
                                    .font(.headline)
                            }
                            VStack(alignment: .leading) {
                                Text("Charging")
                                    .foregroundStyle(Color("secondary-orange"))
                                Text("\(historyViewModel.totalChargingTime)")
                                    .font(.headline)
                            }
                            Spacer()
                        }
                    }
                    .opacity(selectedDate == nil ? 1.0 : 0.0)
                    
                    Chart {
                        ForEach(historyViewModel.inactivityData) {
                            BarMark(x: .value("Date", $0.day, unit: .day), y: .value("Minutes", $0.minutes)
                                    //                        historyViewModel.extractDate(date: $0.day, format: "E")
                            )
                            .foregroundStyle(by: .value("Type", $0.type))
                            .clipShape(RoundedRectangle(cornerRadius: 2))
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
                                    ForEach(selectedDate ?? []) { date in
                                        VStack {
                                            Text("\(date.type)")
                                                .foregroundStyle(date.type == "Idle" ? .accent : Color("secondary-orange"))
                                            Text("\(historyViewModel.convertToHoursMinutes(minutes: date.minutes))")
                                                .font(.headline)
                                        }
                                        .padding(.horizontal, 6)
                                    }
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 6)
                                .background(colorScheme == .light ? Color(.systemGray6) : Color(.systemGray5))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .chartForegroundStyleScale(
                        ["Idle": .accent, "Charging": Color("secondary-orange")]
                    )
                    .chartLegend(.hidden)
                    .chartXSelection(value: $rawSelectedDate)
                    .chartXAxis {
                        AxisMarks(values: historyViewModel.inactivityData.map { $0.day }) { date in
                            AxisValueLabel(format: .dateTime.weekday(), horizontalSpacing: 10)
                        }
                    }
                    .frame(height: 200)
                }
            }
                .padding()
                .background(colorScheme == .light ? .white : Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                ForEach(historyViewModel.groupedInactivities, id: \.0) { (time: String, inactivities: [Any]) in
                    VStack{
                        HStack{
                            Text(time)
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.top, 8)
                        ForEach(0..<inactivities.count, id: \.self) { index in
                            if let idle = inactivities[index] as? Idle {
                                HistoryCard(option: .idle, time: Date.unixToString(unix: idle.startTime ?? 0, timeOption: .hour), finishedTime: Date.unixToString(unix: idle.endTime ?? 0, timeOption: .hour))
                                    .listRowSeparator(.hidden)
                            } else if let charge = inactivities[index] as? Charge {
                                HistoryCard(option: .charging, time: Date.unixToString(unix: charge.startCharging ?? 0, timeOption: .hour), finishedTime: Date.unixToString(unix: charge.endCharging ?? 0, timeOption: .hour))
                                    .listRowSeparator(.hidden)
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
        .navigationTitle("Inactivity History")
    }
}

#Preview {
    InactivityView(historyViewModel: HistoryViewModel())
//        .preferredColorScheme(.dark)
}
