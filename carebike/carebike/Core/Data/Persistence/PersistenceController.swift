import Foundation
import SwiftData

@MainActor
class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    let container: ModelContainer
    private var maintenanceScheduler: MaintenanceScheduler?
    
    @Published var overdueComponents: [Component] = []
    @Published var upcomingMaintenance: [MaintenanceEvent] = []
    
    var modelContext: ModelContext {
        container.mainContext
    }
    
    init(inMemory: Bool = false) {
        do {
            let schema = Schema([
                Bicycle.self,
                Component.self,
                MaintenanceEvent.self,
                Ride.self,
                CostEntry.self
            ])
            
            let modelConfiguration: ModelConfiguration
            if inMemory {
                modelConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true,
                    allowsSave: true
                )
            } else {
                modelConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    allowsSave: true
                )
            }
            
            container = try ModelContainer(
                for: schema,
                configurations: modelConfiguration
            )
            
            maintenanceScheduler = MaintenanceScheduler(modelContext: container.mainContext)
            
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    func checkMaintenanceNeeds() async {
        await maintenanceScheduler?.checkMaintenanceNeeds()
        
        if let scheduler = maintenanceScheduler {
            overdueComponents = scheduler.overdueComponents
            upcomingMaintenance = scheduler.upcomingMaintenance
        }
    }
    
    func scheduleMaintenance(for bicycle: Bicycle, type: MaintenanceType, date: Date, notes: String? = nil) async throws -> MaintenanceEvent? {
        return try await maintenanceScheduler?.scheduleMaintenance(for: bicycle, type: type, date: date, notes: notes)
    }
    
    func completeMaintenance(_ event: MaintenanceEvent) {
        maintenanceScheduler?.completeMaintenance(event)
    }
    
    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }
}
