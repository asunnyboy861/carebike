import Foundation
import SwiftData

@MainActor
class CostAnalyzer: ObservableObject {
    private let modelContext: ModelContext
    
    @Published var totalSpending: Double = 0
    @Published var monthlySpending: [String: Double] = [:]
    @Published var categorySpending: [CostType: Double] = [:]
    @Published var bikeSpending: [UUID: Double] = [:]
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func analyzeSpending(for bicycle: Bicycle? = nil, timeRange: TimeRange = .allTime) async {
        let calendar = Calendar.current
        let now = Date()
        
        var startDate: Date?
        switch timeRange {
        case .lastMonth:
            startDate = calendar.date(byAdding: .month, value: -1, to: now)
        case .lastThreeMonths:
            startDate = calendar.date(byAdding: .month, value: -3, to: now)
        case .lastYear:
            startDate = calendar.date(byAdding: .year, value: -1, to: now)
        case .allTime:
            startDate = nil
        }
        
        let descriptor = FetchDescriptor<CostEntry>()
        
        do {
            let entries = try modelContext.fetch(descriptor)
            let filteredEntries = entries.filter { entry in
                if let start = startDate, entry.date < start { return false }
                if let bike = bicycle, entry.bicycle?.id != bike.id { return false }
                return true
            }
            
            totalSpending = filteredEntries.reduce(0) { $0 + $1.amount }
            
            monthlySpending = [:]
            categorySpending = [:]
            bikeSpending = [:]
            
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "yyyy-MM"
            
            for entry in filteredEntries {
                let monthKey = monthFormatter.string(from: entry.date)
                monthlySpending[monthKey, default: 0] += entry.amount
                
                categorySpending[entry.costType, default: 0] += entry.amount
                
                if let bikeId = entry.bicycle?.id {
                    bikeSpending[bikeId, default: 0] += entry.amount
                }
            }
        } catch {
            print("Failed to analyze costs: \(error)")
        }
    }
    
    func getSpendingTrend() -> SpendingTrend {
        let sortedMonths = monthlySpending.keys.sorted()
        
        guard sortedMonths.count >= 2 else { return .stable }
        
        let recentMonths = sortedMonths.suffix(3)
        let previousMonths = sortedMonths.dropLast(3).suffix(3)
        
        let recentAverage = recentMonths.compactMap { monthlySpending[$0] }.reduce(0, +) / Double(max(recentMonths.count, 1))
        let previousAverage = previousMonths.compactMap { monthlySpending[$0] }.reduce(0, +) / Double(max(previousMonths.count, 1))
        
        let change = (recentAverage - previousAverage) / max(previousAverage, 1) * 100
        
        if change > 20 { return .increasing }
        if change < -20 { return .decreasing }
        return .stable
    }
    
    func getCostPerKilometer(for bicycle: Bicycle) -> Double {
        guard bicycle.totalDistance > 0 else { return 0 }
        let totalCost = bikeSpending[bicycle.id, default: 0]
        return totalCost / bicycle.totalDistance
    }
    
    func getMaintenanceCostPerMonth(for bicycle: Bicycle) -> Double {
        let maintenanceCosts = categorySpending[.maintenance, default: 0] + categorySpending[.component, default: 0]
        return maintenanceCosts / 12
    }
}


