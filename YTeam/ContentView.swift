//
//  ContentView.swift
//  YTeam
//
//  Created by Yap Justin on 10/10/23.
//

import SwiftUI

enum HistoryMenu: String, CaseIterable, Identifiable {
    case fallDetection, idle
    var id: Self { self }
}

struct ToyShape: Identifiable {
    var color: String
    var type: String
    var count: Double
    var id = UUID()
}

struct ContentView: View {
    
    @State var startDate: Date = (Calendar.current
        .date(byAdding: .day, value: -6, to: .now) ?? .now)
    @State var endDate: Date = .now
    
    @State var selectedStartDate: Date = Date()
    @State var selectedEndDate: Date = Date()
    @State var selectedHistoryMenu: HistoryMenu = .fallDetection
    
    @State var fallCount: Int = 4
    @State var sosCount: Int = 1
    
    var body: some View {
        NavigationStack {
            VStack {
                HistoryPicker(selectedHistoryMenu: $selectedHistoryMenu)
                    .padding(.top, 8)
                HistoryDatePicker(selectedStartDate: $selectedStartDate, selectedEndDate: $selectedEndDate)
                    .padding(.top, 24)
                    .padding(.horizontal, 16)
                ScrollView{
                    VStack {
                        HistoryHeader()
                            .padding(.top, 24)
                        HStack{
                            DetectedFallCard(fallCount: $fallCount)
                            SOSCard(sosCount: $sosCount)
                        }
                        HistoryData()
                            .padding(.top, 8)
                            .listRowSeparator(.hidden)
                        HistoryData()
                            .padding(.top, 8)
                            .listRowSeparator(.hidden)
                    }
                    .padding(.horizontal, 16)
                    
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                }
            }
            .background(Color(.systemGroupedBackground))
            .listStyle(.plain)
            .navigationTitle("History")
            
        }
    }
}

struct HistoryPicker: View {
    @Binding var selectedHistoryMenu: HistoryMenu
    var body: some View {
        HStack{
            Picker("HistoryMenu", selection: $selectedHistoryMenu) {
                Text("Emergency").tag(HistoryMenu.fallDetection)
                Text("Inactivity").tag(HistoryMenu.idle)
            }
        }
        .frame(width: Screen.width)
        .pickerStyle(.segmented)
    }
}

struct HistoryDatePicker: View {
    @Binding var selectedStartDate: Date
    @Binding var selectedEndDate: Date
    var body: some View {
        HStack{
            DatePicker(
                "Start",
                selection: $selectedStartDate,
                displayedComponents: [.date]
            )
            .font(.system(size: 14))
            Spacer()
            DatePicker(
                "End",
                selection: $selectedEndDate,
                displayedComponents: [.date]
            )
            .font(.system(size: 14))
        }
    }
}

struct HistoryHeader: View {
    var body: some View {
        HStack{
            Text("Summary")
                .bold()
            Spacer()
        }
    }
}

struct DetectedFallCard: View {
    @Binding var fallCount: Int
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Image(systemName: "figure.fall")
                Text("Detected Falls")
            }
            Text("\(fallCount)")
                .font(.title)
                .bold()
                .padding(.top, 8)
        }
        .frame(width: Screen.width * 0.37)
        .foregroundStyle(.white)
        .padding()
        .background(.blue)
        .cornerRadius(8)
    }
}

struct SOSCard: View {
    @Binding var sosCount: Int
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Image(systemName: "sos.circle.fill")
                Text("SOS Button")
            }
            Text("\(sosCount)")
                .font(.title)
                .bold()
                .padding(.top, 8)
        }
        .frame(width: Screen.width * 0.37)
        .foregroundStyle(.white)
        .padding()
        .background(.orange)
        .cornerRadius(8)
    }
}

struct HistoryData: View {
    var body: some View {
        VStack{
            HStack{
                Text("21 Oct 2023")
                    .bold()
                    .font(.title3)
                Spacer()
            }
            HStack{
                Image(systemName: "figure.fall")
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.blue)
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
                    .background(.orange)
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

#Preview {
    ContentView()
}
