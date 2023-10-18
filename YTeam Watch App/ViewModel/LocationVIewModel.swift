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
    @Published var isSet: Bool = false
    @Published var isWithinRegion: Bool?
    @Published var userProfiles: [UserProfile] = []
    private var cancellables = Set<AnyCancellable>()
    private let service = DataService.shared
    
    private let locationManager: CLLocationManager
    
    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 30
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
    }
    
    func requestPermission() {
        locationManager.requestAlwaysAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if setHomeLocation == nil && isSet == true {
            setHomeLocation = locations.first
//            guard let latitude = setHomeLocation?.coordinate.latitude.magnitude, let longitude = setHomeLocation?.coordinate.longitude.magnitude else { return }
            
            let profile = UserProfile(userId: Description(stringValue: "124930"), userName: Description(stringValue: "Hermawan"))
            Task { try? await service.set(endPoint: MultipleEndPoints.userprofile, fields: profile, httpMethod: .post) }
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
    
    func getProfiles() async throws {
        let firebaseRecords: FirebaseRecords<UserProfile> = try await service.fetch(endPoint: MultipleEndPoints.userprofile, httpMethod: .get)
        let documents = firebaseRecords.documents
        let userProfiles: [UserProfile] = documents.compactMap { $0.fields }
        self.userProfiles = userProfiles
    }
}

