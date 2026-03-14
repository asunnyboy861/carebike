import Foundation
import SwiftData
import CoreLocation

@MainActor
class RideTrackingViewModel: ObservableObject {
    @Published var isTracking = false
    @Published var isPaused = false
    @Published var currentRide: Ride?
    @Published var routePoints: [RoutePoint] = []
    @Published var currentSpeed: Double = 0
    @Published var totalDistance: Double = 0
    @Published var duration: TimeInterval = 0
    
    private let locationManager = LocationManager()
    private var startTime: Date?
    
    var formattedDuration: String {
        duration.formattedDuration
    }
    
    var formattedSpeed: String {
        currentSpeed.formattedSpeed
    }
    
    var formattedDistance: String {
        totalDistance.formattedDistance
    }
    
    func startRide(for bicycle: Bicycle? = nil) {
        isTracking = true
        isPaused = false
        startTime = Date()
        currentRide = Ride(startTime: Date())
        if let bike = bicycle {
            currentRide?.bicycle = bike
        }
        
        locationManager.startRide()
    }
    
    func pauseRide() {
        isPaused = true
        locationManager.pauseRide()
    }
    
    func resumeRide() {
        isPaused = false
        locationManager.resumeRide()
    }
    
    func endRide(modelContext: ModelContext) -> Ride? {
        isTracking = false
        isPaused = false
        
        guard var ride = locationManager.stopRide() else { return nil }
        
        ride.endTime = Date()
        ride.distance = totalDistance
        ride.duration = duration
        
        if let bike = ride.bicycle {
            bike.totalDistance += ride.distance
            bike.lastRideDate = Date()
            
            if let components = bike.components {
                for component in components where component.isActive {
                    component.currentDistance += ride.distance
                    component.updateHealthStatus()
                }
            }
        }
        
        modelContext.insert(ride)
        
        return ride
    }
    
    func updateLocation(_ location: CLLocation) {
        if !isPaused {
            if let previous = routePoints.last {
                let distance = location.distance(from: CLLocation(
                    latitude: previous.latitude,
                    longitude: previous.longitude
                ))
                totalDistance += distance / 1000
            }
            
            let point = RoutePoint(location: location, distance: totalDistance)
            routePoints.append(point)
            
            currentSpeed = max(0, location.speed * 3.6)
            
            if let start = startTime {
                duration = Date().timeIntervalSince(start)
            }
        }
    }
    
    func getRidesForBike(_ bike: Bicycle) -> [Ride] {
        (bike.rides ?? []).sorted { $0.startTime > $1.startTime }
    }
    
    func getTotalDistance(for bike: Bicycle) -> Double {
        (bike.rides ?? []).reduce(0) { $0 + $1.distance }
    }
    
    func getAverageSpeed(for bike: Bicycle) -> Double {
        let rides = bike.rides ?? []
        guard !rides.isEmpty else { return 0 }
        let totalDistance = rides.reduce(0) { $0 + $1.distance }
        let totalDuration = rides.reduce(0.0) { $0 + $1.duration }
        guard totalDuration > 0 else { return 0 }
        return totalDistance / (totalDuration / 3600)
    }
}
