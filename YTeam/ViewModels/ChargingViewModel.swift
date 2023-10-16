//
//  ChargingViewModel.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 16/10/23.
//
import Foundation
import SwiftUI
import WatchConnectivity

final class WatchConnectorManager: NSObject, WCSessionDelegate, ObservableObject {
    @Published var startDate: Date = (Calendar.current.date(byAdding: .day, value: -6, to: .now) ?? .now)
    @Published var endDate: Date = .now
    @Published private(set) var chargingRange: [ChargingRange] = []
    @Published private(set) var daysOfWeek: [Date] = []
    @Published private(set) var chartData: [ChartData] = []
    let startingDate: Date = Calendar.current.date(from: DateComponents(year: 2023)) ?? .now
    let dateNowStart = Calendar.current.date(byAdding: .day, value: -6, to: .now)
    let dateNowEnd = Date.now
    var session: WCSession

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
        getChargingRangesCounts()
        getDaysOfWeek(fromDate: startDate, endDate: endDate)
    }

    func getDaysOfWeek(fromDate: Date, endDate: Date) {
        withAnimation {
            daysOfWeek = Date.dates(from: fromDate.strippedDate, to: endDate.strippedDate)
        }
    }

    func getStartEndDate(date: Date, isEnd: Bool) {
        if isEnd {
            guard let dateNowStart, let tempDate = Calendar.current.date(byAdding: .day, value: -6, to: date) else { return }
            if !(tempDate > dateNowStart) && !(tempDate < startingDate) && !(date < startingDate) {
                startDate = Calendar.current.date(byAdding: .day, value: -6, to: date) ?? .now
            }
        } else {
            guard let tempDate = Calendar.current.date(byAdding: .day, value: 6, to: date) else { return }
            if !(tempDate > dateNowEnd) && !(tempDate < startingDate) && !(date < startingDate) {
                endDate = Calendar.current.date(byAdding: .day, value: 6, to: date) ?? .now
            }
        }
    }


    func getChargingRangesCounts() {
        var tempArray: [ChartData] = []
        for range in chargingRange {
            if let index = tempArray.firstIndex(where: { $0.date.strippedDate == range.endCharging?.strippedDate }) {
                withAnimation {
                    tempArray[index].chargingCount += 1
                }
            } else {
                withAnimation {
                    tempArray.append(ChartData(date: range.endCharging?.strippedDate ?? .now))
                }
            }
        }

        withAnimation {
            chartData = tempArray.sorted(by: { $0.date < $1.date })
        }
    }


    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let messagingHistoryEncapsulator = message["charging_history"] {
                guard let messagingHistory = try? JSONDecoder().decode([ChargingRange].self, from: messagingHistoryEncapsulator as! Data) else {
                    print("Failed to decode the data")
                    return
                }
                self.chargingRange = messagingHistory
            }
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print(session.activationState.rawValue)
    }

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
}

