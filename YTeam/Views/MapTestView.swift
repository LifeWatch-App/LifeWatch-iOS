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
        ZStack {
            if let lastSeenLocation = mapVM.lastSeenLocation, let mapRegion = mapVM.mapRegion {
                VStack {
                    MKMapRep(mapVM: mapVM)
                        .ignoresSafeArea()

                    HStack {
                        Button("Recenter") {
                            mapVM.recenter = true
                        }

                        Button("Zoom Out") {
                            mapVM.zoomOut = true
                        }

                        Button("Test Placemark") {
                            mapVM.testGeoLocation = true
                        }
                    }
                }
            } else {
                Text("Not Available")
            }
        }
    }
}

#Preview {
    MapTestView()
}
