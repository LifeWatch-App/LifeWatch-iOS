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
                HistoryDatePicker(selectedStartDate: $historyViewModel.selectedStartDate, selectedEndDate: $historyViewModel.selectedEndDate)
                    .padding()
                ScrollView{
                    if historyViewModel.selectedHistoryMenu == .emergency {
                        HistoryEmergency(historyViewModel: historyViewModel)
                    } else if historyViewModel.selectedHistoryMenu == .inactivity {
                        HistoryInactivity(vm: historyViewModel)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .listStyle(.plain)
            .navigationTitle("History")
        }
    }
}

struct HistoryEmergency: View {
    @ObservedObject var historyViewModel: HistoryViewModel
    
    var body: some View {
        VStack {
            HistoryHeader()
            
            HStack{
                DetectedFallCard(fallCount: $historyViewModel.fallCount)
                SOSCard(sosCount: $historyViewModel.sosCount)
            }
            
            HStack{
                Text("21 Oct 2023")
                    .bold()
                    .font(.title3)
                Spacer()
            }
            .padding(.top, 8)
            
            HistoryCard(option: .fell)
                .listRowSeparator(.hidden)
            HistoryCard(option: .pressed)
                .listRowSeparator(.hidden)
        }
        .padding(.top, 8)
        .padding(.horizontal, 16)
    }
}

struct HistoryInactivity: View {
    @ObservedObject var vm: HistoryViewModel
    
    var body: some View {
        VStack {
            HistoryHeader()
            
            Chart(inactivityDummyData) {
                BarMark(x: .value("Date", $0.date), y: .value("Minutes", $0.value)
                )
                .foregroundStyle(by: .value("Type", $0.type))
                .cornerRadius(2)
            }
            .chartForegroundStyleScale(
                ["Idle": Color("Blue"), "Charging": Color("Orange")]
            )
            .frame(height: 240)
            
            HStack{
                Text("21 Oct 2023")
                    .bold()
                    .font(.title3)
                Spacer()
            }
            .padding(.top, 8)
            
            HistoryCard(option: .idle)
                .listRowSeparator(.hidden)
            HistoryCard(option: .charging)
                .listRowSeparator(.hidden)
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
            Text("Inactivity").tag(HistoryMenu.inactivity)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
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
            .font(.system(size: 18))
            Spacer()
            DatePicker(
                "End",
                selection: $selectedEndDate,
                displayedComponents: [.date]
            )
            .font(.system(size: 18))
        }
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
        .background(.blue)
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

struct HistoryCard: View {
    var option: HistoryCardOption
    
    var body: some View {
        HStack{
            Image(systemName: option == .fell ? "figure.fall" : option == .pressed ? "sos.circle.fill" : option == .idle ? "moon.fill" : "bolt.fill")
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(option == .fell || option == .idle ? .blue : .orange)
                .cornerRadius(8.0)
            Text(option == .fell ? "Fell" : option == .pressed ? "Pressed" : option == .idle ? "Idle" : "Charging")
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

#Preview {
    NavigationStack {
        HistoryView()
    }
}
