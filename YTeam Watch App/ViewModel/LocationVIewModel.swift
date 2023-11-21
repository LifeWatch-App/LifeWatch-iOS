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
    @Published var radius: CLLocationDistance?
    @Published var shouldSet = false
    @Published var currentPlacemark: CLPlacemark?
    @Published var isWithinRegion = true
    private var isFirstTimeUpdateLocation = true
    private var cancellables = Set<AnyCancellable>()
    private var locationUpdateTimer: Timer?
    private let service = DataService.shared
    private let locationManager = CLLocationManager()


    override init() {
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 200
        locationManager.allowsBackgroundLocationUpdates = true
        setupSubcribers()
        locationManager.startUpdatingLocation()
    }

    func setupSubcribers() {
        $lastSeenLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] lastSeenLocation in
                guard let lastSeenLocation else { return }
                guard let userIData = UserDefaults.standard.object(forKey: "user-auth") else { return }
                guard let userID = try? JSONDecoder().decode(UserRecord.self, from: userIData as! Data).userID else { return }
                self?.fetchHomeLocation(completion: { coordinate in
                    guard let coordinate else { return }
                    self?.setHomeLocation = coordinate
                    self?.testLocationCompletion(coordinate: lastSeenLocation.coordinate, completion: { placemark in
                        self?.currentPlacemark = placemark
                        let isWithinRegion = self?.checkLocationWithinHomeRadius(coordinate: lastSeenLocation.coordinate)
                        let liveLocationRecord = LiveLocationRecord(seniorId: Description(stringValue: userID), locationName: Description(stringValue: self?.currentPlacemark?.formattedAddress ?? "Unknown Address"), longitude: Description(doubleValue: lastSeenLocation.coordinate.longitude), latitude: Description(doubleValue: lastSeenLocation.coordinate.latitude), isOutside: Description(booleanValue: isWithinRegion), isDistanceFilter: Description(booleanValue: true), createdAt: Description(doubleValue: Date.now.timeIntervalSince1970))

                        self?.service.setCompletion(endPoint: MultipleEndPoints.liveLocations, fields: liveLocationRecord, httpMethod: .post) { error in
                            print("Error: \(error?.localizedDescription ?? "No Error")")
                            self?.isFirstTimeUpdateLocation = false
                        }
                    })
                })
            }
            .store(in: &cancellables)

    }

    func fetchHomeLocation(completion: @escaping (CLLocation?) -> Void) {
        Task {
            guard let userIData = UserDefaults.standard.object(forKey: "user-auth") else {
                completion(nil)
                return
            }

            guard let userID = try? JSONDecoder().decode(UserRecord.self, from: userIData as! Data).userID else {
                completion(nil)
                return
            }

            do {
                let homeLocationRecords: FirebaseRecords<HomeLocationRecord> = try await service.fetch(endPoint: MultipleEndPoints.homeLocations, httpMethod: .get)

                if let specificHomeRecords = homeLocationRecords.documents.first(where: { $0.fields?.seniorId?.stringValue == userID }) {
                    let homeCoordinate = CLLocation(latitude: CLLocationDegrees(floatLiteral: specificHomeRecords.fields?.latitude?.doubleValue ?? 0), longitude: CLLocationDegrees(floatLiteral: specificHomeRecords.fields?.longitude?.doubleValue ?? 0))

                    completion(homeCoordinate)
                } else {
                    print("Failed to fetch home location of the specific user")
                    completion(nil)
                }
            } catch {
                print("Failed to fetch home locations: \(error)")
                completion(nil)
            }
        }
    }

    func requestPermission() {
        locationManager.requestAlwaysAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = self.lastSeenLocation else {
            print("Updated last seen location from nil")
            self.lastSeenLocation = locations.first
            return
        }

        guard let newLocation = locations.first, newLocation.distance(from: lastLocation) > 200 else {
            return
        }

        print("Updated last seen location nowp")
        self.lastSeenLocation = newLocation

        if isFirstTimeUpdateLocation && setHomeLocation != nil {
            //                print("Entered here")
            //                guard let lastSeenLocation else {
            //                    print("Not found lastseenLocation")
            //                    return
            //                }
            //
            //                guard let currentPlacemark = self.currentPlacemark else {
            //                    print("Place mark is nil")
            //                    return
            //                }
            //                print("Current placemark", currentPlacemark)
            //                let isWithinRegion = checkLocationWithinHomeRadius(coordinate: lastSeenLocation.coordinate)
            //                let liveLocationRecord = LiveLocationRecord(seniorId: Description(stringValue: userID), locationName: Description(stringValue: currentPlacemark.formattedAddress ?? "Unknown Address"), longitude: Description(doubleValue: lastSeenLocation.coordinate.longitude), latitude: Description(doubleValue: lastSeenLocation.coordinate.latitude), isOutside: Description(booleanValue: isWithinRegion), createdAt: Description(doubleValue: Date.now.timeIntervalSince1970))
            //
            //                self.service.setCompletion(endPoint: MultipleEndPoints.liveLocations, fields: liveLocationRecord, httpMethod: .post) { error in
            //                    print("Error: \(error?.localizedDescription ?? "No Error")")
            //                    DispatchQueue.main.async {
            //                        self.isFirstTimeUpdateLocation = false
            //                    }
            //                }

        } else if !isFirstTimeUpdateLocation && setHomeLocation != nil {
            //                if locationUpdateTimer == nil {
            //                    DispatchQueue.main.async {
            //                        self.locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            //                            guard let lastSeenLocation = self?.lastSeenLocation else { return }
            //                            let isWithinRegion = self?.checkLocationWithinHomeRadius(coordinate: lastSeenLocation.coordinate)
            //                            guard let currentPlacemark = self?.currentPlacemark else { return }
            //                            let liveLocationRecord = LiveLocationRecord(seniorId: Description(stringValue: userID), locationName: Description(stringValue: currentPlacemark.formattedAddress ?? "Unknown Address"), longitude: Description(doubleValue: lastSeenLocation.coordinate.longitude), latitude: Description(doubleValue: lastSeenLocation.coordinate.latitude), isOutside: Description(booleanValue: isWithinRegion), createdAt: Description(doubleValue: Date.now.timeIntervalSince1970))
            //
            //                            self?.service.setCompletion(endPoint: MultipleEndPoints.liveLocations, fields: liveLocationRecord, httpMethod: .post, completion: { error in
            //                                if let error {
            //                                    print("Error: \(error.localizedDescription)")
            //                                } else {
            //                                    print("Success creating live location record from timer")
            //                                }
            //                            })
            //
            //                        }
            //                    }
            //                }
        }


        guard let lastSeenLocation = self.lastSeenLocation, setHomeLocation != nil else { return }
        print("Entered setHomeLocation")
        let testLoc = checkLocationWithinHomeRadius(coordinate: lastSeenLocation.coordinate)

        if self.isWithinRegion != testLoc {
            if self.isWithinRegion == true && testLoc == false {
                guard let userIData = UserDefaults.standard.object(forKey: "user-auth") else { return }
                guard let userID = try? JSONDecoder().decode(UserRecord.self, from: userIData as! Data).userID else { return }

                let liveLocationRecord = LiveLocationRecord(seniorId: Description(stringValue: userID), longitude: Description(doubleValue: lastSeenLocation.coordinate.longitude), latitude: Description(doubleValue: lastSeenLocation.coordinate.latitude), isOutside: Description(booleanValue: self.isWithinRegion), isDistanceFilter: Description(booleanValue: false), createdAt: Description(doubleValue: Date.now.timeIntervalSince1970))

                self.isWithinRegion = testLoc
                self.service.setCompletion(endPoint: MultipleEndPoints.liveLocations, fields: liveLocationRecord, httpMethod: .post, completion: { error in
                    print("Error: \(error?.localizedDescription ?? "Send request because user went outside just now")")
                })
            } else {
                self.isWithinRegion = testLoc
            }
        }
    }

    deinit {
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = nil
    }

    private func testLocation(coordinate: CLLocationCoordinate2D) async throws -> CLPlacemark? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        let placemark: CLPlacemark?
        do {
            placemark = try await geocoder.reverseGeocodeLocation(location).first
            return placemark
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }

    }

    private func testLocationCompletion(coordinate: CLLocationCoordinate2D?, completion: @escaping (CLPlacemark?) -> Void) {
        if let lastLocation = coordinate {
            let location = CLLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude)
            let geocoder = CLGeocoder()

            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completion(firstLocation)
                } else {
                    print("Error: \(error?.localizedDescription)")
                    completion(nil)
                }
            }

        } else {
            print("Nil here")
            completion(nil)
        }
    }

    private func getHomeRadius() -> CLCircularRegion? {
        guard let setHomeLocation = self.setHomeLocation else {
            print("Sethomelocation is nil")
            return nil
        }
        print("Got home radius")
        return CLCircularRegion(center: setHomeLocation.coordinate, radius: 200, identifier: "RegionMap")
    }

    private func checkLocationWithinHomeRadius(coordinate: CLLocationCoordinate2D) -> Bool {
        guard let region = getHomeRadius() else {
            print("Didn't get homeradius")
            return true
        }

        if region.contains(coordinate) {
            return true
        } else {
            return false
        }
    }
}

