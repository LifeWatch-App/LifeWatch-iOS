//
//  MKMapRep.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 30/10/23.
//

import Foundation
import SwiftUI
import MapKit
import Combine
import Contacts


struct MKMapRep: UIViewRepresentable {
    @ObservedObject var mapVM: MapViewModel


    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        guard /*let mapRegion = context.coordinator.mapRegion, */let lastSeenLocation = context.coordinator.lastSeenLocation else { return mapView }

        let coordinateRegion = MKCoordinateRegion(center: lastSeenLocation, latitudinalMeters: 50, longitudinalMeters: 50)
        mapView.setRegion(coordinateRegion, animated: true)
        //            let circle = MKCircle(center: mapRegion.center, radius: 1000)
        //            mapView.setVisibleMapRect(circle.boundingMapRect, edgePadding: .init(top: 30, left: 50, bottom: 20, right: 50), animated: true)
        //
        //            mapView.addOverlay(circle)
        //
        //            let markerAnnotation = MarkerAnnotation(title: "Senior's Home Location", coordinate: mapRegion.center)
        //            let lastSeenAnnotation = MarkerAnnotation(title: "Last Seen location", coordinate: lastSeenLocation)
        //
        //            mapView.addAnnotations([markerAnnotation, lastSeenAnnotation])

        return mapView
    }

    func makeCoordinator() -> MapViewModel {
        return mapVM
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        let mapVM = context.coordinator

        DispatchQueue.main.async {
            if mapVM.recenter {
                zoomRecenterHomeLocation(mapView: uiView, context: context)
                context.coordinator.recenter = false
            }

            if mapVM.shouldSelect && mapVM.selectedPlacemark != nil {
                zoomLocation(mapView: uiView, context: context)
                context.coordinator.selectedPlacemark = nil
                context.coordinator.shouldSelect = false
            }

            mapVM.$lastSeenLocation
                .receive(on: DispatchQueue.main)
                .sink { newCoordinate in
                    self.updateLiveLocationAnnotation(mapView: uiView, context: context)
                }
                .store(in: &context.coordinator.cancellables)

            mapVM.$mapRegion
                .receive(on: DispatchQueue.main)
                .sink { newCoordinate in
                    self.updateHomeLocationAnnotation(mapView: uiView, context: context)
                    self.updateRegionCircle(mapView: uiView, context: context)
                }
                .store(in: &context.coordinator.cancellables)
        }
    }

    private func testLocation(context: Context, completion: @escaping (CLPlacemark?, Error?) -> Void) {
        if let lastLocation = context.coordinator.lastSeenLocation {
            let location = CLLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude)
            let geocoder = CLGeocoder()

            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completion(firstLocation, nil)
                } else {
                    completion(nil, error)
                }
            }

        } else {
            completion(nil, nil)
        }
    }

    private func updateLiveLocationAnnotation(mapView: MKMapView, context: Context) {
        for annotation in mapView.annotations {
            if annotation.title == "Last Seen Location" {
                mapView.removeAnnotation(annotation)
            }
        }
        guard let lastSeenLocation = context.coordinator.lastSeenLocation else { return }
        let coordinateRegion = MKCoordinateRegion(center: lastSeenLocation, latitudinalMeters: 50, longitudinalMeters: 50)
        let lastSeenAnnotation = MarkerAnnotation(title: "Last Seen Location", coordinate: lastSeenLocation)

        mapView.addAnnotation(lastSeenAnnotation)

        //        mapView.setRegion(coordinateRegion, animated: true)
    }

    private func updateHomeLocationAnnotation(mapView: MKMapView, context: Context) {
        for annotation in mapView.annotations {
            if annotation.title == "Senior's Home Location" {
                mapView.removeAnnotation(annotation)
            }
        }
        guard let setHomeLocation = context.coordinator.mapRegion else { return }
        let lastSeenAnnotation = MarkerAnnotation(title: "Senior's Home Location", coordinate: setHomeLocation.center)
        withAnimation {
            mapView.addAnnotation(lastSeenAnnotation)
        }
    }

    private func updateRegionCircle(mapView: MKMapView, context: Context) {
        for overlay in mapView.overlays {
            mapView.removeOverlay(overlay)
        }

        guard let mapRegionCenter = context.coordinator.mapRegion?.center else { return }
        let circle = MKCircle(center: mapRegionCenter, radius: 200)
        //        mapView.setVisibleMapRect(circle.boundingMapRect, edgePadding: .init(top: 30, left: 50, bottom: 20, right: 50), animated: true)
        mapView.addOverlay(circle)
    }

    private func zoomRecenterHomeLocation(mapView: MKMapView, context: Context) {
        guard let location = context.coordinator.mapRegion else {
            print("Print mapRegion not available")
            return
        }
        print("Zoom", location)
        mapView.setRegion(location, animated: true)
    }

    private func zoomLocation(mapView: MKMapView, context: Context) {
        guard let location = context.coordinator.selectedPlacemark else {
            print("Print mapRegion not available")
            return
        }

        //        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04))
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 50, longitudinalMeters: 50)
        mapView.setRegion(region, animated: true)
    }

    private func zoomOutRecenterLiveLocation(mapView: MKMapView, context: Context) {
        guard let location = context.coordinator.lastSeenLocation else {
            print("Print mapRegion not available")
            return
        }
        print("Zoom", location)
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 50, longitudinalMeters: 50)
        mapView.setRegion(region, animated: true)
    }

    typealias UIViewType = MKMapView
}

extension CLPlacemark {
    var formattedAddress: String? {
        guard let postalAddress = postalAddress else {
            return nil
        }
        let formatter = CNPostalAddressFormatter()
        let formattedString = formatter.string(from: postalAddress)
        let formattedAddressWithCommas = formattedString.replacingOccurrences(of: "\n", with: ", ")
        return formattedAddressWithCommas
    }
}
