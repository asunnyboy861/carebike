import SwiftUI
import MapKit

struct RideDetailView: View {
    let ride: Ride
    
    @State private var mapRegion: MKCoordinateRegion
    
    init(ride: Ride) {
        self.ride = ride
        
        if let routePoints = ride.routePoints, let firstPoint = routePoints.first {
            _mapRegion = State(initialValue: MKCoordinateRegion(
                center: firstPoint.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        } else {
            _mapRegion = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                mapSection
                statsSection
                bikeSection
            }
            .padding()
        }
        .navigationTitle("Ride Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Route")
                .font(.headline)
            
            Map(position: .constant(.region(mapRegion))) {
                if let points = ride.routePoints, !points.isEmpty {
                    MapPolyline(coordinates: points.map { $0.coordinate })
                        .stroke(.blue, lineWidth: 4)
                    
                    if let start = points.first {
                        Annotation("Start", coordinate: start.coordinate) {
                            Image(systemName: "play.circle.fill")
                                .foregroundColor(.green)
                                .font(.title)
                        }
                    }
                    
                    if let end = points.last, points.count > 1 {
                        Annotation("End", coordinate: end.coordinate) {
                            Image(systemName: "stop.circle.fill")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                    }
                }
            }
            .frame(height: 250)
            .cornerRadius(Constants.UI.cornerRadius)
        }
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatCard(
                    title: "Distance",
                    value: ride.distance.formattedDistance,
                    icon: "bicycle.circle.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Duration",
                    value: ride.formattedDuration,
                    icon: "clock",
                    color: .green
                )
                
                StatCard(
                    title: "Avg Speed",
                    value: averageSpeed.formattedSpeed,
                    icon: "speedometer",
                    color: .orange
                )
                
                StatCard(
                    title: "Max Speed",
                    value: ride.maxSpeed.formattedSpeed,
                    icon: "bolt",
                    color: .red
                )
            }
        }
    }
    
    private var bikeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bike")
                .font(.headline)
            
            if let bike = ride.bicycle {
                HStack {
                    Image(systemName: bike.bikeType.icon)
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text(bike.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("\(bike.brand) \(bike.model)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(Constants.UI.cornerRadius)
            } else {
                Text("No bike associated")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(Constants.UI.cornerRadius)
            }
        }
    }
    
    private var averageSpeed: Double {
        guard ride.duration > 0 else { return 0 }
        return ride.distance / (ride.duration / 3600)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(Constants.UI.cornerRadius)
    }
}

#Preview {
    NavigationStack {
        RideDetailView(ride: Ride(startTime: Date()))
    }
}
