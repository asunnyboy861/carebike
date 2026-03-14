import Foundation
import SwiftData

@Model
final class Bicycle {
    var id: UUID
    var name: String
    var brand: String
    var model: String
    var year: Int
    var bikeType: BikeType
    var color: String?
    var imageData: Data?
    
    var totalDistance: Double
    var currentDistance: Double
    var lastRideDate: Date?
    var lastMaintenanceDate: Date?
    var nextMaintenanceDate: Date?
    
    var totalMaintenanceCost: Double
    var purchasePrice: Double
    var purchaseDate: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Component.bicycle)
    var components: [Component]?
    
    @Relationship(deleteRule: .cascade, inverse: \MaintenanceEvent.bicycle)
    var maintenanceEvents: [MaintenanceEvent]?
    
    @Relationship(deleteRule: .cascade, inverse: \Ride.bicycle)
    var rides: [Ride]?
    
    @Relationship(deleteRule: .nullify, inverse: \CostEntry.bicycle)
    var costEntries: [CostEntry]?
    
    init(name: String, brand: String, model: String, year: Int, 
         bikeType: BikeType, purchasePrice: Double = 0) {
        self.id = UUID()
        self.name = name
        self.brand = brand
        self.model = model
        self.year = year
        self.bikeType = bikeType
        self.purchasePrice = purchasePrice
        self.purchaseDate = Date()
        self.totalDistance = 0
        self.currentDistance = 0
        self.totalMaintenanceCost = 0
        self.components = []
        self.maintenanceEvents = []
        self.rides = []
        self.costEntries = []
    }
    
    var formattedDistance: String {
        let distance = Measurement(value: totalDistance, unit: UnitLength.kilometers)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        return formatter.string(from: distance)
    }
    
    var daysSinceLastRide: Int? {
        guard let lastRide = lastRideDate else { return nil }
        return Calendar.current.dateComponents([.day], from: lastRide, to: Date()).day
    }
    
    var needsMaintenance: Bool {
        guard let nextMaintenance = nextMaintenanceDate else { return false }
        return nextMaintenance <= Date()
    }
}

enum BikeType: String, Codable, CaseIterable {
    case road = "Road"
    case mountain = "Mountain"
    case hybrid = "Hybrid"
    case electric = "E-Bike"
    case folding = "Folding"
    case commuter = "Commuter"
    case gravel = "Gravel"
    case fixedGear = "Fixed Gear"
    case cyclocross = "Cyclocross"
    case fatBike = "Fat Bike"
    
    var icon: String {
        switch self {
        case .road: return "bicycle"
        case .mountain: return "bicycle.circle"
        case .hybrid: return "bicycle"
        case .electric: return "bolt.bicycle"
        case .folding: return "bicycle"
        case .commuter: return "bicycle"
        case .gravel: return "bicycle.circle"
        case .fixedGear: return "bicycle"
        case .cyclocross: return "bicycle.circle"
        case .fatBike: return "bicycle.circle"
        }
    }
    
    var defaultComponents: [ComponentType] {
        switch self {
        case .road, .gravel, .commuter, .fixedGear, .cyclocross:
            return [.chain, .cassette, .chainring, .brakePads, .tires, .cables]
        case .mountain, .fatBike:
            return [.chain, .cassette, .chainring, .brakePads, .tires, .suspension, .dropperPost]
        case .hybrid:
            return [.chain, .cassette, .brakePads, .tires]
        case .electric:
            return [.chain, .cassette, .chainring, .brakePads, .tires, .battery, .motor]
        case .folding:
            return [.chain, .brakePads, .tires]
        }
    }
}

extension Bicycle: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, brand, model, year, bikeType, color, imageData
        case totalDistance, currentDistance, lastRideDate, lastMaintenanceDate, nextMaintenanceDate
        case totalMaintenanceCost, purchasePrice, purchaseDate
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.init(
            name: try container.decode(String.self, forKey: .name),
            brand: try container.decode(String.self, forKey: .brand),
            model: try container.decode(String.self, forKey: .model),
            year: try container.decode(Int.self, forKey: .year),
            bikeType: try container.decode(BikeType.self, forKey: .bikeType),
            purchasePrice: try container.decode(Double.self, forKey: .purchasePrice)
        )
        
        id = try container.decode(UUID.self, forKey: .id)
        color = try container.decodeIfPresent(String.self, forKey: .color)
        imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
        totalDistance = try container.decode(Double.self, forKey: .totalDistance)
        currentDistance = try container.decode(Double.self, forKey: .currentDistance)
        lastRideDate = try container.decodeIfPresent(Date.self, forKey: .lastRideDate)
        lastMaintenanceDate = try container.decodeIfPresent(Date.self, forKey: .lastMaintenanceDate)
        nextMaintenanceDate = try container.decodeIfPresent(Date.self, forKey: .nextMaintenanceDate)
        totalMaintenanceCost = try container.decode(Double.self, forKey: .totalMaintenanceCost)
        purchaseDate = try container.decode(Date.self, forKey: .purchaseDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(brand, forKey: .brand)
        try container.encode(model, forKey: .model)
        try container.encode(year, forKey: .year)
        try container.encode(bikeType, forKey: .bikeType)
        try container.encodeIfPresent(color, forKey: .color)
        try container.encodeIfPresent(imageData, forKey: .imageData)
        try container.encode(totalDistance, forKey: .totalDistance)
        try container.encode(currentDistance, forKey: .currentDistance)
        try container.encodeIfPresent(lastRideDate, forKey: .lastRideDate)
        try container.encodeIfPresent(lastMaintenanceDate, forKey: .lastMaintenanceDate)
        try container.encodeIfPresent(nextMaintenanceDate, forKey: .nextMaintenanceDate)
        try container.encode(totalMaintenanceCost, forKey: .totalMaintenanceCost)
        try container.encode(purchasePrice, forKey: .purchasePrice)
        try container.encode(purchaseDate, forKey: .purchaseDate)
    }
}
