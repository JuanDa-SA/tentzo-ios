//
//  LocationManager.swift
//  ocoyuApp
//
//  Created by Javier Cuatepotzo on 06/11/24.
//
import SwiftUI
import CoreLocation

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    @ObservationIgnored let manager = CLLocationManager()
    var userLocation: CLLocation?
    var userLocations: [CLLocationCoordinate2D] = []
    var isAuthorized = false
    var isTracking = false
    var totalDistance: Double = 0.0 // Distancia total recorrida en metros

    override init() {
        super.init()
        manager.delegate = self
        startLocationServices()
    }

    func startLocationServices() {
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
            isAuthorized = true
        } else {
            isAuthorized = false
            manager.requestWhenInUseAuthorization()
        }
    }

    func startTracking() {
        isTracking = true
        userLocations.removeAll()
        totalDistance = 0.0 // Reinicia la distancia al iniciar el seguimiento
    }

    func stopTracking() {
        isTracking = false
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            userLocation = lastLocation
            if isTracking {
                if let previousLocation = userLocations.last {
                    let previousCLLocation = CLLocation(latitude: previousLocation.latitude, longitude: previousLocation.longitude)
                    let currentCLLocation = CLLocation(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
                    
                    // Calcula la distancia desde la última ubicación y la agrega al total
                    let distance = previousCLLocation.distance(from: currentCLLocation)
                    totalDistance += distance
                }

                // Agrega la nueva ubicación al historial
                userLocations.append(lastLocation.coordinate)
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            isAuthorized = true
            manager.requestLocation()
        case .notDetermined:
            isAuthorized = false
            manager.requestWhenInUseAuthorization()
        case .denied:
            isAuthorized = false
            print("Access denied")
        default:
            isAuthorized = true
            startLocationServices()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
