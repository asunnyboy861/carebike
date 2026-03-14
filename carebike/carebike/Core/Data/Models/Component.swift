import Foundation
import SwiftData

@Model
final class Component {
    var id: UUID
    var name: String
    var componentType: ComponentType
    var brand: String?
    var model: String?
    
    var installDate: Date
    var startDistance: Double
    var currentDistance: Double
    var maxDistance: Double
    
    var purchasePrice: Double
    var purchaseLocation: String?
    
    var isActive: Bool
    var healthStatus: ComponentHealth
    
    var nextMaintenanceDistance: Double?
    var lastMaintenanceDate: Date?
    
    var bicycle: Bicycle?
    
    @Relationship(deleteRule: .nullify, inverse: \MaintenanceEvent.component)
    var maintenanceEvents: [MaintenanceEvent]?
    
    @Relationship(deleteRule: .nullify, inverse: \CostEntry.component)
    var costEntries: [CostEntry]?
    
    var usagePercentage: Double {
        guard maxDistance > 0 else { return 0 }
        return min(currentDistance / maxDistance * 100, 100)
    }
    
    var remainingDistance: Double {
        max(0, maxDistance - currentDistance)
    }
    
    var needsReplacement: Bool {
        usagePercentage >= 100
    }
    
    var needsAttention: Bool {
        usagePercentage >= 80
    }
    
    init(name: String, componentType: ComponentType, 
         maxDistance: Double? = nil, purchasePrice: Double = 0) {
        self.id = UUID()
        self.name = name
        self.componentType = componentType
        self.maxDistance = maxDistance ?? componentType.defaultMaxDistance
        self.purchasePrice = purchasePrice
        self.installDate = Date()
        self.startDistance = 0
        self.currentDistance = 0
        self.isActive = true
        self.healthStatus = .excellent
        self.maintenanceEvents = []
        self.costEntries = []
    }
    
    func updateHealthStatus() {
        let percentage = usagePercentage
        if percentage >= 100 {
            healthStatus = .replaceNow
        } else if percentage >= 80 {
            healthStatus = .poor
        } else if percentage >= 60 {
            healthStatus = .fair
        } else if percentage >= 30 {
            healthStatus = .good
        } else {
            healthStatus = .excellent
        }
    }
}

enum ComponentType: String, Codable, CaseIterable {
    case chain = "Chain"
    case cassette = "Cassette"
    case chainring = "Chainring"
    case crankset = "Crankset"
    case bottomBracket = "Bottom Bracket"
    case pedals = "Pedals"
    case frontDerailleur = "Front Derailleur"
    case rearDerailleur = "Rear Derailleur"
    case brakes = "Brakes"
    case brakePads = "Brake Pads"
    case rotors = "Rotors"
    case tires = "Tires"
    case tubes = "Tubes"
    case wheels = "Wheels"
    case hub = "Hub"
    case headset = "Headset"
    case seatpost = "Seatpost"
    case saddle = "Saddle"
    case handlebar = "Handlebar"
    case stem = "Stem"
    case grips = "Grips"
    case cables = "Cables"
    case battery = "Battery"
    case motor = "Motor"
    case suspension = "Suspension"
    case dropperPost = "Dropper Post"
    
    var defaultMaxDistance: Double {
        switch self {
        case .chain: return 2000
        case .cassette: return 3000
        case .chainring: return 5000
        case .crankset: return 10000
        case .bottomBracket: return 10000
        case .pedals: return 15000
        case .frontDerailleur: return 10000
        case .rearDerailleur: return 10000
        case .brakes: return 10000
        case .brakePads: return 1500
        case .rotors: return 10000
        case .tires: return 3000
        case .tubes: return 2000
        case .wheels: return 20000
        case .hub: return 20000
        case .headset: return 15000
        case .seatpost: return 15000
        case .saddle: return 20000
        case .handlebar: return 20000
        case .stem: return 20000
        case .grips: return 5000
        case .cables: return 10000
        case .battery: return 30000
        case .motor: return 50000
        case .suspension: return 50000
        case .dropperPost: return 10000
        }
    }
    
    var icon: String {
        switch self {
        case .chain: return "link"
        case .cassette: return "gearshape.2"
        case .chainring: return "gearshape"
        case .crankset: return "gearshape.2"
        case .bottomBracket: return "circle.dashed"
        case .pedals: return "rectangle.and.arrow.up.and.down"
        case .frontDerailleur: return "arrow.left.arrow.right"
        case .rearDerailleur: return "arrow.left.arrow.right"
        case .brakes, .brakePads: return "hand.brake"
        case .rotors: return "circle.circle"
        case .tires, .tubes: return "circle"
        case .wheels: return "circle.circle"
        case .hub: return "circle.dashed.inset.filled"
        case .headset: return "arrow.up.and.down"
        case .seatpost: return "arrow.up.and.down"
        case .saddle: return "rectangle"
        case .handlebar: return "arrow.left.arrow.right"
        case .stem: return "arrow.left.arrow.right"
        case .grips: return "rectangle"
        case .cables: return "cable.connector"
        case .battery: return "battery.100"
        case .motor: return "bolt.fill"
        case .suspension: return "waveform.path"
        case .dropperPost: return "arrow.up.and.down"
        }
    }
    
    var maintenanceTips: String {
        switch self {
        case .chain:
            return "Clean and lubricate every 200-300 km. Check for stretch using a chain checker tool."
        case .cassette:
            return "Replace when teeth become shark-fin shaped. Usually lasts 2-3 chain replacements."
        case .chainring:
            return "Check for worn or hooked teeth. Replace when chain skips under load."
        case .brakePads:
            return "Check pad thickness regularly. Replace when less than 1mm remains."
        case .tires:
            return "Check for cuts, embedded debris, and tread wear. Replace when casing shows."
        case .suspension:
            return "Service air can/damper annually. Check seals for leaks."
        default:
            return "Regular inspection and cleaning recommended."
        }
    }
}

enum ComponentHealth: String, Codable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    case replaceNow = "Replace Now"
    
    var color: String {
        switch self {
        case .excellent: return "green"
        case .good: return "blue"
        case .fair: return "yellow"
        case .poor: return "orange"
        case .replaceNow: return "red"
        }
    }
    
    var icon: String {
        switch self {
        case .excellent: return "checkmark.circle.fill"
        case .good: return "checkmark.circle"
        case .fair: return "exclamationmark.circle"
        case .poor: return "exclamationmark.triangle"
        case .replaceNow: return "xmark.octagon.fill"
        }
    }
}

extension Component: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, componentType, brand, model
        case installDate, startDistance, currentDistance, maxDistance
        case purchasePrice, purchaseLocation, isActive, healthStatus
        case nextMaintenanceDistance, lastMaintenanceDate
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.init(
            name: try container.decode(String.self, forKey: .name),
            componentType: try container.decode(ComponentType.self, forKey: .componentType),
            maxDistance: try container.decodeIfPresent(Double.self, forKey: .maxDistance),
            purchasePrice: try container.decodeIfPresent(Double.self, forKey: .purchasePrice) ?? 0
        )
        
        id = try container.decode(UUID.self, forKey: .id)
        brand = try container.decodeIfPresent(String.self, forKey: .brand)
        model = try container.decodeIfPresent(String.self, forKey: .model)
        installDate = try container.decodeIfPresent(Date.self, forKey: .installDate) ?? Date()
        startDistance = try container.decodeIfPresent(Double.self, forKey: .startDistance) ?? 0
        currentDistance = try container.decodeIfPresent(Double.self, forKey: .currentDistance) ?? 0
        purchaseLocation = try container.decodeIfPresent(String.self, forKey: .purchaseLocation)
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? true
        healthStatus = try container.decodeIfPresent(ComponentHealth.self, forKey: .healthStatus) ?? .excellent
        nextMaintenanceDistance = try container.decodeIfPresent(Double.self, forKey: .nextMaintenanceDistance)
        lastMaintenanceDate = try container.decodeIfPresent(Date.self, forKey: .lastMaintenanceDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(componentType, forKey: .componentType)
        try container.encodeIfPresent(brand, forKey: .brand)
        try container.encodeIfPresent(model, forKey: .model)
        try container.encode(installDate, forKey: .installDate)
        try container.encode(startDistance, forKey: .startDistance)
        try container.encode(currentDistance, forKey: .currentDistance)
        try container.encode(maxDistance, forKey: .maxDistance)
        try container.encode(purchasePrice, forKey: .purchasePrice)
        try container.encodeIfPresent(purchaseLocation, forKey: .purchaseLocation)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(healthStatus, forKey: .healthStatus)
        try container.encodeIfPresent(nextMaintenanceDistance, forKey: .nextMaintenanceDistance)
        try container.encodeIfPresent(lastMaintenanceDate, forKey: .lastMaintenanceDate)
    }
}
