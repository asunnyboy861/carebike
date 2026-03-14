import Foundation
import SwiftData

@MainActor
class MaintenanceScheduler: ObservableObject {
    private let modelContext: ModelContext
    private let notificationManager = NotificationManager.shared
    
    @Published var upcomingMaintenance: [MaintenanceEvent] = []
    @Published var overdueComponents: [Component] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func checkMaintenanceNeeds() async {
        await checkComponentWear()
        await checkScheduledMaintenance()
    }
    
    private func checkComponentWear() async {
        let descriptor = FetchDescriptor<Component>(
            predicate: #Predicate { $0.isActive }
        )
        
        do {
            let components = try modelContext.fetch(descriptor)
            overdueComponents = components.filter { $0.needsReplacement || $0.needsAttention }
            
            for component in overdueComponents {
                if component.needsReplacement {
                    try await scheduleComponentReplacementReminder(component)
                } else if component.needsAttention {
                    try await scheduleComponentInspectionReminder(component)
                }
            }
        } catch {
            print("Failed to fetch components: \(error)")
        }
    }
    
    private func checkScheduledMaintenance() async {
        let now = Date()
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now
        
        let descriptor = FetchDescriptor<MaintenanceEvent>(
            predicate: #Predicate { 
                $0.isScheduled && !$0.isCompleted && $0.scheduledDate != nil
            }
        )
        
        do {
            let events = try modelContext.fetch(descriptor)
            upcomingMaintenance = events.filter { event in
                guard let scheduledDate = event.scheduledDate else { return false }
                return scheduledDate <= nextWeek
            }
        } catch {
            print("Failed to fetch maintenance events: \(error)")
        }
    }
    
    func scheduleMaintenance(
        for bicycle: Bicycle,
        type: MaintenanceType,
        date: Date,
        notes: String? = nil
    ) async throws -> MaintenanceEvent {
        let event = MaintenanceEvent(
            title: "\(type.rawValue) - \(bicycle.name)",
            maintenanceType: type,
            date: date
        )
        event.isScheduled = true
        event.scheduledDate = date
        event.notes = notes
        event.bicycle = bicycle
        
        modelContext.insert(event)
        
        try await notificationManager.scheduleMaintenanceReminder(
            id: NotificationIdentifier.maintenance(id: event.id),
            title: "Maintenance Reminder",
            body: "\(type.rawValue) for \(bicycle.name) is scheduled for today.",
            date: date
        )
        
        return event
    }
    
    private func scheduleComponentReplacementReminder(_ component: Component) async throws {
        guard let bicycle = component.bicycle else { return }
        
        try await notificationManager.scheduleMaintenanceReminder(
            id: NotificationIdentifier.component(id: component.id),
            title: "Component Replacement Needed",
            body: "Your \(component.name) on \(bicycle.name) needs replacement.",
            date: Date()
        )
    }
    
    private func scheduleComponentInspectionReminder(_ component: Component) async throws {
        guard let bicycle = component.bicycle else { return }
        
        let inspectionDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
        
        try await notificationManager.scheduleMaintenanceReminder(
            id: NotificationIdentifier.component(id: component.id),
            title: "Component Inspection Recommended",
            body: "Your \(component.name) on \(bicycle.name) should be inspected soon.",
            date: inspectionDate
        )
    }
    
    func completeMaintenance(_ event: MaintenanceEvent) {
        event.isCompleted = true
        event.date = Date()
        
        if let bicycle = event.bicycle {
            bicycle.lastMaintenanceDate = Date()
        }
        
        if let component = event.component {
            component.lastMaintenanceDate = Date()
            component.updateHealthStatus()
        }
        
        Task {
            try? await notificationManager.cancelNotification(
                id: NotificationIdentifier.maintenance(id: event.id)
            )
        }
    }
    
    func calculateNextMaintenanceDate(for bicycle: Bicycle) -> Date? {
        let defaultInterval: TimeInterval = 60 * 60 * 24 * 30
        
        if let lastMaintenance = bicycle.lastMaintenanceDate {
            return Calendar.current.date(byAdding: .month, value: 1, to: lastMaintenance)
        }
        
        return Calendar.current.date(byAdding: .month, value: 1, to: Date())
    }
}
