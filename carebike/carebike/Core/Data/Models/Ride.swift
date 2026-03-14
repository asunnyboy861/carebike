import Foundation
import SwiftData
import CoreLocation

@Model
final class Ride {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval
    var distance: Double
    var averageSpeed: Double
    var maxSpeed: Double
    var elevationGain: Double
    var calories: Double
    var notes: String?
    var routeData: Data?
    
    var bicycle: Bicycle?
    
    init(startTime: Date = Date()) {
        self.id = UUID()
        self.startTime = startTime
        self.duration = 0
        self.distance = 0
        self.averageSpeed = 0
        self.maxSpeed = 0
        self.elevationGain = 0
        self.calories = 0
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedDistance: String {
        let distance = Measurement(value: distance, unit: UnitLength.kilometers)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        return formatter.string(from: distance)
    }
    
    var formattedAverageSpeed: String {
        let speed = Measurement(value: averageSpeed, unit: UnitSpeed.kilometersPerHour)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        return formatter.string(from: speed)
    }
}

extension Ride {
    var routePoints: [RoutePoint]? {
        guard let routeData = routeData else { return nil }
        return try? JSONDecoder().decode([RoutePoint].self, from: routeData)
    }
}

extension Ride: Codable {
    enum CodingKeys: String, CodingKey {
        case id, startTime, endTime, duration, distance
        case averageSpeed, maxSpeed, elevationGain, calories
        case notes, routeData
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.init(startTime: try container.decode(Date.self, forKey: .startTime))
        
        id = try container.decode(UUID.self, forKey: .id)
        endTime = try container.decodeIfPresent(Date.self, forKey: .endTime)
        duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration) ?? 0
        distance = try container.decodeIfPresent(Double.self, forKey: .distance) ?? 0
        averageSpeed = try container.decodeIfPresent(Double.self, forKey: .averageSpeed) ?? 0
        maxSpeed = try container.decodeIfPresent(Double.self, forKey: .maxSpeed) ?? 0
        elevationGain = try container.decodeIfPresent(Double.self, forKey: .elevationGain) ?? 0
        calories = try container.decodeIfPresent(Double.self, forKey: .calories) ?? 0
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        routeData = try container.decodeIfPresent(Data.self, forKey: .routeData)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(startTime, forKey: .startTime)
        try container.encodeIfPresent(endTime, forKey: .endTime)
        try container.encode(duration, forKey: .duration)
        try container.encode(distance, forKey: .distance)
        try container.encode(averageSpeed, forKey: .averageSpeed)
        try container.encode(maxSpeed, forKey: .maxSpeed)
        try container.encode(elevationGain, forKey: .elevationGain)
        try container.encode(calories, forKey: .calories)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encodeIfPresent(routeData, forKey: .routeData)
    }
}

struct RoutePoint: Codable {
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let timestamp: Date
    let speed: Double?
    let distance: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(location: CLLocation, distance: Double = 0) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
        self.timestamp = location.timestamp
        self.speed = location.speed
        self.distance = distance
    }
}
