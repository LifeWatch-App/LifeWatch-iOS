//
//  MapTestView.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 30/10/23.
//

import SwiftUI
import MapKit

struct MapTestView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var mapVM = MapViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            if mapVM.lastSeenLocation != nil && mapVM.mapRegion != nil {

                MKMapRep(mapVM: mapVM)
                    .ignoresSafeArea()

                VStack(alignment: .trailing, spacing: 12) {
                    Button {
                        mapVM.recenter = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "house.fill")
                                .font(.headline)
                            Text("Re-center")
                        }
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                    }
                    .padding(12)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 100))
                    .padding(.trailing)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(mapVM.allLocations, id: \.self) { location in
                                VStack {
                                    HStack(spacing: 20) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            if location.locationName != "Unknown Address" && !(location.addressArray?.isEmpty ?? true) {
                                                Text(location.addressArray?[0] ?? "None")
                                                    .font(.title3)
                                                    .fontWeight(.semibold)
                                                    .lineLimit(1)

                                                Text(location.addressArray?[1].trimmingCharacters(in: .whitespaces) ?? "None")
                                                    .font(.body)
                                                    .lineLimit(1)
                                            } else {
                                                Text("Address Not Found")
                                                    .font(.title3)
                                                    .fontWeight(.semibold)
                                                    .lineLimit(1)
                                            }
                                        }

                                        Divider()
                                            .padding(.horizontal, 1)
                                            .background(.gray.opacity(0.2))

                                        HStack(spacing: 4) {
                                            Image(systemName: "clock")
                                                .font(.headline)
                                                .foregroundStyle(.secondary)

                                            if let createdAtTime = location.createdAt {
                                                Text("\(Date.unixToTime(unix: createdAtTime))")
                                                    .font(.headline)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                    }
                                }
                                .frame(maxHeight: 70)
                                .padding(20)
                                .background(
                                    CardShape()
                                        .fill(colorScheme == .light ? Color.white : Color(.systemGray6))
                                        .padding(.top, 10) // Add a blue border
                                )
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.accent) // Set the bottom background color to white
                                )
                                .padding(.top, 8)
                                .onTapGesture {
                                    if let latitude = location.latitude, let longitude = location.longitude {
                                        mapVM.shouldSelect = true
                                        mapVM.selectedPlacemark = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .scrollIndicators(.hidden)
                }

            } else if mapVM.mapRegion == nil {
                ContentUnavailableView {
                    Label("Home Location not Available", systemImage: "location.fill")
                } description: {
                    Text("Ask your senior to set their home location")
                }
                .background(Color(.systemGroupedBackground))
            } else {
                ContentUnavailableView {
                    Label("Location not Available", systemImage: "location.fill")
                } description: {
                    Text("Ask your senior to turn on their location.")
                }
                .background(Color(.systemGroupedBackground))
            }
        }
    }
}

#Preview {
    MapTestView()
}
