import SwiftUI
import SwiftData
import MapKit

struct ActiveRideView: View {
    var initialBike: Bicycle? = nil
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var locationManager = LocationManager()
    @State private var isPaused = false
    @State private var selectedBicycle: Bicycle?
    @State private var showingBikePicker = false
    
    @Query(sort: \Bicycle.name) private var bicycles: [Bicycle]
    
    var body: some View {
        VStack(spacing: 0) {
            mapView
            
            statsPanel
        }
        .navigationTitle("Active Ride")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    endRide()
                }
            }
        }
        .onAppear {
            selectedBicycle = initialBike ?? bicycles.first
            locationManager.requestAuthorization()
            locationManager.startRide()
        }
    }
    
    private var mapView: some View {
        Map(position: .constant(.region(mapRegion))) {
            if !locationManager.routePoints.isEmpty {
                MapPolyline(coordinates: locationManager.routePoints.map { $0.coordinate })
                    .stroke(.blue, lineWidth: 4)
            }
            
            if let location = locationManager.currentLocation {
                Annotation("Current", coordinate: location.coordinate) {
                    ZStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 20, height: 20)
                        Circle()
                            .fill(.white)
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    private var mapRegion: MKCoordinateRegion {
        if let location = locationManager.currentLocation {
            return MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }
    
    private var statsPanel: some View {
        VStack(spacing: 16) {
            HStack(spacing: 24) {
                StatItem(
                    title: "Distance",
                    value: locationManager.totalDistance.formattedDistance,
                    icon: "bicycle.circle.fill"
                )
                
                StatItem(
                    title: "Speed",
                    value: locationManager.currentSpeed.formattedSpeed,
                    icon: "speedometer"
                )
                
                StatItem(
                    title: "Duration",
                    value: durationString,
                    icon: "clock"
                )
            }
            
            HStack(spacing: 20) {
                Button(action: togglePause) {
                    HStack {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        Text(isPaused ? "Resume" : "Pause")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: endRide) {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("End Ride")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var durationString: String {
        guard let startTime = locationManager.rideStartTime else { return "00:00" }
        let duration = Date().timeIntervalSince(startTime)
        return duration.formattedDuration
    }
    
    private func togglePause() {
        if isPaused {
            locationManager.resumeRide()
        } else {
            locationManager.pauseRide()
        }
        isPaused.toggle()
    }
    
    private func endRide() {
        if let ride = locationManager.stopRide() {
            if let bike = selectedBicycle {
                ride.bicycle = bike
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
        }
        dismiss()
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        ActiveRideView()
    }
}
