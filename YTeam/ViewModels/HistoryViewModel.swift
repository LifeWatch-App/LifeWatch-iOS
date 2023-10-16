//
//  HistoryViewModel.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 16/10/23.
//

import Foundation

class HistoryViewModel: ObservableObject {
    @Published var startDate: Date = (Calendar.current
        .date(byAdding: .day, value: -6, to: .now) ?? .now)
    @Published var endDate: Date = .now
    
    @Published var selectedStartDate: Date = Date()
    @Published var selectedEndDate: Date = Date()
    @Published var selectedHistoryMenu: HistoryMenu = .emergency
    
    @Published var fallCount: Int = 4
    @Published var sosCount: Int = 1
}

enum HistoryMenu: String, CaseIterable, Identifiable {
    case emergency, inactivity
    var id: Self { self }
}

enum HistoryCardOption: String, CaseIterable, Identifiable {
    case fell, pressed, idle, charging
    var id: Self { self }
}

struct ToyShape: Identifiable {
    var color: String
    var type: String
    var count: Double
    var id = UUID()
}
