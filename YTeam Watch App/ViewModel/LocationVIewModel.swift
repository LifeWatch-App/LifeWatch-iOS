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
        initializerFunction()
        setupSubcribers()
        locationManager.startUpdatingLocation()
    }

    func setupSubcribers() {
        //        $shouldSet
        //            .combineLatest($lastSeenLocation)
        //            .receive(on: DispatchQueue.main)
        //            .sink { [weak self] shouldSet, lastSeenLocation in
        //                guard let userIData = UserDefaults.standard.object(forKey: "user-auth") else { return }
        //                guard let userID = try? JSONDecoder().decode(UserRecord.self, from: userIData as! Data).userID else { return }
        //                guard let notNillLocation = lastSeenLocation else { return }
        //
        //                if shouldSet == true {
        //                    self?.service.fetchCompletion(endPoint: MultipleEndPoints.homeLocations, httpMethod: .get) { (result: Result<FirebaseRecords<HomeLocationRecord>, Error>) in
        //                        switch result {
        //                        case .success(let homeLocationRecords):
        //                            if !homeLocationRecords.documents.isEmpty {
        //                                if let specificHomeRecord = homeLocationRecords.documents.first(where: { $0.fields?.seniorId?.stringValue == userID }) {
        //
        //                                    guard let specificHomeRecordDocumentName = specificHomeRecord.name else { return }
        //                                    let components = specificHomeRecordDocumentName.components(separatedBy: "/")
        //                                    guard let specificHomeRecordDocumentID = components.last else { return }
        //                                    let homeLocationRecord = HomeLocationRecord(seniorId: Description(stringValue: userID), longitude: Description(doubleValue: lastSeenLocation?.coordinate.longitude), latitude: Description(doubleValue: lastSeenLocation?.coordinate.latitude), radius: Description(doubleValue: 200), lastUpdatedAt: Description(doubleValue: Date.now.timeIntervalSince1970))
        //
        //                                    self?.setHomeLocation = lastSeenLocation
        //                                    self?.shouldSet = false
        //                                    self?.service.setCompletion(endPoint: SingleEndpoints.homeLocations(homeLocationsDocumentID: specificHomeRecordDocumentID), fields: homeLocationRecord, httpMethod: .patch) { error in
        //                                        print("Error: \(error?.localizedDescription ?? "No Error")")
        //                                    }
        //
        //                                } else {
        //                                    let homeLocationRecord = HomeLocationRecord(seniorId: Description(stringValue: userID), longitude: Description(doubleValue: self?.lastSeenLocation?.coordinate.longitude), latitude: Description(doubleValue: self?.lastSeenLocation?.coordinate.latitude), radius: Description(doubleValue: 200), lastUpdatedAt: Description(doubleValue: Date.now.timeIntervalSince1970))
        //
        //                                    self?.setHomeLocation = notNillLocation
        //                                    self?.shouldSet = false
        //                                    self?.service.setCompletion(endPoint: MultipleEndPoints.homeLocations, fields: homeLocationRecord, httpMethod: .post) { error in
        //                                        print("Error: \(error?.localizedDescription ?? "No Error")")
        //                                    }
        //
        //                                }
        //
        //                            } else {
        //                                let homeLocationRecord = HomeLocationRecord(seniorId: Description(stringValue: userID), longitude: Description(doubleValue: self?.lastSeenLocation?.coordinate.longitude), latitude: Description(doubleValue: self?.lastSeenLocation?.coordinate.latitude), radius: Description(doubleValue: 200), lastUpdatedAt: Description(doubleValue: Date.now.timeIntervalSince1970))
        //
        //                                self?.setHomeLocation = notNillLocation
        //                                self?.shouldSet = false
        //                                self?.service.setCompletion(endPoint: MultipleEndPoints.homeLocations, fields: homeLocationRecord, httpMethod: .post) { error in
        //                                    print("Error: \(error?.localizedDescription ?? "No Error")")
        //                                }
        //                            }
        //                        case .failure(let error):
        //                            print("Error fetching homeLocationRecords: \(error)")
        //                        }
        //                    }
        //                }
        //            }
        //            .store(in: &cancellables)

        $lastSeenLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] lastSeenLocation in
                guard let lastSeenLocation else { return }
                guard let userIData = UserDefaults.standard.object(forKey: "user-auth") else { return }
                guard let userID = try? JSONDecoder().decode(UserRecord.self, from: userIData as! Data).userID else { return }

                self?.testLocationCompletion(coordinate: lastSeenLocation.coordinate, completion: { placemark in
                    self?.currentPlacemark = placemark
                    let isWithinRegion = self?.checkLocationWithinHomeRadius(coordinate: lastSeenLocation.coordinate)
                    let liveLocationRecord = LiveLocationRecord(seniorId: Description(stringValue: userID), locationName: Description(stringValue: self?.currentPlacemark?.formattedAddress ?? "Unknown Address"), longitude: Description(doubleValue: lastSeenLocation.coordinate.longitude), latitude: Description(doubleValue: lastSeenLocation.coordinate.latitude), isOutside: Description(booleanValue: isWithinRegion), createdAt: Description(doubleValue: Date.now.timeIntervalSince1970))

                    self?.service.setCompletion(endPoint: MultipleEndPoints.liveLocations, fields: liveLocationRecord, httpMethod: .post) { error in
                        print("Error: \(error?.localizedDescription ?? "No Error")")
                        DispatchQueue.main.async {
                            self?.isFirstTimeUpdateLocation = false
                        }
                    }
                })
            }
            .store(in: &cancellables)

    }

    func initializerFunction() {
        Task {
            guard let userIData = UserDefaults.standard.object(forKey: "user-auth") else { return }
            guard let userID = try? JSONDecoder().decode(UserRecord.self, from: userIData as! Data).userID else { return }
            guard let homeLocationRecords: FirebaseRecords<HomeLocationRecord> = try? await service.fetch(endPoint: MultipleEndPoints.homeLocations, httpMethod: .get) else {
                print("Failed to fetch home locations")
                return
            }

            if let specificHomeRecords = homeLocationRecords.documents.first(where: { $0.fields?.seniorId?.stringValue == userID }) {
                DispatchQueue.main.async {
                    self.setHomeLocation = CLLocation(latitude: CLLocationDegrees(floatLiteral: specificHomeRecords.fields?.latitude?.doubleValue ?? 0), longitude: CLLocationDegrees(floatLiteral: specificHomeRecords.fields?.longitude?.doubleValue ?? 0))
                }
            } else {
                print("Failed to fetch home location of the specific user")
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
        guard let userIData = UserDefaults.standard.object(forKey: "user-auth") else { return }
        guard let userID = try? JSONDecoder().decode(UserRecord.self, from: userIData as! Data).userID else { return }

        Task {
            if let location = self.lastSeenLocation {
                if lastSeenLocation != locations.first, (locations.first?.distance(from: location))! > 200 {
                    DispatchQueue.main.async {
                        self.lastSeenLocation = locations.first
                    }
                }

            } else {
                DispatchQueue.main.async {
                    self.lastSeenLocation = locations.first
                }
            }

            if isFirstTimeUpdateLocation && setHomeLocation != nil {
                print("Entered here")
                guard let lastSeenLocation else {
                    print("Not found lastseenLocation")
                    return
                }

                guard let currentPlacemark = self.currentPlacemark else {
                    print("Place mark is nil")
                    return
                }
                print("Current placemark", currentPlacemark)
                let isWithinRegion = checkLocationWithinHomeRadius(coordinate: lastSeenLocation.coordinate)
                let liveLocationRecord = LiveLocationRecord(seniorId: Description(stringValue: userID), locationName: Description(stringValue: currentPlacemark.formattedAddress ?? "Unknown Address"), longitude: Description(doubleValue: lastSeenLocation.coordinate.longitude), latitude: Description(doubleValue: lastSeenLocation.coordinate.latitude), isOutside: Description(booleanValue: isWithinRegion), createdAt: Description(doubleValue: Date.now.timeIntervalSince1970))

                self.service.setCompletion(endPoint: MultipleEndPoints.liveLocations, fields: liveLocationRecord, httpMethod: .post) { error in
                    print("Error: \(error?.localizedDescription ?? "No Error")")
                    DispatchQueue.main.async {
                        self.isFirstTimeUpdateLocation = false
                    }
                }

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
            let testLoc = checkLocationWithinHomeRadius(coordinate: lastSeenLocation.coordinate)

            //            if self.isWithinRegion != testLoc {
            //                if self.isWithinRegion == true && testLoc == false {
            //                    guard let userIData = UserDefaults.standard.object(forKey: "user-auth") else { return }
            //                    guard let userID = try? JSONDecoder().decode(UserRecord.self, from: userIData as! Data).userID else { return }
            //
            //                    let liveLocationRecord = LiveLocationRecord(seniorId: Description(stringValue: userID), longitude: Description(doubleValue: lastSeenLocation.coordinate.longitude), latitude: Description(doubleValue: lastSeenLocation.coordinate.latitude), isOutside: Description(booleanValue: self.isWithinRegion), createdAt: Description(doubleValue: Date.now.timeIntervalSince1970))
            //
            //                    self.isWithinRegion = testLoc
            //                    self.service.setCompletion(endPoint: MultipleEndPoints.liveLocations, fields: liveLocationRecord, httpMethod: .post, completion: { error in
            //                        print("Error: \(error?.localizedDescription ?? "Send request because user went outside just now")")
            //                    })
            //                } else {
            //                    self.isWithinRegion = testLoc
            //                }
            //            }
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

