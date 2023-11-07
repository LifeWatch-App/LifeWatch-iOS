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
    @Published var mapRegion2: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 39.23165776, longitude: -122.03069996), latitudinalMeters: 50, longitudinalMeters: 50)
    @Published var lastSeenLocation: CLLocationCoordinate2D?
    @Published var allLocations: [LiveLocation] = []
    @Published var recenter: Bool = false
    @Published var zoomOut: Bool = false
    @Published var shouldSelect: Bool = false
    @Published var selectedPlacemark: CLLocationCoordinate2D?
    var cancellables = Set<AnyCancellable>()
    private let service = LocationService()

    override init() {
        super.init()
        service.observeHomeLocationSpecific()
        service.observeLiveLocationSpecific()
        service.observeAllLiveLocation()
        setupSubscribers()
    }

    private func setupSubscribers() {
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
                withAnimation {
                    self.lastSeenLocation = self.loadLatestLiveLocation(documents: documentChanges)
                }
            }
            .store(in: &cancellables)

        service.$documentChangesAllLiveLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                guard let self = self else { return }
                print("Document Changes", documentChanges)
                withAnimation {
                    self.allLocations.insert(contentsOf: self.loadLiveLocations(documents: documentChanges), at: 0)
                }
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

        print("LiveLocs", liveLocations)
        return liveLocations
    }

    private func loadLatestHomeLocation(documents: [DocumentChange]) -> MKCoordinateRegion? {
        let document = documents.first?.document
        guard let longitude = document?.get("longitude") as? Double, let latitude = document?.get("latitude") as? Double else {
            print("Fail to get longitude and latitude")
            return nil
        }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        return MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    }
}

extension MapViewModel: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let boundCircle = MKCircleRenderer(overlay: overlay)
            boundCircle.strokeColor = UIColor.systemBlue
            boundCircle.lineWidth = 4
            boundCircle.fillColor = UIColor.systemBlue.withAlphaComponent(0.25)

            return boundCircle
        }

        return MKOverlayRenderer(overlay: overlay)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let _ = annotation as? MarkerAnnotation {
            let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            marker.markerTintColor = .systemBlue
            marker.isDraggable = false
            marker.isHidden = false

            switch annotation.title {
            case "Senior's Home Location":
                marker.glyphImage = UIImage(systemName: "house.fill")
            case "Last Seen Location":
                marker.glyphImage = UIImage(systemName: "figure.dance")
            default:
                break
            }

            return marker
        }

        return nil
    }
}

