//
//  MapViewModel.swift
//  YTeam
//
//  Created by Kevin Sander Utomo on 30/10/23.
//

import Foundation
import SwiftUI
import Firebase
import Combine
import MapKit


final class MapViewModel: NSObject, ObservableObject {
    @Published var mapRegion: MKCoordinateRegion?
    @Published var selectedUserId: String?
    @Published var lastSeenLocation: CLLocationCoordinate2D?
    @Published var allLocations: [LiveLocation] = []
    @Published var is3DMap = false
    @Published var shouldChangeMap = false
    @Published var recenter: Bool = false
    @Published var zoomOut: Bool = false
    @Published var shouldSelect: Bool = false
    @Published var homeSetMode: Bool = false
    @Published var selectedPlacemark: CLLocationCoordinate2D?
    var cancellables = Set<AnyCancellable>()
    private let service = LocationService.shared
    private let authService = AuthService.shared
    
    override init() {
        super.init()
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        
        authService.$selectedInviteId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] id in
                if self?.selectedUserId != id && id != nil {
                    self?.selectedUserId = id
                }
            }
            .store(in: &cancellables)
        
        $selectedUserId
            .combineLatest(authService.$userData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] id, userData in
                if id != nil && userData != nil {
                    print("Entered here man")
                    self?.allLocations = []
                    self?.recenter = false
                    self?.zoomOut = false
                    self?.shouldSelect = false
                    self?.homeSetMode = false
                    self?.shouldChangeMap = false
                    self?.is3DMap = false
                    self?.lastSeenLocation = nil
                    self?.mapRegion = nil
                    self?.service.observeHomeLocationSpecific()
                    self?.service.observeLiveLocationSpecific()
                    self?.service.observeAllLiveLocation()
                }
            }
            .store(in: &cancellables)
        
        
        service.$documentChangesHomeLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                print(documentChanges)
                guard let self = self else { return }
                withAnimation {
                    self.mapRegion = self.loadLatestHomeLocation(documents: documentChanges)
                }
            }
            .store(in: &cancellables)
        
        service.$documentChangesLiveLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                guard let self = self else { return }
                self.lastSeenLocation = self.loadLatestLiveLocation(documents: documentChanges)
            }
            .store(in: &cancellables)
        
        service.$documentChangesAllLiveLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                guard let self = self else { return }
                print("Document Changes", documentChanges)
                self.allLocations.insert(contentsOf: self.loadLiveLocations(documents: documentChanges), at: 0)
            }
            .store(in: &cancellables)
    }
    
    private func loadLatestLiveLocation(documents: [DocumentChange]) -> CLLocationCoordinate2D? {
        let document = documents.first?.document
        guard let longitude = document?.get("longitude") as? Double, let latitude = document?.get("latitude") as? Double else {
            print("Fail to get longitude and latitude")
            return nil
        }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        return coordinate
    }
    
    private func loadLiveLocations(documents: [DocumentChange]) -> [LiveLocation] {
        var liveLocations: [LiveLocation] = []
        
        for document in documents {
            guard var documentData = try? document.document.data(as: LiveLocation.self) else {
                print("Unable to decode to LiveLocation")
                return []
            }
            documentData.addressArray = documentData.locationName?.components(separatedBy: ",") ?? []
            liveLocations.append(documentData)
        }
        return liveLocations
    }
    
    @objc func getCoordinatePressOnMap(sender: UITapGestureRecognizer) {
        guard let mapView = sender.view as? MKMapView else {
            print("Error: Unable to get mapView from sender")
            return
        }
        
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
        
        if homeSetMode {
            Task { try? await service.setHomeLocation(location: locationCoordinate) }
            homeSetMode = false
        }
    }
    
    private func loadLatestHomeLocation(documents: [DocumentChange]) -> MKCoordinateRegion? {
        let document = documents.first?.document
        guard let longitude = document?.get("longitude") as? Double, let latitude = document?.get("latitude") as? Double else {
            print("Fail to get longitude and latitude")
            return nil
        }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        return MKCoordinateRegion(center: coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
    }
    
    func isCoordinate(_ coordinate: CLLocationCoordinate2D, withinRegion region: MKCoordinateRegion) -> Bool {
        let minLat = region.center.latitude - region.span.latitudeDelta / 2.0
        let maxLat = region.center.latitude + region.span.latitudeDelta / 2.0
        let minLon = region.center.longitude - region.span.longitudeDelta / 2.0
        let maxLon = region.center.longitude + region.span.longitudeDelta / 2.0
        
        return (minLat...maxLat).contains(coordinate.latitude) && (minLon...maxLon).contains(coordinate.longitude)
    }
}

extension MapViewModel: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let boundCircle = MKCircleRenderer(overlay: overlay)
            if let lastSeenLocation = lastSeenLocation, let homeLocation = mapRegion {
                if isCoordinate(lastSeenLocation, withinRegion: homeLocation) {
                    boundCircle.strokeColor = UIColor.systemBlue
                    boundCircle.lineWidth = 4
                    boundCircle.fillColor = UIColor.systemBlue.withAlphaComponent(0.25)
                } else {
                    boundCircle.strokeColor = UIColor.systemRed
                    boundCircle.lineWidth = 4
                    boundCircle.fillColor = UIColor.systemRed.withAlphaComponent(0.25)
                }
            }
            return boundCircle
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let _ = annotation as? MarkerAnnotation {
            let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            marker.isDraggable = false
            marker.isHidden = false
            
            switch annotation.title {
            case "Senior's Home Location":
                marker.glyphImage = UIImage(systemName: "house.fill")
                marker.markerTintColor = .systemBlue
            case "Last Seen Location":
                marker.glyphImage = UIImage(systemName: "figure.dance")
                if let lastSeenLocation = lastSeenLocation, let homeLocation = mapRegion {
                    if isCoordinate(lastSeenLocation, withinRegion: homeLocation) {
                        marker.markerTintColor = .systemBlue
                    } else {
                        marker.markerTintColor = .systemRed
                    }
                }
            default:
                break
            }
            
            return marker
        }
        
        return nil
    }
    
}

