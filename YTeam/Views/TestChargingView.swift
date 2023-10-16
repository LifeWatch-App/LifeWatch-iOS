//
//  TestChargingView.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 16/10/23.
//

import Foundation

//
//  ContentView.swift
//  CobaApp
//
//  Created by Kevin Sander Utomo on 10/10/23.
//

import SwiftUI
import Charts

struct TestChargingView: View {
    @StateObject private var vm = WatchConnectorManager()

    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                Chart(vm.daysOfWeek, id: \.self) { day in
                    if vm.chartData.contains(where: { $0.date == day }) {
                        if let chart = vm.chartData.first(where: { $0.date == day }) {
                            BarMark(x: .value("Date", Date().dayMonthFormatter.string(from: chart.date)), y: .value("Charging Time", chart.chargingCount))
                        }
                    } else {
                        BarMark(x: .value("Date", Date().dayMonthFormatter.string(from: day)), y: .value("Charging Time", 0))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 300)
                .padding(20)

                HStack {
                    DatePicker("Start", selection: $vm.startDate, in: vm.startingDate...(vm.dateNowStart ?? .now), displayedComponents: [.date])
                    DatePicker("End", selection: $vm.endDate, in: vm.startingDate...vm.dateNowEnd, displayedComponents: [.date])
                }
                .padding(10)

                ForEach(vm.chargingRange, id: \.self) { range in
                    VStack {
                        Text(range.getFormattedStartEndTime(chargingRange: range))
                    }
                }

                Spacer()
            }
            .onChange(of: vm.endDate) { newValue in
                vm.getStartEndDate(date: newValue, isEnd: true)
                vm.getChargingRangesCounts()
                vm.getDaysOfWeek(fromDate: vm.startDate, endDate: newValue)
            }
            .onChange(of: vm.startDate) { newValue in
                vm.getStartEndDate(date: newValue, isEnd: false)
                vm.getChargingRangesCounts()
                vm.getDaysOfWeek(fromDate: newValue, endDate: vm.endDate)
            }
            .onChange(of: vm.chargingRange) { _ in
                vm.getChargingRangesCounts()
                vm.getDaysOfWeek(fromDate: vm.startDate, endDate: vm.endDate)
            }
        }
    }
}

#Preview {
    TestChargingView()
}
