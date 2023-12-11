//
//  HistoryView.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 16/10/23.
//

import SwiftUI
import Charts
import Shimmer
import SkeletonUI

struct HistoryView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var historyViewModel: HistoryViewModel = HistoryViewModel()
    @State var loading = true
    
    @State var showChangeSenior = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {
                    VStack {
                        HistoryWeekPicker(historyViewModel: historyViewModel)
                        
                        ScrollView {
                            VStack {
                                HStack(alignment: .bottom) {
                                    Text("Symptoms")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                    
                                    if !historyViewModel.isLoading {
                                        NavigationLink {
                                            SymptomView(historyViewModel: historyViewModel)
                                        } label: {
                                            Text("Details")
                                                .font(.headline)
                                                .foregroundStyle(.accent)
                                            
                                        }
                                    }
                                }
                                
                                VStack(spacing: 16) {
                                    if !historyViewModel.isLoading {
                                        if historyViewModel.filteredSymptoms.count > 0 {
                                            ForEach(historyViewModel.filteredSymptoms.sorted {
                                                if $0.value != $1.value {
                                                    return $0.value > $1.value
                                                } else {
                                                    return $0.key < $1.key
                                                }
                                            }.prefix(3), id: \.key) { key, value in
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
                                        } else {
                                            HStack {
                                                Spacer()
                                                
                                                Text("No symptoms")
                                                    .font(.headline)
                                                
                                                Spacer()
                                            }
                                        }
                                    } else {
                                        ForEach(dummySymptomsSkeleton.sorted { $0.value > $1.value }.prefix(3), id: \.key) { key, value in
                                            HStack {
                                                Image("\(key)")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .skeleton(with: historyViewModel.isLoading,
                                                              size: CGSize(width: 35, height: 35),
                                                              animation: .none, appearance: colorScheme == .light ? .gradient() : .solid(color: .gray.opacity(0.2), background: .gray.opacity(0.2)),
                                                              shape: ShapeType.rounded(.radius(5, style: .circular)))
                                                    .shimmering(active: historyViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                                                    .frame(width: 35)
                                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                                
                                                Text("\(key)")
                                                    .font(.headline)
                                                    .padding(.leading, 4)
                                                    .skeleton(with: historyViewModel.isLoading,
                                                              animation: .none,
                                                              appearance: colorScheme == .light ? .gradient() : .solid(color: .gray.opacity(0.2), background: .gray.opacity(0.2)),
                                                              shape: ShapeType.rounded(.radius(5, style: .circular)), lines: 1,
                                                              scales: [0: 1])
                                                    .shimmering(active: historyViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                                            }
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
                                    
                                    if !historyViewModel.isLoading {
                                        NavigationLink {
                                            EmergencyView(historyViewModel: historyViewModel)
                                        } label: {
                                            Text("Details")
                                                .font(.headline)
                                                .foregroundStyle(.accent)
                                        }
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
                                            .skeleton(with: historyViewModel.isLoading,
                                                      size: CGSize(width: 35, height: 35),
                                                      animation: .none,
                                                      appearance: colorScheme == .light ? .gradient() : .solid(color: .gray.opacity(0.2), background: .gray.opacity(0.2)),
                                                      shape: ShapeType.rounded(.radius(5, style: .circular)))
                                            .shimmering(active: historyViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                        
                                        Text("Detected Falls")
                                            .font(.headline)
                                            .padding(.leading, 4)
                                            .skeleton(with: historyViewModel.isLoading,
                                                      animation: .none, appearance: colorScheme == .light ? .gradient() : .solid(color: .gray.opacity(0.2), background: .gray.opacity(0.2)),
                                                      shape: ShapeType.rounded(.radius(5, style: .circular)), lines: 1,
                                                      scales: [0: 1])
                                            .shimmering(active: historyViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                                        
                                        Spacer()
                                        
                                        if !historyViewModel.isLoading {
                                            Text("\(historyViewModel.fallsCount)")
                                                .font(.title3)
                                                .bold()
                                        }
                                    }
                                    Divider()
                                    
                                    HStack {
                                        Image(systemName: "sos.circle.fill")
                                            .resizable()
                                            .frame(width: 16, height: 16)
                                            .foregroundStyle(.white)
                                            .padding(8)
                                            .background(Color("emergency-pink"))
                                            .skeleton(with: historyViewModel.isLoading,
                                                      size: CGSize(width: 35, height: 35),
                                                      appearance: colorScheme == .light ? .gradient() : .solid(color: .gray.opacity(0.2), background: .gray.opacity(0.2)),
                                                      shape: ShapeType.rounded(.radius(5, style: .circular)))
                                            .shimmering(active: historyViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                        
                                        Text("SOS Button Pressed")
                                            .font(.headline)
                                            .padding(.leading, 4)
                                            .skeleton(with: historyViewModel.isLoading,
                                                      animation: .none, appearance: colorScheme == .light ? .gradient() : .solid(color: .gray.opacity(0.2), background: .gray.opacity(0.2)),
                                                      shape: ShapeType.rounded(.radius(5, style: .circular)), lines: 1,
                                                      scales: [0: 1])
                                            .shimmering(active: historyViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
                                        
                                        Spacer()
                                        
                                        if !historyViewModel.isLoading {
                                            Text("\(historyViewModel.sosCount)")
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
                                    Text("Heart Rate")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                    
                                    if !historyViewModel.isLoading {
                                        NavigationLink {
                                            HeartRateView(historyViewModel: historyViewModel)
                                        } label: {
                                            Text("Details")
                                                .font(.headline)
                                                .foregroundStyle(.accent)
                                        }
                                    }
                                }
                                
                                VStack {
                                    Chart {
                                        ForEach(historyViewModel.heartRateData) {
                                            LineMark(x: .value("Date", $0.day, unit: .day), y: .value("Avg. Heart Rate", $0.avgHeartRate)
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 2))
                                            
                                            //                                    PointMark(x: .value("Date", $0.day, unit: .day), y: .value("Avg. Heart Rate", $0.avgHeartRate)
                                            //                                    )
                                            //                                    .clipShape(RoundedRectangle(cornerRadius: 2))
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
                                .skeleton(with: historyViewModel.isLoading,
                                          size: CGSize(width: UIScreen.main.bounds.width - 70, height: 150),
                                          animation: .none, appearance: colorScheme == .light ? .gradient() : .solid(color: .gray.opacity(0.2), background: .gray.opacity(0.2)),
                                          shape: ShapeType.rounded(.radius(5, style: .circular)))
                                .shimmering(active: historyViewModel.isLoading, animation: .easeInOut(duration: 0.7).repeatCount(5, autoreverses: false), gradient: Gradient(colors: [.black.opacity(0.6), .black, .black.opacity(0.6)]))
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
                                    
                                    if !historyViewModel.isLoading {
                                        NavigationLink {
                                            InactivityView(historyViewModel: historyViewModel)
                                        } label: {
                                            Text("Details")
                                                .font(.headline)
                                                .foregroundStyle(.accent)
                                        }
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
                                .skeleton(with: historyViewModel.isLoading,
                                          size: CGSize(width: UIScreen.main.bounds.width - 70, height: 150),
                                          animation: .none, appearance: colorScheme == .light ? .gradient() : .solid(color: .gray.opacity(0.2), background: .gray.opacity(0.2)),
                                          shape: ShapeType.rounded(.radius(5, style: .circular)))
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
                }
            }
        }
        .onAppear {
            if historyViewModel.viewHasAppeared != true {
                historyViewModel.viewHasAppeared = true
            }
        }
        //        .onDisappear {
        //            for cancellable in historyViewModel.cancellables {
        //                cancellable.cancel()
        //            }
        //            historyViewModel.cancellables = []
        //        }
    }
}




#Preview {
    NavigationStack {
        HistoryView()
            .preferredColorScheme(.dark)
    }
}
