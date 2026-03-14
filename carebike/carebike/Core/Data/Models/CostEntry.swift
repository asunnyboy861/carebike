import Foundation
import SwiftData

@Model
final class CostEntry {
    var id: UUID
    var title: String
    var costType: CostType
    var amount: Double
    var date: Date
    var notes: String?
    var vendor: String?
    var receiptImageData: Data?
    
    var bicycle: Bicycle?
    var component: Component?
    var maintenanceEvent: MaintenanceEvent?
    
    init(title: String, costType: CostType, amount: Double, date: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.costType = costType
        self.amount = amount
        self.date = date
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

enum CostType: String, Codable, CaseIterable {
    case purchase = "Bike Purchase"
    case maintenance = "Maintenance"
    case component = "Component"
    case accessory = "Accessory"
    case gear = "Gear & Apparel"
    case service = "Service"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .purchase: return "bicycle"
        case .maintenance: return "wrench.and.screwdriver"
        case .component: return "gearshape"
        case .accessory: return "backpack"
        case .gear: return "person"
        case .service: return "wrench.adjustable"
        case .other: return "questionmark.circle"
        }
    }
}

extension CostEntry: Codable {
    enum CodingKeys: String, CodingKey {
        case id, title, costType, amount, date
        case notes, vendor, receiptImageData
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.init(
            title: try container.decode(String.self, forKey: .title),
            costType: try container.decode(CostType.self, forKey: .costType),
            amount: try container.decode(Double.self, forKey: .amount),
            date: try container.decode(Date.self, forKey: .date)
        )
        
        id = try container.decode(UUID.self, forKey: .id)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        vendor = try container.decodeIfPresent(String.self, forKey: .vendor)
        receiptImageData = try container.decodeIfPresent(Data.self, forKey: .receiptImageData)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(costType, forKey: .costType)
        try container.encode(amount, forKey: .amount)
        try container.encode(date, forKey: .date)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encodeIfPresent(vendor, forKey: .vendor)
        try container.encodeIfPresent(receiptImageData, forKey: .receiptImageData)
    }
}
