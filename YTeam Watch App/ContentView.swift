//
//  ContentView.swift
//  YTeam Watch App
//
//  Created by Yap Justin on 10/10/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var locationViewModel = LocationViewModel()

    var body: some View {
        switch locationViewModel.authorizationStatus {
        case .notDetermined:
            AnyView(RequestLocationView())
                .environmentObject(locationViewModel)
        case .restricted:
            ErrorView(errorText: "Location use is restricted.")
        case .denied:
            ErrorView(errorText: "The app does not have location permissions. Please enable them in settings.")
        case .authorizedAlways, .authorizedWhenInUse:
            TrackingView()
                .environmentObject(locationViewModel)
        default:
            Text("Unexpected status")
        }
    }
}

struct RequestLocationView: View {
    @EnvironmentObject var locationViewModel: LocationViewModel

    var body: some View {
        VStack {
            Button(action: {
                locationViewModel.requestPermission()
            }, label: {
                Label("Allow tracking", systemImage: "location")
            })
            .padding(10)
            .foregroundColor(.white)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            Text("We need your permission to track you.")
                .foregroundColor(.gray)
                .font(.caption)
        }
    }
}

struct ErrorView: View {
    var errorText: String

    var body: some View {
        VStack {
            Image(systemName: "xmark.octagon")
                .resizable()
                .frame(width: 100, height: 100, alignment: .center)
            Text(errorText)
        }
        .padding()
        .foregroundColor(.white)
        .background(Color.red)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct TrackingView: View {
    @EnvironmentObject var locationViewModel: LocationViewModel
    @State var showAlert: Bool = false

    var body: some View {
        VStack {
            VStack(spacing: 15) {
                VStack {
                    PairView(
                        leftText: "Latitude:",
                        rightText: String(locationViewModel.lastSeenLocation?.coordinate.latitude ?? 0)
                    )
                    PairView(
                        leftText: "Longitude:",
                        rightText: String(locationViewModel.lastSeenLocation?.coordinate.latitude ?? 0)
                    )
                }

                if locationViewModel.isSet && locationViewModel.lastSeenLocation != nil {
                    if let within = locationViewModel.isWithinRegion {
                        if within {
                            Text("Within radius")
                        } else {
                            Text("Not within radius")
                        }
                    }
                } else {
                    VStack {
                        Button("Set Current Location as Home") {
                            locationViewModel.isSet = true
                        }
                    }
                }
                
                ForEach(locationViewModel.userProfiles, id: \.self) { profile in
                    HStack {
                        Text(profile.userName?.stringValue ?? "No Name")
                        Text(profile.userId?.stringValue ?? "No id")
                    }
                }
            }
            .padding()
        }
        .onAppear {
            Task { try? await locationViewModel.getProfiles() }
        }
        .onChange(of: locationViewModel.lastSeenLocation) { newValue in
            if let newValue {
                locationViewModel.observeLocation(coordinate: newValue.coordinate)
            }
        }
        .onChange(of: locationViewModel.isWithinRegion) { newValue in
            if locationViewModel.isSet {
                if let newValue {
                    if !newValue {
                        showAlert.toggle()
                        WKInterfaceDevice.current().play(.failure)
                    }
                }
            }
        }
        .alert("You have exited the region", isPresented: $showAlert, actions: {
            Button("OK", role: .cancel) {
                showAlert = false
            }
        })
    }
}

struct PairView: View {
    let leftText: String
    let rightText: String

    var body: some View {
        HStack {
            Text(leftText)
            Spacer()
            Text(rightText)
        }
    }
}

