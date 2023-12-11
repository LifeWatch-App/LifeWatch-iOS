import SwiftUI
import MapKit

struct MapTestView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var mapVM: MapViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            if mapVM.lastSeenLocation != nil {
                ZStack(alignment: .topLeading) {
                    MKMapRep(mapVM: mapVM)
                        .ignoresSafeArea(edges: .top)

                    VStack(alignment: .leading){
                        if mapVM.homeSetMode {
                            VStack {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(
                                            Color.black
                                        )

                                    TextField("Search Location...", text: $mapVM.searchText)
                                    //                                .foregroundColor(Color.theme.accent)
                                        .submitLabel(.search)
                                        .autocorrectionDisabled()
                                        .overlay(
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.title2)
                                                .padding()
                                                .offset(x: 10)
                                                .foregroundColor(Color.blue)
                                                .opacity(mapVM.searchText.isEmpty ? 0 : 1)
                                                .onTapGesture {
                                                    UIApplication.shared.endEditing()
                                                    mapVM.searchText = ""
                                                    mapVM.locationSearchItems = []
                                                    mapVM.shouldNavigateLocationFromSearch = false
                                                }
                                            , alignment: .trailing
                                        )
                                }
                                .font(.headline)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.white)
                                )
                                .padding(.horizontal)
                                .padding(.top, 10)


                                if !mapVM.locationSearchItems.isEmpty && !mapVM.searchText.isEmpty {
                                    ScrollView {
                                        VStack(spacing: 15) {
                                            ForEach(mapVM.locationSearchItems) { location in
                                                VStack(alignment: .leading, spacing: 10) {
                                                    Text(location.place.name ?? "No Name")
                                                        .font(.title3)
                                                        .fontWeight(.bold)

                                                    Text(location.place.formattedAddress ?? "None")
                                                        .font(.headline)
                                                        .fontWeight(.regular)
                                                        .foregroundStyle(Color.secondary)
                                                    if mapVM.locationSearchItems.count > 1 {
                                                        Divider()
                                                    }
                                                }
                                                .onTapGesture {
                                                    withAnimation {
                                                        mapVM.shouldNavigateLocationFromSearch = true
                                                        mapVM.selectedSearchPlacemark = location.place.location?.coordinate
                                                        UIApplication.shared.endEditing()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: mapVM.locationSearchItems.count > 1 ? UIScreen.main.bounds.height * 0.20 : UIScreen.main.bounds.height * 0.08, alignment: .leading)
                                    .padding(15)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .padding(.horizontal)
//                                    .animation(.easeInOut, value: mapVM.locationSearchItems)
//                                    .animation(.easeInOut, value: mapVM.searchText)
                                }
                            }
                        } else {
                            Text("")
                                .opacity(0)
                        }

                        Button {
                            mapVM.is3DMap.toggle()
                            mapVM.shouldChangeMap = true
                        } label: {
                            Text("3D")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(10)
                                .background(mapVM.is3DMap ? Color("secondary-green") : Color.blue)
                                .clipShape(Circle())
                                .opacity(mapVM.homeSetMode ? 0 : 1)
                        }
                        .padding(.leading)
                        .padding(.top)
                    }
                }

                VStack(alignment: .trailing, spacing: 12) {
                    if mapVM.homeSetMode {
                        HStack {
                            Spacer()

                            Image(systemName: "checkmark")
                            Text("Done")

                            Spacer()
                        }
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .padding(12)
                        .background(.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.vertical, 30)
                        .padding(.horizontal)
                        .onTapGesture {
                            mapVM.homeSetMode = false
                            mapVM.searchText = ""
                            mapVM.locationSearchItems = []
                            mapVM.shouldNavigateLocationFromSearch = false
                        }

                    } else {
                        Button {
                            mapVM.homeSetMode = true
                            mapVM.searchText = ""
                            mapVM.locationSearchItems = []
                            mapVM.shouldNavigateLocationFromSearch = false
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "house.fill")
                                    .font(.headline)

                                Text("Set Boundary")
                            }
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                        }
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                    }

                    if !mapVM.homeSetMode {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(mapVM.allLocations, id: \.self) { location in
                                    VStack {
                                        HStack(/*spacing: location.addressArray?[0].count ?? 0 > 20 ? 30 : 70*/) {
                                            VStack(alignment: .leading, spacing: 8) {
                                                if location.locationName != "Unknown Address" && !(location.addressArray?.isEmpty ?? true) {
                                                    Text(location.addressArray?[0] ?? "None")
                                                        .font(.headline)
                                                        .fontWeight(.semibold)
                                                    //                                                    .lineLimit(1)

                                                    Text(location.addressArray?[1].trimmingCharacters(in: .whitespaces) ?? "None")
                                                        .font(.headline)
                                                        .foregroundStyle(.black.opacity(0.4))
                                                        .fontWeight(.medium)
                                                    //                                                    .lineLimit(1)
                                                } else {
                                                    Text("Address Not Found")
                                                        .font(.headline)
                                                        .fontWeight(.semibold)
                                                    //                                                    .lineLimit(1)
                                                }
                                            }
                                            Spacer()

                                            //                                        Spacer()
                                            Divider()
                                                .padding(.horizontal, 1)
                                                .background(.gray.opacity(0.2))
                                                .padding(.horizontal, 4)

                                            //                                        Spacer()
                                            VStack(alignment: .leading, spacing: 10) {
                                                if (location.latitude == mapVM.lastSeenLocation?.latitude ?? 0 && location.longitude == mapVM.lastSeenLocation?.longitude ?? 0) {
                                                    Text("Last Seen")
                                                        .font(.headline)
                                                }
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
                                            Spacer()
                                        }

                                    }
                                    .frame(maxHeight: 90)
                                    .frame(width: UIScreen.main.bounds.width * 0.75)
                                    //                                .frame(maxHeight: 70)
                                    .padding(.vertical, 20)
                                    .padding(.horizontal, 20)
                                    .background(
                                        CardShape()
                                            .fill(colorScheme == .light ? Color.white : Color(.systemGray6))
                                            .padding(.top, 10)
                                    )
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                        //Check if location within homeradius
                                            .fill(location.isOutside ?? false ? Color("emergency-pink") : .accent)
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
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .navigationBarTitleDisplayMode(.inline)

//            } else if mapVM.mapRegion == nil {
//                ContentUnavailableView {
//                    Label("Home Location Not Available", systemImage: "location.fill")
//                } description: {
//                    Text("Ask your senior to set their home location")
//                }
//                .background(Color(.systemGroupedBackground))
            } else {
                ContentUnavailableView {
                    Label("Location Not Available", systemImage: "location.fill")
                } description: {
                    Text("Ask your senior to turn on their location.")
                }
                .background(Color(.systemGroupedBackground))
            }
        }
        .navigationTitle(mapVM.homeSetMode ? "Set pin on a location" : "")
        .onDisappear {
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

extension UIApplication {
    /*
     It will dismiss the keyboard
     */
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

