import SwiftUI
import MapKit

struct MapTestView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var mapVM: MapViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            if mapVM.lastSeenLocation != nil && mapVM.mapRegion != nil {
                ZStack(alignment: .top) {
                    MKMapRep(mapVM: mapVM)
                        .ignoresSafeArea(edges: .top)

                    ZStack(alignment: .topLeading) {
                        Text("Set pin on a location")
                            .foregroundStyle(colorScheme == .light ? Color.black : Color.white)
                            .font(.headline)
                            .frame(maxWidth: UIScreen.main.bounds.width)
                            .padding()
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
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
                        .padding(.leading)
                    }
                }

                VStack(alignment: .trailing, spacing: 12) {
                    Button {
                        mapVM.homeSetMode.toggle()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "house.fill")
                                .font(.headline)
                            Text("Set Boundary")
                        }
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                    }
                    .padding(12)
                    .background(mapVM.homeSetMode ? Color.green : Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 100))
                    .padding(.trailing)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(mapVM.allLocations, id: \.self) { location in
                                VStack {
                                    HStack(spacing: 50) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            if location.locationName != "Unknown Address" && !(location.addressArray?.isEmpty ?? true) {
                                                Text(location.addressArray?[0] ?? "None")
                                                    .font(.title2)
                                                    .fontWeight(.semibold)
//                                                    .lineLimit(1)

                                                Text(location.addressArray?[1].trimmingCharacters(in: .whitespaces) ?? "None")
                                                    .font(.title3)
//                                                    .lineLimit(1)
                                            } else {
                                                Text("Address Not Found")
                                                    .font(.title3)
                                                    .fontWeight(.semibold)
//                                                    .lineLimit(1)
                                            }
                                        }

//                                        Spacer()
                                        Divider()
                                            .padding(.horizontal, 1)
                                            .background(.gray.opacity(0.2))

//                                        Spacer()
                                        VStack(spacing: 10) {
                                            if (location.latitude == mapVM.lastSeenLocation?.latitude ?? 0 && location.longitude == mapVM.lastSeenLocation?.longitude ?? 0) {
                                                Text("Last Seen Location")
                                                    .font(.headline)
                                            }
                                            HStack(spacing: 4) {
                                                Image(systemName: "clock")
                                                    .font(.title3)
                                                    .foregroundStyle(.secondary)

                                                if let createdAtTime = location.createdAt {
                                                    Text("\(Date.unixToTime(unix: createdAtTime))")
                                                        .font(.title3)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                        }
//                                        Spacer()
                                    }

                                }
                                .frame(maxHeight: 90)
                                .frame(width: UIScreen.main.bounds.width * 0.85)
//                                .frame(maxHeight: 70)
                                .padding(.vertical, 20)
                                .padding(.horizontal, 30)
                                .background(
                                    CardShape()
                                        .fill(colorScheme == .light ? Color.white : Color(.systemGray6))
                                        .padding(.top, 10)
                                )
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                    //Check if location within homeradius
                                        .fill(location.isOutside ?? false ? Color.red : .accent)
                                )
                                .padding(.vertical, 8)
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
                        .padding(.horizontal)
                    }
                    .scrollIndicators(.hidden)
                }
                .navigationBarTitleDisplayMode(.inline)

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
        .onAppear {
            resetMapState()
        }
    }

    private func resetMapState() {
        mapVM.is3DMap = false
        mapVM.shouldChangeMap = false
        mapVM.recenter = false
        mapVM.zoomOut = false
        mapVM.shouldSelect = false
        mapVM.homeSetMode = false
    }
}

