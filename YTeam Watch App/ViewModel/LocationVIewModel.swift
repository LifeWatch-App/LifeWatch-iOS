//
//  LocationVIewModel.swift
//  YTeam Watch App
//
//  Created by Kevin Sander Utomo on 12/10/23.
//


import Foundation
import SwiftUI
import CoreLocation
import CoreMotion
import Combine

final class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastSeenLocation: CLLocation?
    @Published var setHomeLocation: CLLocation?
    private let locationManager = CLLocationManager()
    @Published var isSet: Bool = false
    @Published var isWithinRegion: Bool?
    @Published var userProfiles: [UserProfile] = []
    private var cancellables = Set<AnyCancellable>()
    private let service = DataService.shared


    override init() {
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 2
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
    }

    func requestPermission() {
        guard CLLocationManager.locationServicesEnabled() else {
            print("Location Services not available")
            return
        }
        locationManager.requestAlwaysAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if setHomeLocation == nil && isSet == true {
            setHomeLocation = locations.first
        }
        lastSeenLocation = locations.first
    }

    func observeLocation(coordinate: CLLocationCoordinate2D) {
        guard (setHomeLocation != nil) else {
            return
        }

        if isSet == true && lastSeenLocation != nil {
            isWithinRegion = checkLocationWithinHomeRadius(coordinate: coordinate) ?? false
        }
    }

    private func getHomeRadius() -> CLCircularRegion? {
        guard let setHomeLocation else { return nil }
        return CLCircularRegion(center: setHomeLocation.coordinate, radius: 60, identifier: "RegionMap")
    }

    private func checkLocationWithinHomeRadius(coordinate: CLLocationCoordinate2D) -> Bool? {
        guard let lastSeenLocation else { return nil }
        guard let region = getHomeRadius() else { return false }

        if region.contains(lastSeenLocation.coordinate) {
            return true
        } else {
            return false
        }
    }
}

