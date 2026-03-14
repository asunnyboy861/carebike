import Foundation

@available(*, deprecated, message: "Use CostAnalyzer (Core/Domain/Services/CostAnalyzer.swift) instead. TimeRange and SpendingTrend are now defined in CostAnalyzer.swift")
@MainActor
class AnalyticsViewModel: ObservableObject {
    @Published var totalSpending: Double = 0
    @Published var monthlySpending: [String: Double] = [:]
    @Published var categorySpending: [CostType: Double] = [:]
    @Published var spendingTrend: SpendingTrend = .stable
    
    @available(*, deprecated, message: "Use CostAnalyzer.analyzeSpending() instead")
    func analyze(entries: [CostEntry], timeRange: TimeRange = .allTime) {
    }
    
    private func calculateTrend() {
    }
    
    @available(*, deprecated, message: "Use CostAnalyzer.getCostPerKilometer() instead")
    func getCostPerKilometer(totalCost: Double, totalDistance: Double) -> Double {
        guard totalDistance > 0 else { return 0 }
        return totalCost / totalDistance
    }
    
    func getAverageRideDistance(rides: [Ride]) -> Double {
        guard !rides.isEmpty else { return 0 }
        return rides.reduce(0) { $0 + $1.distance } / Double(rides.count)
    }
    
    func getAverageRideDuration(rides: [Ride]) -> TimeInterval {
        guard !rides.isEmpty else { return 0 }
        return rides.reduce(0) { $0 + $1.duration } / Double(rides.count)
    }
}
