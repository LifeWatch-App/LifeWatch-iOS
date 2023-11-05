//
//  HistoryView.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 16/10/23.
//

import SwiftUI
import Charts

struct HistoryView: View {
    @StateObject var historyViewModel: HistoryViewModel = HistoryViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                HistoryPicker(selectedHistoryMenu: $historyViewModel.selectedHistoryMenu)
                    .padding(.top, 8)
                
                HStack {
                    Button {
                        historyViewModel.changeWeek(type: .previous)
                    } label: {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.title)
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
                    }
                    .disabled(historyViewModel.isToday(date: Date()))
                }
                .padding([.horizontal, .top])
                
                ScrollView{
                    if historyViewModel.selectedHistoryMenu == .emergency {
                        HistoryEmergency(historyViewModel: historyViewModel)
                    } else if historyViewModel.selectedHistoryMenu == .heartRate {
                        HistoryHeartRate(historyViewModel: historyViewModel)
                    } else if historyViewModel.selectedHistoryMenu == .inactivity {
                        HistoryInactivity(historyViewModel: historyViewModel)
                    }
                }
                
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("History")
        }
    }
}

struct HistoryEmergency: View {
    @ObservedObject var historyViewModel: HistoryViewModel
    var body: some View {
        VStack {
            HistoryHeader()
            if (historyViewModel.loading == true) {
                ProgressView()
            } else {
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
                                HistoryCard(option: .fell, time: Date.unixToString(unix: fall.time, timeOption: .hour))
                                    .listRowSeparator(.hidden)
                            } else if let sos = emergencies[index] as? SOS {
                                HistoryCard(option: .pressed, time: Date.unixToString(unix: sos.time, timeOption: .hour))
                                    .listRowSeparator(.hidden)
                            }
                        }
                    }
                }
            }
        }
        .padding(.top, 8)
        .padding(.horizontal, 16)
    }
}

struct HistoryHeartRate: View {
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
                HistoryHeader()
                if (historyViewModel.loading == true) {
                    ProgressView()
                } else {
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
                                .cornerRadius(2)
                                
                                PointMark(x: .value("Date", $0.day, unit: .day), y: .value("Avg. Heart Rate", $0.avgHeartRate)
                                )
                                .cornerRadius(2)
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
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .chartLegend(.hidden)
                        .chartXSelection(value: $rawSelectedDate)
                        .chartXAxis {
                            AxisMarks(values: historyViewModel.inactivityData.map { $0.day }) { date in
                                AxisValueLabel(format: .dateTime.weekday(), horizontalSpacing: 10)
                            }
                        }
                        .frame(height: 200)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    
                    // Heart Rate Card Here
                }
            }
            .padding(.horizontal)
        }
    }
}

struct HistoryInactivity: View {
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
            HistoryHeader()
            if (historyViewModel.loading == true) {
                ProgressView()
            } else {
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
                            .cornerRadius(2)
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
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
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
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
            }
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
        }
        .padding(.top, 8)
        .padding(.horizontal, 16)
    }
}

struct HistoryPicker: View {
    @Binding var selectedHistoryMenu: HistoryMenu
    
    var body: some View {
        Picker("HistoryMenu", selection: $selectedHistoryMenu) {
            Text("Emergency").tag(HistoryMenu.emergency)
            Text("Heart Rate").tag(HistoryMenu.heartRate)
            Text("Inactivity").tag(HistoryMenu.inactivity)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
}

struct HistoryHeader: View {
    var body: some View {
        HStack{
            Text("Summary")
                .font(.title3)
                .bold()
            Spacer()
        }
    }
}

struct DetectedFallCard: View {
    @Binding var fallCount: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack{
                    Image(systemName: "figure.fall")
                        .font(.title3)
                    Text("Falls")
                }
                Text("\(fallCount)")
                    .font(.title)
                    .bold()
                    .padding(.top, 8)
            }
            
            Spacer()
        }
        .foregroundStyle(.white)
        .padding()
        .background(.accent)
        .cornerRadius(8)
    }
}

struct SOSCard: View {
    @Binding var sosCount: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading){
                HStack{
                    Image(systemName: "sos.circle.fill")
                        .font(.title3)
                    Text("SOS Button")
                }
                Text("\(sosCount)")
                    .font(.title)
                    .bold()
                    .padding(.top, 8)
            }
            
            Spacer()
        }
        .foregroundStyle(.white)
        .padding()
        .background(Color("secondary-orange"))
        .cornerRadius(8)
    }
}

struct HistoryData: View {
    var body: some View {
        VStack{
            HStack{
//                Text("21 Oct 2023")
//                    .bold()
//                    .font(.title3)
                Spacer()
            }
            HStack{
                Image(systemName: "figure.fall")
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.accent)
                    .cornerRadius(8.0)
                Text("Fell")
                    .padding(.leading, 8.0)
                Spacer()
                Group{
                    Image(systemName: "clock")
                    Text("13.00")
                }
                .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.white))
            .cornerRadius(8.0)
            HStack{
                Image(systemName: "sos.circle.fill")
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color("secondary-orange"))
                    .cornerRadius(8.0)
                Text("Pressed")
                    .padding(.leading, 8.0)
                Spacer()
                Group{
                    Image(systemName: "clock")
                    Text("13.00")
                }
                .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.white))
            .cornerRadius(8.0)
        }
    }
}

struct HistoryCard: View {
    var option: HistoryCardOption
    var time: String
    var finishedTime: String?
    
    var body: some View {
        HStack{
            Image(systemName: option == .fell ? "figure.fall" : option == .pressed ? "sos.circle.fill" : option == .idle ? "moon.fill" : "bolt.fill")
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(option == .fell || option == .idle ? .accent : Color("secondary-orange"))
                .cornerRadius(8.0)
            Text(option == .fell ? "Fell" : option == .pressed ? "Pressed" : option == .idle ? "Idle" : "Charging")
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
        .background(Color(.systemBackground))
        .cornerRadius(8.0)
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
}
