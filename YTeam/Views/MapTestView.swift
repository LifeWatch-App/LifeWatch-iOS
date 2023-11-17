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
            if mapVM.lastSeenLocation != nil && mapVM.mapRegion != nil {
                ZStack(alignment: .top){
                    MKMapRep(mapVM: mapVM)
                        .ignoresSafeArea(edges: .top)

                    ZStack(alignment: .topLeading) {

                        Spacer()
                        Text("Set pin on a location")
                            .font(.headline)
                            .frame(maxWidth: UIScreen.main.bounds.width)
                            .padding(20)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(20)
                            .opacity(mapVM.homeSetMode ? 1 : 0)


                        Button {
                            mapVM.is3DMap.toggle()
                            mapVM.shouldChangeMap = true
                        } label: {
                            Text("3D")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(mapVM.is3DMap ? Color.green : Color.blue)
                                .clipShape(Circle())
                                .opacity(mapVM.homeSetMode ? 0 : 1)
                        }
                        .padding(.leading, 20)
                        .padding(.top, 20)

                    }
                }


                VStack(alignment: .trailing, spacing: 20) {
                    Button {

                        mapVM.homeSetMode.toggle()

                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "house.fill")
                                .font(.headline)
                            Text("Set Boundary")
                        }
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                    }
                    .padding(10)
                    .background(mapVM.homeSetMode ? Color.green : Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    
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
                                        withAnimation {
                                            mapVM.shouldSelect = true
                                            mapVM.selectedPlacemark = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                .padding(.horizontal, 15)

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
