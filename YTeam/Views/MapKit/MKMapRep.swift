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
        
        guard let lastSeenLocation = context.coordinator.lastSeenLocation else { return mapView }
        
        let coordinateRegion = MKCoordinateRegion(center: lastSeenLocation, latitudinalMeters: 50, longitudinalMeters: 50)
        mapView.setRegion(coordinateRegion, animated: true)
        let gestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.getCoordinatePressOnMap(sender:)))
        mapView.addGestureRecognizer(gestureRecognizer)
        mapView.mapType = .standard
        return mapView
    }
    
    
    func makeCoordinator() -> MapViewModel {
        return mapVM
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let coordinator = context.coordinator
        
        if coordinator.shouldSelect, coordinator.selectedPlacemark != nil {
            zoomLocation(mapView: uiView, context: context)
            DispatchQueue.main.async {
                coordinator.shouldSelect = false
            }
        }
        
        if let mapRegion = coordinator.mapRegion {
            Task {
                updateHomeLocationAnnotation(mapView: uiView, location: mapRegion.center, context: context)
                if let lastSeenLocation = context.coordinator.lastSeenLocation, let homeLocation = context.coordinator.mapRegion {
                    try await LocationService.shared.updateLatestLocationSpecificOutside(isOutside: !isCoordinate(lastSeenLocation, withinRegion: homeLocation))
                    updateRegionCircle(mapView: uiView, location: mapRegion.center)
                }
            }
        }
        
        if let lastSeenLocation = coordinator.lastSeenLocation {
            updateLiveLocationAnnotation(mapView: uiView, location: lastSeenLocation)
            updateRegionCircle(mapView: uiView, location: context.coordinator.mapRegion!.center)
        }
        
        if coordinator.shouldChangeMap {
            changeView(mapView: uiView, context: context)
            DispatchQueue.main.async {
                coordinator.shouldChangeMap = false
            }
        }
    }
    
    func isCoordinate(_ coordinate: CLLocationCoordinate2D, withinRegion region: MKCoordinateRegion) -> Bool {
        let minLat = region.center.latitude - region.span.latitudeDelta / 2.0
        let maxLat = region.center.latitude + region.span.latitudeDelta / 2.0
        let minLon = region.center.longitude - region.span.longitudeDelta / 2.0
        let maxLon = region.center.longitude + region.span.longitudeDelta / 2.0
        
        return (minLat...maxLat).contains(coordinate.latitude) && (minLon...maxLon).contains(coordinate.longitude)
    }
    
    private func changeView(mapView: MKMapView, context: Context) {
        if context.coordinator.selectedPlacemark != nil {
            guard let lastSeenLocation = context.coordinator.selectedPlacemark else { return }
            if context.coordinator.is3DMap {
                let camera = MKMapCamera()
                camera.centerCoordinate = lastSeenLocation
                camera.pitch = 80
                camera.altitude = 100
                camera.heading = 45.0
                mapView.setCamera(camera, animated: true)
            } else {
                let coordinateRegion = MKCoordinateRegion(center: lastSeenLocation, latitudinalMeters: 50, longitudinalMeters: 50)
                mapView.setRegion(coordinateRegion, animated: true)
            }
        } else {
            guard let lastSeenLocation = context.coordinator.lastSeenLocation else { return }
            if context.coordinator.is3DMap {
                let camera = MKMapCamera()
                camera.centerCoordinate = lastSeenLocation
                camera.pitch = 80
                camera.altitude = 100
                camera.heading = 45.0
                mapView.setCamera(camera, animated: true)
            } else {
                let coordinateRegion = MKCoordinateRegion(center: lastSeenLocation, latitudinalMeters: 50, longitudinalMeters: 50)
                mapView.setRegion(coordinateRegion, animated: true)
            }
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
    
    private func updateLiveLocationAnnotation(mapView: MKMapView, location: CLLocationCoordinate2D) {
        let annotation = mapView.annotations.filter { $0.title == "Last Seen Location" }.first
        
        if annotation == nil {
            let lastSeenAnnotation = MarkerAnnotation(title: "Last Seen Location", coordinate: location)
            mapView.addAnnotation(lastSeenAnnotation)
        } else if annotation?.coordinate.latitude != location.latitude && annotation?.coordinate.longitude != location.longitude {
            removeAnnotations(title: "Last Seen Location", mapView: mapView)
            let lastSeenAnnotation = MarkerAnnotation(title: "Last Seen Location", coordinate: location)
            mapView.addAnnotation(lastSeenAnnotation)
        }
    }
    
    private func updateLiveLocationAnnotationFromHomeChange(mapView: MKMapView, location: CLLocationCoordinate2D) {
        let annotation = mapView.annotations.filter { $0.title == "Last Seen Location" }.first
        
        if annotation == nil {
            let lastSeenAnnotation = MarkerAnnotation(title: "Last Seen Location", coordinate: location)
            mapView.addAnnotation(lastSeenAnnotation)
        } else if annotation?.coordinate.latitude == location.latitude && annotation?.coordinate.longitude == location.longitude {
            removeAnnotations(title: "Last Seen Location", mapView: mapView)
            let lastSeenAnnotation = MarkerAnnotation(title: "Last Seen Location", coordinate: location)
            mapView.addAnnotation(lastSeenAnnotation)
        } else if annotation?.coordinate.latitude != location.latitude && annotation?.coordinate.longitude != location.longitude {
            removeAnnotations(title: "Last Seen Location", mapView: mapView)
            let lastSeenAnnotation = MarkerAnnotation(title: "Last Seen Location", coordinate: location)
            mapView.addAnnotation(lastSeenAnnotation)
        }
    }
    
    private func updateHomeLocationAnnotation(mapView: MKMapView, location: CLLocationCoordinate2D, context: Context) {
        let annotation = mapView.annotations.filter { $0.title == "Senior's Home Location" }.first
        guard let lastSeenLocation = context.coordinator.lastSeenLocation else { return }
        if annotation == nil {
            let homeLocationAnnotation = MarkerAnnotation(title: "Senior's Home Location", coordinate: location)
            mapView.addAnnotation(homeLocationAnnotation)
        } else if annotation?.coordinate.latitude != location.latitude && annotation?.coordinate.longitude != location.longitude {
            removeAnnotations(title: "Senior's Home Location", mapView: mapView)
            let homeLocationAnnotation = MarkerAnnotation(title: "Senior's Home Location", coordinate: location)
            mapView.addAnnotation(homeLocationAnnotation)
            updateLiveLocationAnnotationFromHomeChange(mapView: mapView, location: lastSeenLocation)
        }
    }
    
    private func updateRegionCircle(mapView: MKMapView, location: CLLocationCoordinate2D) {
        removeOverlays(mapView: mapView)
        let circle = MKCircle(center: location, radius: 200)
        mapView.addOverlay(circle)
    }
    
    private func removeAnnotations(title: String, mapView: MKMapView) {
        let annotations = mapView.annotations.filter { $0.title == title }
        mapView.removeAnnotations(annotations)
    }
    
    private func removeOverlays(mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
    }
    
    
    
    private func zoomRecenterHomeLocation(mapView: MKMapView, context: Context) {
        guard let location = context.coordinator.mapRegion else {
            print("Print mapRegion not available")
            return
        }
        mapView.setRegion(location, animated: true)
    }
    
    private func zoomLocation(mapView: MKMapView, context: Context) {
        guard let location = context.coordinator.selectedPlacemark else {
            print("Print mapRegion not available")
            return
        }
        
        if context.coordinator.is3DMap == false {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 50, longitudinalMeters: 50)
            mapView.setRegion(region, animated: true)
        } else {
            let camera = MKMapCamera()
            camera.centerCoordinate = location
            camera.pitch = 80
            camera.altitude = 100
            camera.heading = 45.0
            mapView.setCamera(camera, animated: true)
        }
    }
    
    private func zoomOutRecenterLiveLocation(mapView: MKMapView, context: Context) {
        guard let location = context.coordinator.lastSeenLocation else {
            print("Print mapRegion not available")
            return
        }
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
