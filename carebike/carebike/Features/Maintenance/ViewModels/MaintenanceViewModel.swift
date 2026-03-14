import Foundation
import SwiftData

@MainActor
class MaintenanceViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedType: MaintenanceType?
    @Published var filter: MaintenanceFilter = .all
    
    func filterEvents(_ events: [MaintenanceEvent]) -> [MaintenanceEvent] {
        var filtered = events
        
        if !searchText.isEmpty {
            filtered = filtered.filter { event in
                event.title.localizedCaseInsensitiveContains(searchText) ||
                (event.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        if let type = selectedType {
            filtered = filtered.filter { $0.maintenanceType == type }
        }
        
        switch filter {
        case .all:
            break
        case .scheduled:
            filtered = filtered.filter { $0.isScheduled && !$0.isCompleted }
        case .completed:
            filtered = filtered.filter { $0.isCompleted }
        case .overdue:
            filtered = filtered.filter { event in
                guard event.isScheduled, !event.isCompleted, let date = event.scheduledDate else { return false }
                return date < Date()
            }
        }
        
        return filtered.sorted { $0.date > $1.date }
    }
    
    func getUpcomingMaintenance(_ events: [MaintenanceEvent]) -> [MaintenanceEvent] {
        events.filter { $0.isScheduled && !$0.isCompleted }
            .sorted {
                guard let d1 = $0.scheduledDate, let d2 = $1.scheduledDate else { return false }
                return d1 < d2
            }
    }
    
    func getOverdueMaintenance(_ events: [MaintenanceEvent]) -> [MaintenanceEvent] {
        events.filter { event in
            guard event.isScheduled, !event.isCompleted, let date = event.scheduledDate else { return false }
            return date < Date()
        }
    }
    
    func getTotalMaintenanceCost(_ events: [MaintenanceEvent]) -> Double {
        events.reduce(0) { $0 + $1.cost }
    }
    
    func getMaintenanceCostByMonth(_ events: [MaintenanceEvent]) -> [String: Double] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        
        return Dictionary(grouping: events) { formatter.string(from: $0.date) }
            .mapValues { events in events.reduce(0) { $0 + $1.cost } }
    }
    
    func getMaintenanceCountByType(_ events: [MaintenanceEvent]) -> [MaintenanceType: Int] {
        Dictionary(grouping: events) { $0.maintenanceType }
            .mapValues { $0.count }
    }
}
