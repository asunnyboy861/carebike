import Foundation
import CoreLocation
import Combine

@MainActor
class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var currentLocation: CLLocation?
    @Published var isLocationEnabled = false
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var routePoints: [RoutePoint] = []
    @Published var currentSpeed: Double = 0
    @Published var totalDistance: Double = 0
    @Published var currentRide: Ride?
    
    private var previousLocation: CLLocation?
    var rideStartTime: Date?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 5
        locationManager.activityType = .fitness
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        
        authorizationStatus = locationManager.authorizationStatus
        isLocationEnabled = authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
    
    func startRide() {
        routePoints.removeAll()
        totalDistance = 0
        currentSpeed = 0
        previousLocation = nil
        rideStartTime = Date()
        currentRide = Ride(startTime: Date())
        
        locationManager.startUpdatingLocation()
    }
    
    func stopRide() -> Ride? {
        locationManager.stopUpdatingLocation()
        
        guard var ride = currentRide else { return nil }
        
        ride.endTime = Date()
        ride.distance = totalDistance
        ride.duration = Date().timeIntervalSince(ride.startTime)
        ride.averageSpeed = totalDistance / max(ride.duration / 3600, 0.001)
        
        if let routeData = try? JSONEncoder().encode(routePoints) {
            ride.routeData = routeData
        }
        
        currentRide = nil
        return ride
    }
    
    func pauseRide() {
        locationManager.stopUpdatingLocation()
    }
    
    func resumeRide() {
        locationManager.startUpdatingLocation()
    }
    
    private func processLocation(_ location: CLLocation) {
        currentLocation = location
        currentSpeed = max(0, location.speed * 3.6)
        
        if let previous = previousLocation {
            let distance = location.distance(from: previous)
            totalDistance += distance / 1000
            
            let routePoint = RoutePoint(location: location, distance: totalDistance)
            routePoints.append(routePoint)
        } else {
            let routePoint = RoutePoint(location: location, distance: 0)
            routePoints.append(routePoint)
        }
        
        previousLocation = location
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let location = locations.last else { return }
            processLocation(location)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            authorizationStatus = status
            isLocationEnabled = status == .authorizedAlways || status == .authorizedWhenInUse
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error)")
    }
}
