import Foundation
import SwiftData

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let maintenanceScheduler: MaintenanceScheduler?
    
    init() {
        self.maintenanceScheduler = nil
    }
    
    init(modelContext: ModelContext) {
        self.maintenanceScheduler = MaintenanceScheduler(modelContext: modelContext)
    }
    
    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        
        await maintenanceScheduler?.checkMaintenanceNeeds()
    }
    
    func getTotalDistance(for bicycles: [Bicycle]) -> Double {
        bicycles.reduce(0) { $0 + $1.totalDistance }
    }
    
    func getComponentsNeedingAttention(from components: [Component]) -> [Component] {
        components.filter { $0.needsAttention }
            .sorted { $0.usagePercentage > $1.usagePercentage }
    }
    
    func getUpcomingMaintenance(from events: [MaintenanceEvent]) -> [MaintenanceEvent] {
        events.filter { !$0.isCompleted && $0.isScheduled }
            .sorted { 
                guard let date1 = $0.scheduledDate, let date2 = $1.scheduledDate else { return false }
                return date1 < date2
            }
    }
    
    func getMostRiddenBike(from bicycles: [Bicycle]) -> Bicycle? {
        bicycles.max(by: { $0.totalDistance < $1.totalDistance })
    }
    
    func getMaintenanceCostThisMonth(for bicycle: Bicycle) -> Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        
        return (bicycle.maintenanceEvents ?? [])
            .filter { $0.date >= startOfMonth }
            .reduce(0) { $0 + $1.cost }
    }
}
