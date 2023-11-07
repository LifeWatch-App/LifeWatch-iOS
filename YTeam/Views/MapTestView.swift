//
//  MapTestView.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 30/10/23.
//

import SwiftUI
import MapKit

struct MapTestView: View {
    @StateObject private var mapVM = MapViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            if let lastSeenLocation = mapVM.lastSeenLocation {

                MKMapRep(mapVM: mapVM)
                    .ignoresSafeArea()

//                                HStack {
//                                    Button("Recenter") {
//                                        mapVM.recenter = true
//                                    }
//                
//                                    Button("Zoom Out") {
//                                        mapVM.zoomOut = true
//                                    }
//                                }

                ScrollView(.horizontal) {
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
                                                .foregroundStyle(.black.opacity(0.8))
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

                                    HStack(spacing: 5) {
                                        Image(systemName: "clock")
                                            .font(.headline)
                                            .foregroundStyle(.gray)

                                        if let createdAtTime = location.createdAt {
                                            Text("\(Date.unixToTime(unix: createdAtTime))")
                                                .font(.headline)
                                                .foregroundStyle(.gray)
                                        }
                                    }
                                }
                            }
                            .frame(maxHeight: UIScreen.main.bounds.width * 0.15)
                            .padding(20)
                            .background(
                                CardShape()
                                    .fill(Color.white)
                                    .padding(.top, 10) // Add a blue border
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue) // Set the bottom background color to white
                            )
                            .onTapGesture {
                                if let latitude = location.latitude, let longitude = location.longitude {
                                    mapVM.shouldSelect = true
                                    mapVM.selectedPlacemark = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 15)
                .scrollIndicators(.hidden)

            } else {
                Text("Not Available")
            }
        }
    }
}

#Preview {
    MapTestView()
}
