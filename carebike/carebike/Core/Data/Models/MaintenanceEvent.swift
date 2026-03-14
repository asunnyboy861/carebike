import Foundation
import SwiftData

@Model
final class MaintenanceEvent {
    var id: UUID
    var title: String
    var maintenanceType: MaintenanceType
    var maintenanceDescription: String?
    var date: Date
    var cost: Double
    var distance: Double
    var isCompleted: Bool
    var isScheduled: Bool
    var scheduledDate: Date?
    var notes: String?
    var serviceProvider: String?
    
    var bicycle: Bicycle?
    var component: Component?
    
    @Relationship(deleteRule: .nullify, inverse: \CostEntry.maintenanceEvent)
    var costEntries: [CostEntry]?
    
    init(title: String, maintenanceType: MaintenanceType, date: Date = Date(), 
         cost: Double = 0, distance: Double = 0) {
        self.id = UUID()
        self.title = title
        self.maintenanceType = maintenanceType
        self.date = date
        self.cost = cost
        self.distance = distance
        self.isCompleted = false
        self.isScheduled = false
        self.costEntries = []
    }
    
    var formattedCost: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: cost)) ?? "$0.00"
    }
}

enum MaintenanceType: String, Codable, CaseIterable {
    case routine = "Routine Maintenance"
    case repair = "Repair"
    case replacement = "Component Replacement"
    case upgrade = "Upgrade"
    case inspection = "Inspection"
    case cleaning = "Cleaning"
    case tuning = "Tuning"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .routine: return "wrench.and.screwdriver"
        case .repair: return "wrench.adjustable"
        case .replacement: return "arrow.triangle.2.circlepath"
        case .upgrade: return "arrow.up.circle"
        case .inspection: return "eye"
        case .cleaning: return "sparkles"
        case .tuning: return "slider.horizontal.3"
        case .other: return "questionmark.circle"
        }
    }
    
    var defaultInterval: Int {
        switch self {
        case .routine: return 500
        case .inspection: return 1000
        case .cleaning: return 200
        case .tuning: return 1000
        default: return 0
        }
    }
}

enum MaintenancePriority: String, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    
    var icon: String {
        switch self {
        case .low: return "flag"
        case .medium: return "flag.fill"
        case .high: return "exclamationmark.circle"
        case .urgent: return "exclamationmark.triangle.fill"
        }
    }
}

extension MaintenanceEvent: Codable {
    enum CodingKeys: String, CodingKey {
        case id, title, maintenanceType, maintenanceDescription
        case date, cost, distance, isCompleted, isScheduled
        case scheduledDate, notes, serviceProvider
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.init(
            title: try container.decode(String.self, forKey: .title),
            maintenanceType: try container.decode(MaintenanceType.self, forKey: .maintenanceType),
            date: try container.decode(Date.self, forKey: .date),
            cost: try container.decodeIfPresent(Double.self, forKey: .cost) ?? 0,
            distance: try container.decodeIfPresent(Double.self, forKey: .distance) ?? 0
        )
        
        id = try container.decode(UUID.self, forKey: .id)
        maintenanceDescription = try container.decodeIfPresent(String.self, forKey: .maintenanceDescription)
        isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
        isScheduled = try container.decodeIfPresent(Bool.self, forKey: .isScheduled) ?? false
        scheduledDate = try container.decodeIfPresent(Date.self, forKey: .scheduledDate)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        serviceProvider = try container.decodeIfPresent(String.self, forKey: .serviceProvider)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(maintenanceType, forKey: .maintenanceType)
        try container.encodeIfPresent(maintenanceDescription, forKey: .maintenanceDescription)
        try container.encode(date, forKey: .date)
        try container.encode(cost, forKey: .cost)
        try container.encode(distance, forKey: .distance)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(isScheduled, forKey: .isScheduled)
        try container.encodeIfPresent(scheduledDate, forKey: .scheduledDate)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encodeIfPresent(serviceProvider, forKey: .serviceProvider)
    }
}
