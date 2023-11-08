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
                        
                        VStack(spacing: 12) {
                            ForEach(symptomsDummyData.prefix(3).indices, id: \.self) { index in
                                HStack {
                                    Image(symptomsDummyData[index].name)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                    
                                    Text(symptomsDummyData[index].name)
                                        .font(.headline)
                                        .padding(.leading, 4)
                                    
                                    Spacer()
                                    
                                    Text("1")
                                        .font(.title3)
                                        .bold()
                                }
                                
                                if index != symptomsDummyData.count-1 && index < 2 {
                                    Divider()
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

//struct HistoryEmergency: View {
//    @ObservedObject var historyViewModel: HistoryViewModel
//    var body: some View {
//        VStack {
//            HStack{
//                Text("Summary")
//                    .font(.title3)
//                    .bold()
//                Spacer()
//            }
//            
//            if (historyViewModel.loading == true) {
//                ProgressView()
//            } else {
//                HStack{
//                    DetectedFallCard(fallCount: $historyViewModel.fallsCount)
//                    SOSCard(sosCount: $historyViewModel.sosCount)
//                }
//                
//                ForEach(historyViewModel.groupedEmergencies, id: \.0) { (time: String, emergencies: [Emergency]) in
//                    VStack{
//                        HStack{
//                            Text(time)
//                                .font(.headline)
//                            Spacer()
//                        }
//                        .padding(.top, 8)
//                        ForEach(0..<emergencies.count, id: \.self) { index in
//                            if let fall = emergencies[index] as? Fall {
//                                HistoryCard(option: .fell, time: Date.unixToString(unix: fall.time, timeOption: .hour))
//                                    .listRowSeparator(.hidden)
//                            } else if let sos = emergencies[index] as? SOS {
//                                HistoryCard(option: .pressed, time: Date.unixToString(unix: sos.time, timeOption: .hour))
//                                    .listRowSeparator(.hidden)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        .padding(.top, 8)
//        .padding(.horizontal, 16)
//    }
//}
//
//struct HistoryHeartRate: View {
//    @Environment(\.calendar) var calendar
//    @ObservedObject var historyViewModel: HistoryViewModel
//    
//    func endOfDay(for date: Date) -> Date {
//        calendar.date(byAdding: .day, value: 1, to: date)!
//    }
//    
//    @State var rawSelectedDate: Date? = nil
//    var selectedDate: HeartRateChart? {
//        if let rawSelectedDate {
//            return historyViewModel.heartRateData.first {
//                let endOfDay = endOfDay(for: $0.day)
//                
//                return ($0.day ... endOfDay).contains(rawSelectedDate)
//            }
//        }
//        
//        return nil
//    }
//    
//    var body: some View {
//        VStack {
//            VStack {
//                HStack{
//                    Text("Summary")
//                        .font(.title3)
//                        .bold()
//                    Spacer()
//                }
//                
//                if (historyViewModel.loading == true) {
//                    ProgressView()
//                } else {
//                    VStack {
//                        HStack {
//                            VStack(alignment: .leading) {
//                                Text("Average Heart Rate This Week")
//                                    .foregroundStyle(.secondary)
//                                Text("\(historyViewModel.avgHeartRate) BPM")
//                                    .font(.headline)
//                            }
//                            Spacer()
//                        }
//                        .opacity(selectedDate == nil ? 1.0 : 0.0)
//                        
//                        Chart {
//                            ForEach(historyViewModel.heartRateData) {
//                                LineMark(x: .value("Date", $0.day, unit: .day), y: .value("Avg. Heart Rate", $0.avgHeartRate)
//                                )
//                                .clipShape(RoundedRectangle(cornerRadius: 2))
//                                
//                                PointMark(x: .value("Date", $0.day, unit: .day), y: .value("Avg. Heart Rate", $0.avgHeartRate)
//                                )
//                                .clipShape(RoundedRectangle(cornerRadius: 2))
//                            }
//                            
//                            if let rawSelectedDate {
//                                RuleMark(
//                                    x: .value("Selected", rawSelectedDate, unit: .day)
//                                )
//                                .foregroundStyle(Color(.systemGray6))
//                                .offset(yStart: -8, yEnd: -1)
//                                .zIndex(-1)
//                                .annotation(
//                                    position: .top, spacing: 0,
//                                    overflowResolution: .init(
//                                        x: .fit(to: .chart),
//                                        y: .disabled
//                                    )
//                                ) {
//                                    HStack {
//                                        Text("Avg. Heart Rate:")
//                                            .foregroundStyle(.accent)
//                                        
//                                        Text("\(selectedDate?.avgHeartRate ?? 0) BPM")
//                                            .font(.headline)
//                                    }
//                                    .padding(12)
//                                    .background(Color(.systemGray6))
//                                    .clipShape(RoundedRectangle(cornerRadius: 8))
//                                }
//                            }
//                        }
//                        .chartLegend(.hidden)
//                        .chartXSelection(value: $rawSelectedDate)
//                        .chartXAxis {
//                            AxisMarks(values: historyViewModel.inactivityData.map { $0.day }) { date in
//                                AxisValueLabel(format: .dateTime.weekday(), horizontalSpacing: 10)
//                            }
//                        }
//                        .frame(height: 200)
//                    }
//                    .padding()
//                    .background(Color(.systemBackground))
//                    .clipShape(RoundedRectangle(cornerRadius: 16))
//                    
//                    // Heart Rate Card Here
//                }
//            }
//            .padding(.horizontal)
//        }
//    }
//}
//
//struct HistoryInactivity: View {
//    @Environment(\.calendar) var calendar
//    @ObservedObject var historyViewModel: HistoryViewModel
//    
//    func endOfDay(for date: Date) -> Date {
//        calendar.date(byAdding: .day, value: 1, to: date)!
//    }
//    
//    @State var rawSelectedDate: Date? = nil
//    var selectedDate: [InactivityChart]? {
//        if let rawSelectedDate {
//            return historyViewModel.inactivityData.filter {
//                let endOfDay = endOfDay(for: $0.day)
//                
//                return ($0.day ... endOfDay).contains(rawSelectedDate)
//            }
//        }
//        
//        return nil
//    }
//    
//    var body: some View {
//        VStack {
//            HStack{
//                Text("Summary")
//                    .font(.title3)
//                    .bold()
//                Spacer()
//            }
//            
//            if (historyViewModel.loading == true) {
//                ProgressView()
//            } else {
//                VStack {
//                    VStack(alignment: .leading) {
//                        Text("Total Inactivity This Week")
//                            .foregroundStyle(.secondary)
//                        HStack(spacing: 20) {
//                            VStack(alignment: .leading) {
//                                Text("Idle")
//                                    .foregroundStyle(.accent)
//                                Text("\(historyViewModel.totalIdleTime)")
//                                    .font(.headline)
//                            }
//                            VStack(alignment: .leading) {
//                                Text("Charging")
//                                    .foregroundStyle(Color("secondary-orange"))
//                                Text("\(historyViewModel.totalChargingTime)")
//                                    .font(.headline)
//                            }
//                            Spacer()
//                        }
//                    }
//                    .opacity(selectedDate == nil ? 1.0 : 0.0)
//                    
//                    Chart {
//                        ForEach(historyViewModel.inactivityData) {
//                            BarMark(x: .value("Date", $0.day, unit: .day), y: .value("Minutes", $0.minutes)
//                                    //                        historyViewModel.extractDate(date: $0.day, format: "E")
//                            )
//                            .foregroundStyle(by: .value("Type", $0.type))
//                            .clipShape(RoundedRectangle(cornerRadius: 2))
//                        }
//                        
//                        if let rawSelectedDate {
//                            RuleMark(
//                                x: .value("Selected", rawSelectedDate, unit: .day)
//                            )
//                            .foregroundStyle(Color(.systemGray6))
//                            .offset(yStart: -8, yEnd: -1)
//                            .zIndex(-1)
//                            .annotation(
//                                position: .top, spacing: 0,
//                                overflowResolution: .init(
//                                    x: .fit(to: .chart),
//                                    y: .disabled
//                                )
//                            ) {
//                                HStack {
//                                    ForEach(selectedDate ?? []) { date in
//                                        VStack {
//                                            Text("\(date.type)")
//                                                .foregroundStyle(date.type == "Idle" ? .accent : Color("secondary-orange"))
//                                            Text("\(historyViewModel.convertToHoursMinutes(minutes: date.minutes))")
//                                                .font(.headline)
//                                        }
//                                        .padding(.horizontal, 6)
//                                    }
//                                }
//                                .padding(.vertical, 12)
//                                .padding(.horizontal, 6)
//                                .background(Color(.systemGray6))
//                                .clipShape(RoundedRectangle(cornerRadius: 8))
//                            }
//                        }
//                    }
//                    .chartForegroundStyleScale(
//                        ["Idle": .accent, "Charging": Color("secondary-orange")]
//                    )
//                    .chartLegend(.hidden)
//                    .chartXSelection(value: $rawSelectedDate)
//                    .chartXAxis {
//                        AxisMarks(values: historyViewModel.inactivityData.map { $0.day }) { date in
//                            AxisValueLabel(format: .dateTime.weekday(), horizontalSpacing: 10)
//                        }
//                    }
//                    .frame(height: 200)
//                }
//                .padding()
//                .background(Color(.systemBackground))
//                .clipShape(RoundedRectangle(cornerRadius: 16))
//            }
//            ForEach(historyViewModel.groupedInactivities, id: \.0) { (time: String, inactivities: [Any]) in
//                VStack{
//                    HStack{
//                        Text(time)
//                            .font(.headline)
//                        Spacer()
//                    }
//                    .padding(.top, 8)
//                    ForEach(0..<inactivities.count, id: \.self) { index in
//                        if let idle = inactivities[index] as? Idle {
//                            HistoryCard(option: .idle, time: Date.unixToString(unix: idle.startTime ?? 0, timeOption: .hour), finishedTime: Date.unixToString(unix: idle.endTime ?? 0, timeOption: .hour))
//                                .listRowSeparator(.hidden)
//                        } else if let charge = inactivities[index] as? Charge {
//                            HistoryCard(option: .charging, time: Date.unixToString(unix: charge.startCharging ?? 0, timeOption: .hour), finishedTime: Date.unixToString(unix: charge.endCharging ?? 0, timeOption: .hour))
//                                .listRowSeparator(.hidden)
//                        }
//                    }
//                }
//            }
//        }
//        .padding(.top, 8)
//        .padding(.horizontal, 16)
//    }
//}
